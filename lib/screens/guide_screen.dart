import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../app_colors.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});
  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school, color: AppColors.neonBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Text('AI GUIDE', style: GoogleFonts.orbitron(letterSpacing: 2)),
        ]),
        backgroundColor: AppColors.bgDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(Icons.auto_awesome, 'WHAT IS AI?', const Color(0xFF00B8FF)),
          const SizedBox(height: 8),
          _infoCard(
            'Artificial Intelligence is computer software that can understand and respond like a human.',
            Icons.psychology, const Color(0xFF00B8FF)),
          const SizedBox(height: 8),
          _infoCard(
            'Large Language Models like GPT-4o, Claude, and Gemini are trained on massive text data.',
            Icons.memory, const Color(0xFF7C4DFF)),
          const SizedBox(height: 24),

          _sectionHeader(Icons.vpn_key, 'GETTING AN API KEY', const Color(0xFFFF6D00)),
          const SizedBox(height: 8),
          _stepCard(1, 'Choose a provider', 'OpenAI, Anthropic, Google, or any listed in this app.', Icons.search, const Color(0xFFFF6D00)),
          const SizedBox(height: 8),
          _stepCard(2, 'Create an account', 'Sign up on their website. Most offer free credits.', Icons.person_add, const Color(0xFFFF6D00)),
          const SizedBox(height: 8),
          _stepCard(3, 'Find your API key', 'Go to API keys section in account settings and copy it.', Icons.key, const Color(0xFFFF6D00)),
          const SizedBox(height: 8),
          _stepCard(4, 'Enter it in the app', 'Settings > API Key > paste > DEPLOY CONFIG.', Icons.check, const Color(0xFF00FF88)),
          const SizedBox(height: 24),

          _sectionHeader(Icons.explore, 'USING THIS APP', const Color(0xFF00FF88)),
          const SizedBox(height: 8),
          _featureCard(Icons.compare_arrows, 'COMPARE MODELS', 'Browse 12+ AI models. Compare pricing, benchmarks, and features side-by-side.', const Color(0xFF00B8FF)),
          const SizedBox(height: 8),
          _featureCard(Icons.chat, 'AI CHAT', 'Connect your API key and chat with any supported model in real-time.', const Color(0xFF7C4DFF)),
          const SizedBox(height: 8),
          _featureCard(Icons.lightbulb, 'MODEL ADVISOR', 'Tell us your needs and budget. We recommend the best model.', const Color(0xFFFF6D00)),
          const SizedBox(height: 8),
          _featureCard(Icons.menu_book, 'AI GLOSSARY', 'Tap ? in Models screen to learn AI terms and concepts.', const Color(0xFFE040FB)),
          const SizedBox(height: 24),

          _sectionHeader(Icons.tips_and_updates, 'TIPS FOR BEGINNERS', const Color(0xFFFFA726)),
          const SizedBox(height: 8),
          _tipCard('Start with cheap models', 'GPT-4o Mini or Gemini Flash cost pennies and are great for learning.'),
          const SizedBox(height: 8),
          _tipCard('Be specific in prompts', 'Say "Write Python code to sort a list" instead of "Write code".'),
          const SizedBox(height: 8),
          _tipCard('Watch your context window', 'Models can only remember so much text. Use larger context for long documents.'),
          const SizedBox(height: 8),
          _tipCard('Monitor your costs', 'Input (your prompt) is cheaper than output (AI response). A typical chat costs less than a penny.'),
          const SizedBox(height: 8),
          _tipCard('Keep your API key safe', 'Never share your key. It is stored only on your device in this app.'),
          const SizedBox(height: 8),
          _tipCard('Try different models', 'GPT-4o for general, Claude for coding, Gemini for long documents. Use the Advisor to find your match.'),
          const SizedBox(height: 24),

          
          const SizedBox(height: 24),
          _sectionHeader(Icons.terminal, 'FOR DEVELOPERS', const Color(0xFF00FF88)),
          const SizedBox(height: 8),
          _infoCard('This app is built with Flutter and can be cloned, modified, and built from source.', Icons.code, const Color(0xFF00FF88)),
          const SizedBox(height: 24),
          _sectionHeader(Icons.download, '1. CLONE FROM GITHUB', const Color(0xFF00B8FF)),
          const SizedBox(height: 8),
          _stepCard(1, 'Install Git', 'Download from git-scm.com or run: sudo apt install git', Icons.download, const Color(0xFF00B8FF)),
          const SizedBox(height: 8),
          _stepCard(2, 'Clone the repo', 'git clone the repo, then cd into the folder', Icons.folder_open, const Color(0xFF00B8FF)),
          const SizedBox(height: 8),
          _stepCard(3, 'Open in VS Code', 'Run: code . from the project directory', Icons.code, const Color(0xFF00B8FF)),
          const SizedBox(height: 24),
          _sectionHeader(Icons.downloading, '2. INSTALL FLUTTER', const Color(0xFF7C4DFF)),
          const SizedBox(height: 8),
          _stepCard(1, 'Download Flutter SDK', 'Go to flutter.dev/downloads and get the stable release for your OS', Icons.download, const Color(0xFF7C4DFF)),
          const SizedBox(height: 8),
          _stepCard(2, 'Add to PATH', 'Add flutter/bin to your system PATH so you can run flutter commands', Icons.settings, const Color(0xFF7C4DFF)),
          const SizedBox(height: 8),
          _stepCard(3, 'Run flutter doctor', 'flutter doctor checks for Android SDK, Java, and connected devices', Icons.check_circle, const Color(0xFF7C4DFF)),
          const SizedBox(height: 8),
          _stepCard(4, 'Using pi (coding agent)', 'Run pi from your project directory to get AI-assisted coding help', Icons.smart_toy, const Color(0xFF7C4DFF)),
          const SizedBox(height: 24),
          _sectionHeader(Icons.android, '3. ANDROID SETUP', const Color(0xFFFF6D00)),
          const SizedBox(height: 8),
          _stepCard(1, 'Install Android Studio', 'Download from developer.android.com/studio and run the installer', Icons.download, const Color(0xFFFF6D00)),
          const SizedBox(height: 8),
          _stepCard(2, 'Accept SDK licenses', 'Run flutter doctor --android-licenses and accept all prompts', Icons.verified, const Color(0xFFFF6D00)),
          const SizedBox(height: 8),
          _stepCard(3, 'Build the APK', 'Run flutter build apk --release. Output goes to build/app/outputs/flutter-apk/', Icons.build, const Color(0xFFFF6D00)),
          const SizedBox(height: 8),
          _stepCard(4, 'Install on phone', 'Enable USB Debugging, connect USB, then run adb install', Icons.phone_android, const Color(0xFFFF6D00)),
          const SizedBox(height: 24),
          _sectionHeader(Icons.storage, '4. PROJECT STRUCTURE', const Color(0xFFE040FB)),
          const SizedBox(height: 8),
          _infoCard('The main app code is in lib/. Here is how it is organized:', Icons.folder, const Color(0xFFE040FB)),
          const SizedBox(height: 8),
          _devFileTree(),
          const SizedBox(height: 24),
          _sectionHeader(Icons.update, '5. BUILDING UPDATES', const Color(0xFF448AFF)),
          const SizedBox(height: 8),
          _stepCard(1, 'Make changes', 'Edit files in lib/ using VS Code, pi, or any editor', Icons.edit, const Color(0xFF448AFF)),
          const SizedBox(height: 8),
          _stepCard(2, 'Check for errors', 'Run: flutter analyze', Icons.search, const Color(0xFF448AFF)),
          const SizedBox(height: 8),
          _stepCard(3, 'Build new APK', 'Run flutter build apk --release. Update version in pubspec.yaml first', Icons.build, const Color(0xFF448AFF)),
          const SizedBox(height: 8),
          _stepCard(4, 'Share with friends', 'Upload APK to Google Drive, WeTransfer, or any file sharing service', Icons.share, const Color(0xFF448AFF)),
          const SizedBox(height: 32),
          _sectionHeader(Icons.link, 'USEFUL LINKS', const Color(0xFF448AFF)),
          const SizedBox(height: 8),
          _linkCard('OpenAI API Keys', 'https://platform.openai.com/api-keys'),
          const SizedBox(height: 8),
          _linkCard('Anthropic Console', 'https://console.anthropic.com'),
          const SizedBox(height: 8),
          _linkCard('Google AI Studio', 'https://makersuite.google.com/app/apikey'),
          const SizedBox(height: 8),
          _linkCard('OpenRouter Models', 'https://openrouter.ai/models'),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Text(title, style: GoogleFonts.orbitron(fontSize: 13, color: color, letterSpacing: 2)),
      const SizedBox(width: 10),
      Expanded(child: Container(height: 0.5, color: AppColors.borderSubtle)),
    ]);
  }

  Widget _infoCard(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.5))),
      ]),
    );
  }

  Widget _stepCard(int num, String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 28, height: 28, decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text('$num', style: GoogleFonts.orbitron(fontSize: 13, color: color, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.orbitron(fontSize: 13, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _featureCard(IconData icon, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.orbitron(fontSize: 12, color: AppColors.textPrimary, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _tipCard(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('💡', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.orbitron(fontSize: 12, color: AppColors.textPrimary, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
        ])),
      ]),
    );
  }

  Widget _linkCard(String title, String url) {
    return GestureDetector(
      onTap: () async { try { await launchUrlString(url, mode: LaunchMode.externalApplication); } catch (_) {} },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF448AFF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.link, color: Color(0xFF448AFF), size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.orbitron(fontSize: 12, color: AppColors.textPrimary, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(url, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.open_in_new, color: AppColors.textMuted, size: 16),
        ]),
      ),
    );
  }

  Widget _devFileTree() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _treeLine('lib/', true, const Color(0xFF00B8FF)),
        _treeLine('  main.dart', false, AppColors.textSecondary),
        _treeLine('  app_colors.dart', false, AppColors.textSecondary),
        _treeLine('  models/', true, const Color(0xFF7C4DFF)),
        _treeLine('    ai_model.dart', false, AppColors.textSecondary),
        _treeLine('  screens/', true, const Color(0xFFFF6D00)),
        _treeLine('    home_screen.dart', false, AppColors.textSecondary),
        _treeLine('    models_screen.dart', false, AppColors.textSecondary),
        _treeLine('    chat_screen.dart', false, AppColors.textSecondary),
        _treeLine('    settings_screen.dart', false, AppColors.textSecondary),
        _treeLine('    advisor_screen.dart', false, AppColors.textSecondary),
        _treeLine('    trends_screen.dart', false, AppColors.textSecondary),
        _treeLine('    compare_screen.dart', false, AppColors.textSecondary),
        _treeLine('    guide_screen.dart', false, AppColors.textSecondary),
        _treeLine('    onboarding_screen.dart', false, AppColors.textSecondary),
        _treeLine('  services/', true, const Color(0xFFE040FB)),
        _treeLine('    scraping_service.dart', false, AppColors.textSecondary),
        _treeLine('    api_service.dart', false, AppColors.textSecondary),
        _treeLine('    advisor_service.dart', false, AppColors.textSecondary),
        _treeLine('    trends_service.dart', false, AppColors.textSecondary),
        _treeLine('    glossary_service.dart', false, AppColors.textSecondary),
        _treeLine('    version_service.dart', false, AppColors.textSecondary),
        _treeLine('    onboarding_service.dart', false, AppColors.textSecondary),
        _treeLine('  widgets/', true, const Color(0xFFFFA726)),
        _treeLine('    tilt_card.dart', false, AppColors.textSecondary),
        _treeLine('    model_card.dart', false, AppColors.textSecondary),
        _treeLine('    scanline_overlay.dart', false, AppColors.textSecondary),
      ]),
    );
  }

  Widget _treeLine(String text, bool isFolder, Color color) {
    return Padding(
      padding: EdgeInsets.only(left: isFolder ? 0 : 16, bottom: 2),
      child: Row(children: [
        Icon(isFolder ? Icons.folder : Icons.insert_drive_file, size: 14, color: color),
        const SizedBox(width: 6),
        Text(text, style: GoogleFonts.inter(fontSize: 11, color: isFolder ? color : AppColors.textSecondary, fontWeight: isFolder ? FontWeight.w600 : FontWeight.normal)),
      ]),
    );
  }

  }
