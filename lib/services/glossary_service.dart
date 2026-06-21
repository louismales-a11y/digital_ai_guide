import "package:flutter/material.dart";
class AITerm {
  final String term;
  final String definition;
  final String? example;
  final IconData icon;

  AITerm({required this.term, required this.definition, this.example, required this.icon});
}

class GlossaryService {
  static final List<AITerm> terms = [
    AITerm(term: 'MMLU', icon: Icons.analytics,
      definition: 'Massive Multitask Language Understanding — a benchmark that tests AI models on 57 subjects including math, law, medicine, and history. Higher scores (0-100%) indicate broader knowledge.',
      example: 'GPT-4o scores 88.7%, meaning it correctly answered ~89% of test questions across all subjects.'),
    AITerm(term: 'Context Window', icon: Icons.auto_stories,
      definition: 'The maximum amount of text (in tokens) a model can remember at once. Larger context = can process longer documents, books, or conversations in one go.',
      example: '1M tokens = roughly 750,000 words or 3 full-length novels in a single prompt.'),
    AITerm(term: 'Token', icon: Icons.code,
      definition: 'The basic unit of text that AI models read and write. A token is roughly 0.75 words (English). Models are priced per 1,000 tokens (1K) or 1,000,000 tokens (1M).',
      example: '"Hello world" = 2 tokens. "Digital AI Guide" = 4 tokens.'),
    AITerm(term: 'Input Price', icon: Icons.attach_money,
      definition: 'Cost per 1,000 tokens for text you send to the AI (your prompt, questions, instructions). Usually cheaper than output price.'),
    AITerm(term: 'Output Price', icon: Icons.attach_money,
      definition: 'Cost per 1,000 tokens for text the AI generates back to you (responses, code, analysis). Usually 2-4x the input price.'),
    AITerm(term: 'Vision / Multimodal', icon: Icons.image,
      definition: 'Ability to understand images, photos, diagrams, and documents alongside text. Models with vision can analyze charts, read handwriting, and describe photos.'),
    AITerm(term: 'Function Calling', icon: Icons.functions,
      definition: 'Allows AI models to call external tools and APIs — like searching the web, running code, or querying databases. Essential for building AI applications.'),
    AITerm(term: 'Streaming', icon: Icons.stream,
      definition: 'Receiving AI responses word-by-word as they are generated (like watching someone type), instead of waiting for the complete response. Makes chat feel faster and more natural.'),
    AITerm(term: 'Fine-tuning', icon: Icons.tune,
      definition: 'Training a pre-existing AI model on your own data to specialize it for specific tasks. Like taking a general doctor and making them a dermatology expert.'),
    AITerm(term: 'RAG', icon: Icons.api,
      definition: 'Retrieval-Augmented Generation — a technique where the AI searches your documents first, then answers based on what it found. Reduces hallucinations and grounds answers in your data.'),
    AITerm(term: 'BE (Benchmark)', icon: Icons.leaderboard,
      definition: 'Standardized tests used to compare AI model performance. Common benchmarks include MMLU (knowledge), HumanEval (coding), and GSM8K (math reasoning).'),
    AITerm(term: 'Open Source', icon: Icons.code_off,
      definition: 'Models with publicly available weights that anyone can download, run, and modify. Llama 3.1 is open-source. GPT-4o and Claude are closed-source (proprietary).'),
  ];

  static AITerm? find(String query) {
    final lower = query.toLowerCase();
    return terms.where((t) => t.term.toLowerCase().contains(lower) || t.definition.toLowerCase().contains(lower)).firstOrNull;
  }
}
