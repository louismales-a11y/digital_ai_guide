import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Central version tracking for Digital AI Guide
class AppVersion {
  /// Current app version (from pubspec.yaml)
  static const String version = '1.18.13';
  static const int buildNumber = 58;
  
  /// Human-readable version label
  static const String label = 'v$version (build $buildNumber)';
  
  /// List of changes per version
  static const Map<String, String> changelog = {
    '1.0.0': 'Initial Flutter scaffold',
    '1.1.0': 'Futuristic cyberpunk theme (black + blue + red)',
    '1.2.0': 'CRT scanline overlay with analog noise',
    '1.3.0': 'Release build with signing config',
    '1.4.0': '3D TiltCard effects on all cards',
    '1.4.1': 'Fixed layout overflow in header (FittedBox + compact settings button',
    '1.4.2': 'Full layout audit - fixed overflow on all screens (AppBars, cards, chips)',
    '1.5.0': 'MORE button on model cards linking to official AI provider websites',
    '1.6.0': 'BENEFITS button with detailed modal: strengths, weaknesses, and user reviews with star ratings',
    '1.6.1': 'Improved ACCESS DENIED dialog with direct GO TO SETTINGS button + clearer message',
    '1.7.0': 'New: Model Advisor (smart model recommendations) + Market Trends (AI industry news feed) — both fully functional',
  };

  /// Get the latest changes description
  static String get latestChanges {
    final entries = changelog.entries.toList();
    return entries.reversed.take(3).map((e) => '${e.key}: ${e.value}').join('\n');
  }

  AppVersion._();
}
