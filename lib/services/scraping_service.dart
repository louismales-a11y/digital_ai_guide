import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_model.dart';

class ScrapingService {
  static const String _cacheVersionKey = 'cache_version';
  static const int _currentCacheVersion = 99; // Increment when model fields change
  static const String _cacheKey = 'cached_ai_models';
  static const String _lastFetchKey = 'last_fetch_time';
  static const Duration _cacheDuration = Duration(hours: 6);

  Future<List<AIModel>> getModels({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      final cached = prefs.getString(_cacheKey);
      final lastFetch = prefs.getInt(_lastFetchKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final cacheVersion = prefs.getInt(_cacheVersionKey) ?? 0;
      if (cached != null && cacheVersion == _currentCacheVersion && (now - lastFetch) < _cacheDuration.inMilliseconds) {
        final List<dynamic> decoded = jsonDecode(cached);
        return decoded.map((e) => AIModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
    // Always start with built-in models (they have all fields including bestFor, speed, languages)
    final models = _getBuiltinModels();
    // Try to enhance with fresh pricing from OpenRouter
    try {
      final freshPricing = await _scrapeOpenRouter();
      for (final fresh in freshPricing) {
        final idx = models.indexWhere((m) => m.name == fresh.name || m.provider == fresh.provider);
        if (idx >= 0) {
          models[idx] = AIModel(
            name: models[idx].name, provider: models[idx].provider,
            description: models[idx].description, strengths: models[idx].strengths,
            inputPricePer1kTokens: fresh.inputPricePer1kTokens ?? models[idx].inputPricePer1kTokens,
            outputPricePer1kTokens: fresh.outputPricePer1kTokens ?? models[idx].outputPricePer1kTokens,
            contextWindow: fresh.contextWindow ?? models[idx].contextWindow,
            category: models[idx].category,
            supportsVision: models[idx].supportsVision, supportsFunctionCalling: models[idx].supportsFunctionCalling,
            supportsStreaming: models[idx].supportsStreaming,
            benchmarkScore: models[idx].benchmarkScore, knowledgeCutoff: models[idx].knowledgeCutoff,
            websiteUrl: models[idx].websiteUrl,
            weaknesses: models[idx].weaknesses, reviews: models[idx].reviews,
            bestFor: models[idx].bestFor, speed: models[idx].speed, languages: models[idx].languages,
          );
        }
      }
    } catch (_) {}
    final encoded = jsonEncode(models.map((m) => m.toJson()).toList());
    await prefs.setString(_cacheKey, encoded);
    await prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt(_cacheVersionKey, _currentCacheVersion);
    return models;
  }
  Future<List<AIModel>> _scrapeAllSources() async {
    final models = <AIModel>[];
    try {
      final openRouterModels = await _scrapeOpenRouter();
      models.addAll(openRouterModels);
    } catch (_) {}
    if (models.isNotEmpty) return models;
    return _getBuiltinModels();
  }

  Future<List<AIModel>> _scrapeOpenRouter() async {
    final models = <AIModel>[];
    final response = await http.get(
      Uri.parse('https://openrouter.ai/api/v1/models'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> modelList = data['data'] as List<dynamic>? ?? [];
      for (final item in modelList) {
        try {
          final id = item['id'] as String? ?? '';
          final name = item['name'] as String? ?? id;
          String provider = 'Unknown';
          if (id.contains('openai')) provider = 'OpenAI';
          else if (id.contains('anthropic')) provider = 'Anthropic';
          else if (id.contains('google') || id.contains('gemini')) provider = 'Google';
          else if (id.contains('meta') || id.contains('llama')) provider = 'Meta';
          else if (id.contains('mistral')) provider = 'Mistral';
          else if (id.contains('cohere')) provider = 'Cohere';
          else if (id.contains('deepseek')) provider = 'DeepSeek';
          else if (id.contains('xai') || id.contains('grok')) provider = 'xAI';
          else if (id.contains('perplexity')) provider = 'Perplexity';

          final pricing = item['pricing'] as Map<String, dynamic>?;
          final double? inputPrice = pricing != null ? double.tryParse((pricing['prompt'] ?? '0').toString()) : null;
          final double? outputPrice = pricing != null ? double.tryParse((pricing['completion'] ?? '0').toString()) : null;
          final contextLength = item['context_length'] as int?;
          final description = item['description'] as String? ?? '';

          String category = 'General';
          final idl = id.toLowerCase();
          if (idl.contains('vision') || idl.contains('multimodal')) category = 'Vision';
          else if (idl.contains('instruct') || idl.contains('chat')) category = 'Chat';
          else if (idl.contains('code') || idl.contains('coder')) category = 'Code';
          else if (idl.contains('reasoning') || idl.contains('thinking')) category = 'Reasoning';
          else if (idl.contains('embedding') || idl.contains('embed')) category = 'Embeddings';
          else if (idl.contains('image') || idl.contains('dall-e') || idl.contains('stable-diffusion')) category = 'Image';
          else if (idl.contains('audio') || idl.contains('whisper') || idl.contains('tts')) category = 'Audio';

          models.add(AIModel(
            name: name,
            provider: provider,
            description: description,
            strengths: _inferStrengths(name, provider, category),
            inputPricePer1kTokens: inputPrice,
            outputPricePer1kTokens: outputPrice,
            contextWindow: contextLength,
            category: category,
            supportsVision: idl.contains('vision'),
            supportsFunctionCalling: true,
            supportsStreaming: true,
            websiteUrl: _getWebsiteUrl(id, provider),
            benchmarkScore: _getBenchmarkHint(name, provider),
          ));
        } catch (_) {
          continue;
        }
      }
    }
    return models;
  }

  String _inferStrengths(String name, String provider, String category) {
    final lower = name.toLowerCase();
    final s = <String>[];
    if (lower.contains('gpt-4') || lower.contains('claude-3') || lower.contains('gemini-ultra')) {
      s.addAll(['Best-in-class reasoning', 'Complex task handling']);
    }
    if (lower.contains('gpt-4o') || lower.contains('claude-3.5') || lower.contains('gemini-1.5')) {
      s.addAll(['Multimodal capabilities', 'Fast response times']);
    }
    if (lower.contains('gpt-3.5') || lower.contains('haiku') || lower.contains('flash') || lower.contains('mistral-small') || lower.contains('llama-3')) {
      s.addAll(['Cost-effective', 'Fast inference']);
    }
    if (lower.contains('code') || lower.contains('coder')) {
      s.addAll(['Code generation & review', 'Debugging assistance']);
    }
    if (lower.contains('reasoning') || lower.contains('thinking')) {
      s.addAll(['Deep reasoning', 'Step-by-step analysis']);
    }
    if (category == 'Vision') {
      s.addAll(['Image understanding', 'Visual question answering']);
    }
    if (lower.contains('embedding')) {
      s.addAll(['Semantic search', 'Text similarity']);
    }
    if (s.isEmpty) {
      s.addAll(['General purpose AI', 'Natural language processing']);
    }
    return s.join(' \u2022 ');
  }

  String? _getBenchmarkHint(String name, String provider) {
    final lower = name.toLowerCase();
    if (lower.contains('gpt-4o')) return 'MMLU: 88.7%';
    if (lower.contains('gpt-4-turbo')) return 'MMLU: 86.5%';
    if (lower.contains('gpt-4')) return 'MMLU: 86.4%';
    if (lower.contains('claude-3.5')) return 'MMLU: 88.9%';
    if (lower.contains('claude-3-opus')) return 'MMLU: 86.8%';
    if (lower.contains('claude-3-sonnet')) return 'MMLU: 79.0%';
    if (lower.contains('gemini-ultra')) return 'MMLU: 90.0%';
    if (lower.contains('gemini-1.5')) return 'MMLU: 85.9%';
    if (lower.contains('gemini-flash')) return 'MMLU: 77.8%';
    if ((lower.contains('llama-3') && (lower.contains('70b') || lower.contains('405b')))) return 'MMLU: 86.1%';
    if (lower.contains('llama-3')) return 'MMLU: 68.9%';
    if (lower.contains('mistral-large')) return 'MMLU: 84.0%';
    if (lower.contains('mistral-medium')) return 'MMLU: 75.0%';
    if (lower.contains('mistral-small')) return 'MMLU: 72.0%';
    if (lower.contains('deepseek')) return 'MMLU: 88.3%';
    return null;
  }


  String _getWebsiteUrl(String id, String provider) {
    final lower = id.toLowerCase();
    if (lower.contains('openai') || provider == 'OpenAI') return 'https://openai.com';
    if (lower.contains('anthropic') || provider == 'Anthropic') return 'https://anthropic.com';
    if (lower.contains('google') || lower.contains('gemini') || provider == 'Google') return 'https://deepmind.google/technologies/gemini';
    if (lower.contains('meta') || lower.contains('llama') || provider == 'Meta') return 'https://www.llama.com';
    if (lower.contains('mistral') || provider == 'Mistral') return 'https://mistral.ai';
    if (lower.contains('deepseek') || provider == 'DeepSeek') return 'https://deepseek.com';
    if (lower.contains('xai') || lower.contains('grok') || provider == 'xAI') return 'https://x.ai';
    if (lower.contains('cohere') || provider == 'Cohere') return 'https://cohere.com';
    if (lower.contains('perplexity')) return 'https://perplexity.ai';
    return 'https://' + provider.toLowerCase() + '.ai';
  }

  List<AIModel> _getBuiltinModels() {
    return [
      AIModel(name: 'GPT-4o', provider: 'OpenAI',
        description: 'Omni model with vision, audio, and text capabilities.',
        strengths: 'Multimodal | Fastest flagship | Cost-effective | 128K context',
        inputPricePer1kTokens: 0.0025, outputPricePer1kTokens: 0.01, contextWindow: 128000,
        category: 'Vision', supportsVision: true, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 88.7%', knowledgeCutoff: '2024-10-01', websiteUrl: 'https://openai.com/index/gpt-4o/',
        weaknesses: ['Higher cost than GPT-4o Mini', 'No native image generation', 'Rate limits on free tier'],
        reviews: [
          AIReview(author: 'TechCrunch', rating: 4.5, text: 'Best all-around multimodal model.', source: 'techcrunch.com'),
          AIReview(author: 'Ars Technica', rating: 4, text: 'Impressive vision capabilities.', source: 'arstechnica.com'),
        ],
        bestFor: 'General purpose, vision tasks, chat',
        speed: 'Fast',
        languages: 'Multilingual (50+)',
        easeOfUse: 'Easy'),
      AIModel(name: 'GPT-4o Mini', provider: 'OpenAI',
        description: 'Small, affordable model for lightweight tasks.',
        strengths: 'Extremely affordable | Fast | 128K context',
        inputPricePer1kTokens: 0.00015, outputPricePer1kTokens: 0.0006, contextWindow: 128000,
        category: 'Chat', supportsVision: true, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 82.0%', knowledgeCutoff: '2024-10-01', websiteUrl: 'https://openai.com/index/gpt-4o-mini/',
        weaknesses: ['Lower reasoning than GPT-4o', 'Not for complex tasks'],
        reviews: [
          AIReview(author: 'The Verge', rating: 4, text: 'Incredible value.', source: 'theverge.com'),
          AIReview(author: 'Developer', rating: 4.5, text: 'Best price-performance.'),
        ],
        bestFor: 'Simple chat, classification, lightweight tasks',
        speed: 'Very fast',
        languages: 'Multilingual (50+)',
        easeOfUse: 'Easy'),
      AIModel(name: 'Claude 3.5 Sonnet', provider: 'Anthropic',
        description: 'Most intelligent model with strong reasoning and coding.',
        strengths: 'Best coding | Strong reasoning | 200K context',
        inputPricePer1kTokens: 0.003, outputPricePer1kTokens: 0.015, contextWindow: 200000,
        category: 'Code',
        benchmarkScore: 'MMLU: 88.9%', knowledgeCutoff: '2025-04-01', websiteUrl: 'https://anthropic.com/claude/sonnet',
        weaknesses: ['Higher latency', 'More expensive', 'Smaller ecosystem'],
        reviews: [
          AIReview(author: 'Cursor AI', rating: 5, text: 'Best model for code generation.', source: 'cursor.com'),
          AIReview(author: 'Developer', rating: 4.5, text: 'Catches bugs that GPT misses.'),
        ],
        bestFor: 'Coding, analysis, long-form writing',
        speed: 'Moderate',
        languages: 'Multilingual (30+)',
        easeOfUse: 'Moderate'),
      AIModel(name: 'Claude 3.5 Haiku', provider: 'Anthropic',
        description: 'Fastest and most compact model.',
        strengths: 'Lightning fast | Cost-effective | 200K context',
        inputPricePer1kTokens: 0.0008, outputPricePer1kTokens: 0.004, contextWindow: 200000,
        category: 'Chat', supportsVision: true, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 78.0%', knowledgeCutoff: '2025-04-01', websiteUrl: 'https://anthropic.com/claude/haiku',
        weaknesses: ['Less capable on complex tasks', 'Smaller knowledge base'],
        reviews: [
          AIReview(author: 'Developer', rating: 4, text: 'Blazing fast and cheap.'),
        ],
        bestFor: 'Quick Q&A, data extraction, chatbots',
        speed: 'Very fast',
        languages: 'Multilingual (20+)',
        easeOfUse: 'Easy'),
      AIModel(name: 'Gemini 2.0 Flash', provider: 'Google',
        description: 'Next-gen multimodal model.',
        strengths: 'Multimodal | Extremely fast | 1M context',
        inputPricePer1kTokens: 0.00015, outputPricePer1kTokens: 0.0006, contextWindow: 1000000,
        category: 'Vision', supportsVision: true, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 85.0%', knowledgeCutoff: '2025-06-01', websiteUrl: 'https://deepmind.google/technologies/gemini/flash',
        weaknesses: ['Less consistent on reasoning', 'Google integration limits'],
        reviews: [
          AIReview(author: 'Developer', rating: 4, text: 'Insanely fast. 1M context is unmatched.'),
        ],
        bestFor: 'Long documents, multimodal, real-time apps',
        speed: 'Very fast',
        languages: 'Multilingual (40+)',
        easeOfUse: 'Easy'),
      AIModel(name: 'Gemini 2.0 Pro', provider: 'Google',
        description: "Google's most capable model.",
        strengths: 'Best reasoning | Coding expert | 2M context',
        inputPricePer1kTokens: 0.005, outputPricePer1kTokens: 0.015, contextWindow: 2000000,
        category: 'General', supportsVision: true, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 90.0%', knowledgeCutoff: '2025-06-01', websiteUrl: 'https://deepmind.google/technologies/gemini/pro',
        weaknesses: ['Very expensive', 'Limited availability'],
        reviews: [
          AIReview(author: 'Benchmark Analyst', rating: 4.5, text: 'Top of MMLU at 90%.'),
        ],
        bestFor: 'Research, complex analysis, coding',
        speed: 'Moderate',
        languages: 'Multilingual (40+)',
        easeOfUse: 'Moderate'),
      AIModel(name: 'Llama 3.1 405B', provider: 'Meta',
        description: 'Largest open-source model.',
        strengths: 'Open-source | Frontier capabilities | 128K context',
        inputPricePer1kTokens: 0.002, outputPricePer1kTokens: 0.002, contextWindow: 128000,
        category: 'General', supportsVision: false, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 86.1%', knowledgeCutoff: '2024-03-01', websiteUrl: 'https://www.llama.com',
        weaknesses: ['Massive compute needed', 'Not available as API directly'],
        reviews: [
          AIReview(author: 'Meta AI', rating: 5, text: 'Largest open-source model ever.', source: 'ai.meta.com'),
        ],
        bestFor: 'Self-hosting, research, customization',
        speed: 'Slow',
        languages: 'Multilingual (30+)',
        easeOfUse: 'Complex'),
      AIModel(name: 'Llama 3.1 70B', provider: 'Meta',
        description: 'Efficient open-source model.',
        strengths: 'Open-source | Good performance | Cost-effective',
        inputPricePer1kTokens: 0.0008, outputPricePer1kTokens: 0.0008, contextWindow: 128000,
        category: 'General', supportsVision: false, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 80.0%', knowledgeCutoff: '2024-03-01', websiteUrl: 'https://www.llama.com',
        weaknesses: ['Not multimodal', 'Requires significant compute'],
        reviews: [
          AIReview(author: 'Self-hosted Dev', rating: 4.5, text: 'Best for self-hosting.'),
        ],
        bestFor: 'Self-hosting, chatbots, fine-tuning',
        speed: 'Moderate',
        languages: 'Multilingual (20+)',
        easeOfUse: 'Moderate'),
      AIModel(name: 'Mistral Large 2', provider: 'Mistral',
        description: 'Mistral flagship model.',
        strengths: 'Multilingual | Strong reasoning | 128K context',
        inputPricePer1kTokens: 0.003, outputPricePer1kTokens: 0.009, contextWindow: 128000,
        category: 'General', supportsVision: false, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 84.0%', knowledgeCutoff: '2025-01-01', websiteUrl: 'https://mistral.ai/news/mistral-large-2/',
        weaknesses: ['Smaller ecosystem', 'Fewer integrations'],
        reviews: [
          AIReview(author: 'Developer', rating: 4, text: 'Excellent multilingual support.'),
        ],
        bestFor: 'Multilingual tasks, European languages',
        speed: 'Fast',
        languages: 'Multilingual (50+)',
        easeOfUse: 'Moderate'),
      AIModel(name: 'DeepSeek-V3', provider: 'DeepSeek',
        description: 'Highly efficient MoE model.',
        strengths: 'Ultra low cost | Strong reasoning | 128K context',
        inputPricePer1kTokens: 0.00027, outputPricePer1kTokens: 0.0011, contextWindow: 128000,
        category: 'Reasoning',
        benchmarkScore: 'MMLU: 88.3%', knowledgeCutoff: '2025-03-01', websiteUrl: 'https://deepseek.com',
        weaknesses: ['Less known', 'Smaller community'],
        reviews: [
          AIReview(author: 'AI Benchmark', rating: 5, text: 'Best price-to-performance.', source: 'artificialanalysis.ai'),
        ],
        bestFor: 'Budget-friendly, reasoning, coding',
        speed: 'Fast',
        languages: 'Multilingual (20+)',
        easeOfUse: 'Easy'),
      AIModel(name: 'Grok-2', provider: 'xAI',
        description: 'xAI frontier model.',
        strengths: 'Real-time knowledge | Strong reasoning',
        inputPricePer1kTokens: 0.005, outputPricePer1kTokens: 0.015, contextWindow: 128000,
        category: 'Reasoning',
        benchmarkScore: 'MMLU: 87.5%', knowledgeCutoff: '2025-04-01', websiteUrl: 'https://x.ai',
        weaknesses: ['Limited availability', 'Smaller ecosystem'],
        reviews: [
          AIReview(author: 'X Premium User', rating: 4.5, text: 'Love the real-time awareness.'),
        ],
        bestFor: 'Real-time news, witty chat, current events',
        speed: 'Fast',
        languages: 'English',
        easeOfUse: 'Easy'),
      AIModel(name: 'Command R+', provider: 'Cohere',
        description: 'Enterprise RAG model.',
        strengths: 'Enterprise RAG | Multilingual | Citation support',
        inputPricePer1kTokens: 0.003, outputPricePer1kTokens: 0.015, contextWindow: 128000,
        category: 'General', supportsVision: false, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 75.7%', knowledgeCutoff: '2024-08-01', websiteUrl: 'https://cohere.com',
        weaknesses: ['Lower reasoning scores', 'Smaller community'],
        reviews: [
          AIReview(author: 'Enterprise Dev', rating: 4.5, text: 'Best-in-class for RAG.'),
        ],
        bestFor: 'Enterprise RAG, document processing',
        speed: 'Moderate',
        languages: 'Multilingual (10+)',
        easeOfUse: 'Moderate'),
      AIModel(name: 'GPT-4 Turbo', provider: 'OpenAI',
        description: 'Previous flagship with 128K context and vision.',
        strengths: '128K context | Vision | Reliable | Broad knowledge',
        inputPricePer1kTokens: 0.01, outputPricePer1kTokens: 0.03, contextWindow: 128000,
        category: 'General', supportsVision: true, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 86.4%', knowledgeCutoff: '2024-04-01', websiteUrl: 'https://openai.com',
        weaknesses: ['Slower than GPT-4o', 'More expensive'],
        reviews: [AIReview(author: 'GPT-4 Turbo', rating: 4.0, text: 'Previous flagship with 128K context and vision.')],
        bestFor: 'Legacy apps, reliable perf',
        speed: 'Moderate',
        languages: 'Multilingual (40+)',
        easeOfUse: 'Easy'),
      AIModel(name: 'o1', provider: 'OpenAI',
        description: 'Reasoning model with chain-of-thought for complex problems.',
        strengths: 'Deep reasoning | Math | Science | Step-by-step',
        inputPricePer1kTokens: 0.015, outputPricePer1kTokens: 0.06, contextWindow: 128000,
        category: 'Reasoning', supportsVision: false, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 92.3%', knowledgeCutoff: '2024-09-01', websiteUrl: 'https://openai.com',
        weaknesses: ['Very expensive', 'Slow', 'No vision'],
        reviews: [AIReview(author: 'o1', rating: 4.0, text: 'Reasoning model with chain-of-thought for complex problems.')],
        bestFor: 'Complex math, science, reasoning',
        speed: 'Slow',
        languages: 'English',
        easeOfUse: 'Complex'),
      AIModel(name: 'Claude 3 Opus', provider: 'Anthropic',
        description: 'Anthropic most powerful model for complex tasks.',
        strengths: 'Deep analysis | Nuanced | Best reasoning | Safe',
        inputPricePer1kTokens: 0.015, outputPricePer1kTokens: 0.075, contextWindow: 200000,
        category: 'General', supportsVision: true, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 86.8%', knowledgeCutoff: '2024-02-01', websiteUrl: 'https://anthropic.com',
        weaknesses: ['Very expensive', 'Slow'],
        reviews: [AIReview(author: 'Claude 3 Opus', rating: 4.0, text: 'Anthropic most powerful model for complex tasks.')],
        bestFor: 'Complex analysis, research',
        speed: 'Slow',
        languages: 'Multilingual (30+)',
        easeOfUse: 'Moderate'),
      AIModel(name: 'Gemini 1.5 Pro', provider: 'Google',
        description: 'Previous-gen flagship with 2M context window.',
        strengths: '2M context | Multimodal | Strong reasoning',
        inputPricePer1kTokens: 0.0035, outputPricePer1kTokens: 0.0105, contextWindow: 2000000,
        category: 'General', supportsVision: true, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 85.9%', knowledgeCutoff: '2024-05-01', websiteUrl: 'https://deepmind.google/technologies/gemini',
        weaknesses: ['Outperformed by 2.0 Pro', 'Slower'],
        reviews: [AIReview(author: 'Gemini 1.5 Pro', rating: 4.0, text: 'Previous-gen flagship with 2M context window.')],
        bestFor: 'Long docs, research papers',
        speed: 'Moderate',
        languages: 'Multilingual (40+)',
        easeOfUse: 'Easy'),
      AIModel(name: 'Mixtral 8x7B', provider: 'Mistral',
        description: 'Efficient mixture-of-experts open-source model.',
        strengths: 'MoE efficient | Open weights | Fast | Good perf',
        inputPricePer1kTokens: 0.0007, outputPricePer1kTokens: 0.0007, contextWindow: 32768,
        category: 'General', supportsVision: false, supportsFunctionCalling: true,
        benchmarkScore: 'MMLU: 70.6%', knowledgeCutoff: '2024-02-01', websiteUrl: 'https://mistral.ai',
        weaknesses: ['Lower benchmarks', 'Limited context'],
        reviews: [AIReview(author: 'Mixtral 8x7B', rating: 4.0, text: 'Efficient mixture-of-experts open-source model.')],
        bestFor: 'Self-hosting, chatbots',
        speed: 'Fast',
        languages: 'Multilingual (20+)',
        easeOfUse: 'Complex'),
      AIModel(name: 'Codestral', provider: 'Mistral',
        description: 'Mistral code-focused model with 32K context and strong multilingual code generation.',
        strengths: 'Code generation | 32K context | Multilingual code | Fast',
        inputPricePer1kTokens: 0.001, outputPricePer1kTokens: 0.003, contextWindow: 32000,
        category: 'Code', supportsVision: false, supportsFunctionCalling: true,
        benchmarkScore: null, knowledgeCutoff: '2024-07-01', websiteUrl: 'https://mistral.ai',
        weaknesses: ['Limited context', 'No vision', 'Narrow focus'],
        reviews: [],
        bestFor: 'Code generation, completion, review',
        speed: 'Fast',
        languages: 'Multilingual (20+)',
        easeOfUse: 'Moderate'),
      AIModel(name: 'DeepSeek-Coder V2', provider: 'DeepSeek',
        description: 'DeepSeek specialized code model with strong performance on coding benchmarks.',
        strengths: 'Code expert | Strong benchmarks | 128K context | Cost-effective',
        inputPricePer1kTokens: 0.00014, outputPricePer1kTokens: 0.00028, contextWindow: 128000,
        category: 'Code', supportsVision: false, supportsFunctionCalling: true,
        benchmarkScore: null, knowledgeCutoff: '2025-03-01', websiteUrl: 'https://deepseek.com',
        weaknesses: ['Limited non-code tasks', 'Less known'],
        reviews: [],
        bestFor: 'Code generation, debugging, optimization',
        speed: 'Fast',
        languages: 'English',
        easeOfUse: 'Easy'),
      AIModel(name: 'Code Llama 70B', provider: 'Meta',
        description: 'Meta open-source code generation model based on Llama 2 architecture.',
        strengths: 'Open-source | Code specialist | 70B params | Free',
        inputPricePer1kTokens: 0.0008, outputPricePer1kTokens: 0.0008, contextWindow: 16384,
        category: 'Code', supportsVision: false, supportsFunctionCalling: false,
        benchmarkScore: null, knowledgeCutoff: '2024-03-01', websiteUrl: 'https://ai.meta.com',
        weaknesses: ['Smaller context', 'No vision', 'No function calling'],
        reviews: [],
        bestFor: 'Self-hosted code gen, education',
        speed: 'Moderate',
        languages: 'English',
        easeOfUse: 'Complex'),
      AIModel(name: 'CodeGemma 7B', provider: 'Google',
        description: 'Google lightweight code model optimized for fast code completion.',
        strengths: 'Lightweight | Fast completion | Open weights | Efficient',
        inputPricePer1kTokens: 0.0002, outputPricePer1kTokens: 0.0002, contextWindow: 8192,
        category: 'Code', supportsVision: false, supportsFunctionCalling: false,
        benchmarkScore: null, knowledgeCutoff: '2024-06-01', websiteUrl: 'https://ai.google.dev',
        weaknesses: ['Very small context', 'Basic capabilities', 'No vision'],
        reviews: [],
        bestFor: 'Code completion, IDE integration',
        speed: 'Very fast',
        languages: 'English',
        easeOfUse: 'Moderate'),
      AIModel(name: 'StarCoder2 15B', provider: 'Hugging Face',
        description: 'Open-source code model trained on 900+ programming languages.',
        strengths: 'Open-source | 900+ languages | 15B params | Community',
        inputPricePer1kTokens: 0.0004, outputPricePer1kTokens: 0.0004, contextWindow: 16384,
        category: 'Code', supportsVision: false, supportsFunctionCalling: false,
        benchmarkScore: null, knowledgeCutoff: '2024-04-01', websiteUrl: 'https://huggingface.co/bigcode',
        weaknesses: ['Limited context', 'No vision', 'Basic reasoning'],
        reviews: [],
        bestFor: 'Code generation, multi-language',
        speed: 'Fast',
        languages: 'Multilingual (30+)',
        easeOfUse: 'Complex'),
    ];
  }
}
