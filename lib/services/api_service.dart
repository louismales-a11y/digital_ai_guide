import 'dart:convert';
import "package:flutter/foundation.dart";
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({required this.role, required this.content, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class ApiService extends ChangeNotifier {
  static const String _apiKeyKey = 'api_key';
  static const String _selectedModelKey = 'selected_model';
  static const String _baseUrlKey = 'api_base_url';

  String? _apiKey;
  String _selectedModel = 'gpt-4o';
  String _baseUrl = 'https://api.openai.com/v1';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_apiKeyKey);
    _selectedModel = prefs.getString(_selectedModelKey) ?? 'gpt-4o';
    _baseUrl = prefs.getString(_baseUrlKey) ?? 'https://api.openai.com/v1';
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, key); notifyListeners();
  }

  Future<void> setSelectedModel(String model) async {
    _selectedModel = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModelKey, model); notifyListeners();
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url); notifyListeners();
  }

  String? get apiKey => _apiKey;
  String get selectedModel => _selectedModel;
  String get baseUrl => _baseUrl;

  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Future<String> sendMessage({
    required List<ChatMessage> messages,
    void Function(String chunk)? onStream,
  }) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('API key not set. Please add your API key in Settings.');
    }

    final uri = Uri.parse('$_baseUrl/chat/completions');
    
    final body = {
      'model': _selectedModel,
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': onStream != null,
      'max_tokens': 4096,
      'temperature': 0.7,
    };

    if (onStream != null) {
      // Streaming request
      final request = http.Request('POST', uri)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        })
        ..body = jsonEncode(body);

      final response = await http.Client().send(request);
      
      if (response.statusCode != 200) {
        final error = await response.stream.bytesToString();
        throw Exception('API Error (${response.statusCode}): $error');
      }

      final completer = Completer<String>();
      final buffer = StringBuffer();

      response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          (line) {
            if (line.startsWith('data: ')) {
              final data = line.substring(6).trim();
              if (data == '[DONE]') {
                if (!completer.isCompleted) {
                  completer.complete(buffer.toString());
                }
                return;
              }
              try {
                final json = jsonDecode(data);
                final choices = json['choices'] as List?;
                if (choices != null && choices.isNotEmpty) {
                  final delta = choices[0]['delta'] as Map<String, dynamic>?;
                  final content = delta?['content'] as String?;
                  if (content != null) {
                    buffer.write(content);
                    onStream(content);
                  }
                }
              } catch (_) {}
            }
          },
          onError: (error) {
            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
          onDone: () {
            if (!completer.isCompleted) {
              completer.complete(buffer.toString());
            }
          },
        );

      return completer.future;
    } else {
      // Non-streaming request
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('API Error (${response.statusCode}): ${response.body}');
      }

      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    }
  }
}
