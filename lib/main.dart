import "app_colors.dart";
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'widgets/scanline_overlay.dart';
import 'services/update_service.dart';
import 'services/version_service.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ApiService()..initialize(),
      child: const DigitalAIGuideApp(),
    ),
  );
  _checkForUpdates();
}

Future<void> _checkForUpdates() async {
  final update = await UpdateService.checkForUpdate();
  if (update != null && update.isNewer) {
    // Wait a moment for the app to render, then show dialog
    await Future.delayed(const Duration(seconds: 2));
    if (_navigatorKey.currentContext != null) {
      _showUpdateDialog(_navigatorKey.currentContext!, update);
    }
  }
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

void _showUpdateDialog(BuildContext context, UpdateInfo update) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF12121A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF1E1E30)),
      ),
      title: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00B8FF), Color(0xFF0088FF)]),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.system_update, color: Colors.black, size: 22),
        ),
        const SizedBox(width: 12),
        Text("UPDATE AVAILABLE", style: GoogleFonts.orbitron(color: Color(0xFF00B8FF), fontSize: 16, letterSpacing: 1)),
      ]),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Version ${update.latestVersion} is available", style: GoogleFonts.orbitron(fontSize: 14, color: Colors.white, letterSpacing: 0.5)),
        Text("You have v${AppVersion.version} (build ${AppVersion.buildNumber})", style: GoogleFonts.inter(fontSize: 11, color: Color(0xFF8888AA))),
        if (update.releaseNotes.isNotEmpty) ...[const SizedBox(height: 12), Text("What's new:", style: GoogleFonts.orbitron(fontSize: 11, color: Color(0xFF7C4DFF), letterSpacing: 1)), const SizedBox(height: 6), Text(update.releaseNotes, style: GoogleFonts.inter(fontSize: 12, color: Color(0xFF8888AA), height: 1.4))],
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text("LATER", style: GoogleFonts.orbitron(color: Color(0xFF555577), fontSize: 11, letterSpacing: 2)),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00B8FF), Color(0xFF0088FF)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (update.downloadUrl.isNotEmpty) {
                try { await launchUrlString(update.downloadUrl, mode: LaunchMode.externalApplication); } catch (_) {}
              }
            },
            child: Text("UPDATE", style: GoogleFonts.orbitron(color: Colors.black, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    ),
  );
}

class DigitalAIGuideApp extends StatelessWidget {
  const DigitalAIGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScanlineOverlay(
      opacity: 0.015,
      lineThickness: 1.0,
      lineSpacing: 4.0,
      showNoise: false,
      showVignette: true,
      child: _App(),
    );
  }
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Digital AI Guide',
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.light,
      home: const HomeScreen(),
      builder: (context, child) {
        return SafeArea(child: child!);
      },
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.neonBlue,
        secondary: AppColors.neonRed,
        surface: AppColors.bgCard,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.orbitronTextTheme().copyWith(
        bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSecondary),
        bodySmall: GoogleFonts.inter(color: AppColors.textMuted),
        headlineLarge: GoogleFonts.orbitron(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.orbitron(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.orbitron(color: AppColors.textPrimary),
        titleMedium: GoogleFonts.poppins(color: AppColors.textPrimary),
        labelLarge: GoogleFonts.inter(color: AppColors.textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.neonBlue,
        ),
        iconTheme: const IconThemeData(color: AppColors.neonBlue),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgCardHover,
        selectedColor: AppColors.neonBlue.withOpacity(0.2),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
        side: const BorderSide(color: AppColors.borderSubtle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neonBlue, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonBlue,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      useMaterial3: true,
    );
  }
}
