import 'dart:convert';
import 'package:http/http.dart' as http;
import 'version_service.dart';

class UpdateInfo {
  final String latestVersion;
  final int latestBuild;
  final String downloadUrl;
  final String releaseNotes;

  UpdateInfo({
    required this.latestVersion,
    required this.latestBuild,
    required this.downloadUrl,
    required this.releaseNotes,
  });

  bool get isNewer {
    final parts = latestVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = AppVersion.version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < 3; i++) {
      final remote = i < parts.length ? parts[i] : 0;
      final current = i < currentParts.length ? currentParts[i] : 0;
      if (remote > current) return true;
      if (remote < current) return false;
    }
    return latestBuild > AppVersion.buildNumber;
  }
}

class UpdateService {
  static const String _versionUrl =
      'https://raw.githubusercontent.com/YOUR_USERNAME/digital_ai_guide/main/version.json';

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(_versionUrl),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UpdateInfo(
          latestVersion: data['latestVersion'] as String? ?? AppVersion.version,
          latestBuild: data['latestBuild'] as int? ?? AppVersion.buildNumber,
          downloadUrl: data['downloadUrl'] as String? ?? '',
          releaseNotes: data['releaseNotes'] as String? ?? '',
        );
      }
    } catch (_) {}
    return null;
  }
}
