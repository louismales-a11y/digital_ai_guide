import '../models/ai_model.dart';

class ModelScore {
  final AIModel model;
  final double score;
  final List<String> reasons;

  ModelScore({required this.model, required this.score, required this.reasons});
}

class AdvisorService {
  /// Recommend the best models based on user needs
  static List<ModelScore> recommend({
    required List<AIModel> models,
    required List<String> taskTypes,
    required double budgetPreference, // 0.0 = cheapest, 1.0 = best
    required String contextLength, // 'short', 'medium', 'long'
  }) {
    final scored = <ModelScore>[];

    for (final model in models) {
      double score = 0;
      final reasons = <String>[];

      // === Task-based scoring ===
      for (final task in taskTypes) {
        switch (task) {
        case 'coding':
          if (model.name.toLowerCase().contains('claude') ||
              model.name.toLowerCase().contains('sonnet')) {
            score += 30;
            reasons.add('Excellent at code generation & debugging');
          }
          if (model.supportsFunctionCalling) {
            score += 15;
            reasons.add('Supports function/tool calling');
          }
          if (model.name.toLowerCase().contains('gpt-4') ||
              model.name.toLowerCase().contains('deepseek')) {
            score += 20;
            reasons.add('Strong coding benchmarks');
          }
          break;

        case 'writing':
          if (model.name.toLowerCase().contains('claude') ||
              model.name.toLowerCase().contains('sonnet')) {
            score += 25;
            reasons.add('Best-in-class nuanced writing');
          }
          if (model.name.toLowerCase().contains('gpt-4')) {
            score += 25;
            reasons.add('Strong creative & professional writing');
          }
          if (model.contextWindow != null && model.contextWindow! >= 100000) {
            score += 15;
            reasons.add('Large context for long-form content');
          }
          break;

        case 'analysis':
          if (model.benchmarkScore != null) {
            final mmlu = double.tryParse(model.benchmarkScore!.replaceAll(RegExp(r'[^0-9.]'), ''));
            if (mmlu != null && mmlu > 85) {
              score += 30;
              reasons.add('Top benchmark scores (MMLU: ${model.benchmarkScore})');
            }
          }
          if (model.contextWindow != null && model.contextWindow! >= 100000) {
            score += 20;
            reasons.add('Large context for deep analysis');
          }
          break;

        case 'creative':
          score += 20;
          if (model.name.toLowerCase().contains('gpt')) {
            score += 15;
            reasons.add('Creative writing strength');
          }
          if (model.supportsVision) {
            score += 10;
            reasons.add('Multimodal for visual creativity');
          }
          break;

        case 'chat':
          if (model.name.toLowerCase().contains('mini') ||
              model.name.toLowerCase().contains('haiku') ||
              model.name.toLowerCase().contains('flash')) {
            score += 25;
            reasons.add('Fast & cost-effective for chat');
          }
          score += 15; // All models can chat
          reasons.add('General purpose conversation');
          break;

        case 'vision':
          if (model.supportsVision) {
            score += 35;
            reasons.add('Supports image understanding');
          }
          if (model.name.toLowerCase().contains('gpt-4o') ||
              model.name.toLowerCase().contains('gemini') ||
              model.name.toLowerCase().contains('vision')) {
            score += 20;
            reasons.add('Best-in-class multimodal performance');
          }
          break;

        case 'reasoning':
          if (model.benchmarkScore != null) {
            final mmlu = double.tryParse(model.benchmarkScore!.replaceAll(RegExp(r'[^0-9.]'), ''));
            if (mmlu != null && mmlu > 85) {
              score += 30;
              reasons.add('Top benchmark performance (MMLU: ${model.benchmarkScore})');
            }
          }
          if (model.name.toLowerCase().contains('reasoning') ||
              model.name.toLowerCase().contains('thinking') ||
              model.name.toLowerCase().contains('deepseek')) {
            score += 20;
            reasons.add('Designed for deep reasoning');
          }
          break;
        }
      }

      // === Budget scoring ===
      final inputPrice = model.inputPricePer1kTokens ?? 0.01;
      final outputPrice = model.outputPricePer1kTokens ?? 0.01;
      final avgPrice = (inputPrice + outputPrice) / 2;

      if (budgetPreference < 0.3) {
        // Budget-conscious
        if (avgPrice < 0.001) {
          score += 25;
          reasons.add('Very affordable pricing');
        } else if (avgPrice < 0.005) {
          score += 15;
          reasons.add('Reasonable pricing');
        } else {
          score += 5;
        }
      } else if (budgetPreference < 0.7) {
        // Balanced
        if (avgPrice < 0.001) {
          score += 20;
          reasons.add('Great value for capabilities');
        } else if (avgPrice < 0.01) {
          score += 15;
          reasons.add('Good balance of cost & quality');
        } else {
          score += 10;
        }
      } else {
        // Best quality
        if (avgPrice > 0.005) {
          score += 20;
          reasons.add('Premium model with top capabilities');
        } else {
          score += 10;
        }
        if (model.benchmarkScore != null) {
          score += 10;
        }
      }

      // === Context scoring ===
      if (contextLength == 'long' && model.contextWindow != null && model.contextWindow! >= 100000) {
        score += 20;
        reasons.add('Massive context window (${(model.contextWindow! / 1000).toStringAsFixed(0)}K tokens)');
      } else if (contextLength == 'medium' && model.contextWindow != null && model.contextWindow! >= 32000) {
        score += 15;
        reasons.add('Good context window (${(model.contextWindow! / 1000).toStringAsFixed(0)}K tokens)');
      } else if (contextLength == 'short') {
        score += 10; // All models handle short context
      }

      // === Bonus for well-rounded models ===
      if (model.supportsVision && model.supportsFunctionCalling) {
        score += 10;
        reasons.add('Versatile: vision + tool calling');
      }

      scored.add(ModelScore(model: model, score: score, reasons: reasons));
    }

    // Sort by score descending and return top 5
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(5).toList();
  }
}
