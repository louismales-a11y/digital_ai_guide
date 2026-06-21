import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchResult {
  final String title;
  final String snippet;
  final String url;
  SearchResult({required this.title, required this.snippet, required this.url});
}

class WebSearchService {
  static Future<List<SearchResult>> search(String query) async {
    try {
      // Try DuckDuckGo instant answer API (free, no key)
      final response = await http.get(
        Uri.parse('https://api.duckduckgo.com/?q=${Uri.encodeComponent(query)}&format=json&no_html=1'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = <SearchResult>[];
        
        // Abstract answer
        if (data['AbstractText'] != null && data['AbstractText'].toString().isNotEmpty) {
          results.add(SearchResult(
            title: data['AbstractSource']?.toString() ?? 'Summary',
            snippet: data['AbstractText'].toString(),
            url: data['AbstractURL']?.toString() ?? '',
          ));
        }
        
        // Related topics
        final topics = data['RelatedTopics'] as List? ?? [];
        for (final topic in topics.take(5)) {
          final text = topic['Text']?.toString() ?? '';
          final url = topic['FirstURL']?.toString() ?? '';
          if (text.isNotEmpty && url.isNotEmpty) {
            results.add(SearchResult(
              title: text.split(' - ').first,
              snippet: text,
              url: url,
            ));
          }
        }
        
        if (results.isNotEmpty) return results;
      }
    } catch (_) {}
    return [];
  }
}
