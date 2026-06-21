import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class FreeChatService {
  static final List<String> _jokes = [
    "Why did the AI break up with its girlfriend? It had too many emotional layers!",
    "What's an AI's favorite music? Anything with good algorithms!",
    "Why don't AI's ever get lost? They always follow their neural networks!",
    "What did the AI say when it learned to code? 'This is not a bug, it's a feature!'",
    "Why was the AI bad at poker? It couldn't hide its tells from the training data!",
  ];

  static final List<String> _encouragements = [
    "Great question! I'm here to help. If you want more detailed responses, add your own API key in Settings - it unlocks access to GPT-4o, Claude, and other premium models.",
    "Thanks for trying the free AI! For faster, more accurate responses with the latest models, consider adding your own API key in Settings.",
    "I'm running on a free tier right now. For the best experience with streaming responses and model selection, add your API key in the Settings menu.",
    "Free AI mode active! To unlock the full power of models like GPT-4o and Claude, just add your API key in Settings anytime.",
  ];

  static Future<String> getResponse(String message) async {
    // Try multiple free API endpoints
    final errors = <String>[];
    
    // Try 1: Hugging Face
    try {
      final response = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/google/flan-t5-base'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'inputs': message}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final text = data[0]['generated_text'] as String? ?? '';
          if (text.isNotEmpty) return text;
        }
      }
      errors.add('HuggingFace: ${response.statusCode}');
    } catch (e) {
      errors.add('HF: ${e.toString().substring(0, 30)}');
    }

    // Try 2: Use a simpler approach - return helpful info
    final lower = message.toLowerCase();
    
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return "Hello! Welcome to Digital AI Guide. I'm the free built-in AI assistant. How can I help you today?\n\n💡 Tip: Add your own API key in Settings to unlock GPT-4o, Claude, and other premium models with faster responses!";
    }
    
    if (lower.contains('who are you') || lower.contains('what are you')) {
      return "I'm the free built-in AI assistant for Digital AI Guide! I can help answer questions, but I'm limited compared to the full models. For the best experience, add your API key in Settings to use GPT-4o, Claude, or any model you prefer.";
    }
    
    if (lower.contains('thank') || lower.contains('thanks')) {
      return "You're welcome! 😊 Let me know if you need anything else. And remember, for even better responses, you can add your API key in Settings anytime!";
    }

    // Default: give a helpful response with a random encouragement
    final random = Random();
    final encouragement = _encouragements[random.nextInt(_encouragements.length)];
    return "I received your message, but the free AI server is currently unavailable. I can only provide basic responses right now.\n\n$encouragement";
  }
}
