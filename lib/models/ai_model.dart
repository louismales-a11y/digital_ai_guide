
class AIReview {
  final String author;
  final double rating;
  final String text;
  final String? source;

  AIReview({required this.author, required this.rating, required this.text, this.source});

  factory AIReview.fromJson(Map<String, dynamic> json) {
    return AIReview(
      author: json['author'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      text: json['text'] as String? ?? '',
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'author': author,
    'rating': rating,
    'text': text,
    'source': source,
  };
}

class AIModel {
  final String name;
  final String provider;
  final String description;
  final String strengths;
  final double? inputPricePer1kTokens;
  final double? outputPricePer1kTokens;
  final int? contextWindow;
  final String category;
  final String? iconUrl;
  final bool supportsVision;
  final bool supportsFunctionCalling;
  final bool supportsStreaming;
  final DateTime? lastUpdated;
  final String? benchmarkScore;
  final String? knowledgeCutoff;
  final String? websiteUrl;
  final List<String> weaknesses;
  final List<AIReview> reviews;
  final String? bestFor;
  final String? speed;
  final String? languages;
  final String? easeOfUse; // Easy, Moderate, Complex

  AIModel({
    required this.name,
    required this.provider,
    required this.description,
    required this.strengths,
    this.inputPricePer1kTokens,
    this.outputPricePer1kTokens,
    this.contextWindow,
    required this.category,
    this.iconUrl,
    this.supportsVision = false,
    this.supportsFunctionCalling = false,
    this.supportsStreaming = true,
    this.lastUpdated,
    this.benchmarkScore,
    this.knowledgeCutoff,
    this.websiteUrl,
    this.weaknesses = const [],
    this.reviews = const [],
    this.bestFor,
    this.speed,
    this.languages,
    this.easeOfUse,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      name: json['name'] as String,
      provider: json['provider'] as String,
      description: json['description'] as String? ?? '',
      strengths: json['strengths'] as String? ?? '',
      inputPricePer1kTokens: (json['input_price_per_1k_tokens'] as num?)?.toDouble(),
      outputPricePer1kTokens: (json['output_price_per_1k_tokens'] as num?)?.toDouble(),
      contextWindow: json['context_window'] as int?,
      category: json['category'] as String? ?? 'General',
      iconUrl: json['icon_url'] as String?,
      supportsVision: json['supports_vision'] as bool? ?? false,
      supportsFunctionCalling: json['supports_function_calling'] as bool? ?? false,
      supportsStreaming: json['supports_streaming'] as bool? ?? true,
      lastUpdated: json['last_updated'] != null ? DateTime.tryParse(json['last_updated'] as String) : null,
      benchmarkScore: json['benchmark_score'] as String?,
      knowledgeCutoff: json['knowledge_cutoff'] as String?,
      websiteUrl: json['website_url'] as String?,
      weaknesses: (json['weaknesses'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      reviews: (json['reviews'] as List<dynamic>?)?.map((e) => AIReview.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      bestFor: json['best_for'] as String?,
      speed: json['speed'] as String?,
      languages: json['languages'] as String?,
      easeOfUse: json['ease_of_use'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'provider': provider,
      'description': description,
      'strengths': strengths,
      'input_price_per_1k_tokens': inputPricePer1kTokens,
      'output_price_per_1k_tokens': outputPricePer1kTokens,
      'context_window': contextWindow,
      'category': category,
      'icon_url': iconUrl,
      'supports_vision': supportsVision,
      'supports_function_calling': supportsFunctionCalling,
      'supports_streaming': supportsStreaming,
      'last_updated': lastUpdated?.toIso8601String(),
      'benchmark_score': benchmarkScore,
      'knowledge_cutoff': knowledgeCutoff,
      'website_url': websiteUrl,
      'weaknesses': weaknesses,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'best_for': bestFor,
      'speed': speed,
      'languages': languages,
      'ease_of_use': easeOfUse,
    };
  }

  String get priceDisplay {
    if (inputPricePer1kTokens == null && outputPricePer1kTokens == null) {
      return 'Contact for pricing';
    }
    final input = inputPricePer1kTokens != null ? '\$${inputPricePer1kTokens!.toStringAsFixed(4)}' : 'N/A';
    final output = outputPricePer1kTokens != null ? '\$${outputPricePer1kTokens!.toStringAsFixed(4)}' : 'N/A';
    return 'Input: $input/1k tokens • Output: $output/1k tokens';
  }

  List<String> get strengthsList => strengths.split(' | ').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  String get displayUrl {
    if (websiteUrl != null && websiteUrl!.isNotEmpty) return websiteUrl!;
    switch (provider) {
      case 'OpenAI': return 'https://openai.com';
      case 'Anthropic': return 'https://anthropic.com';
      case 'Google': return 'https://deepmind.google/technologies/gemini';
      case 'Meta': return 'https://www.llama.com';
      case 'Mistral': return 'https://mistral.ai';
      case 'DeepSeek': return 'https://deepseek.com';
      case 'xAI': return 'https://x.ai';
      case 'Cohere': return 'https://cohere.com';
      default: return 'https://' + provider.toLowerCase() + '.ai';
    }
  }
}
