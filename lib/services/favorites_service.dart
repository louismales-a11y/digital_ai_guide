import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _key = 'favorite_models';

  static Future<Set<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  static Future<void> toggleFavorite(String modelName) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (list.contains(modelName)) {
      list.remove(modelName);
    } else {
      list.add(modelName);
    }
    await prefs.setStringList(_key, list);
  }

  static Future<bool> isFavorite(String modelName) async {
    final favs = await getFavorites();
    return favs.contains(modelName);
  }
}
