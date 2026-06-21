import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_colors.dart';
import '../services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  final Widget home;
  const OnboardingScreen({super.key, required this.home});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const String _onboardingKey = 'onboarding_complete';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_onboardingKey) ?? false);
  }

  static Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      icon: Icons.auto_awesome,
      title: 'WELCOME TO\nDIGITAL AI GUIDE',
      desc: 'Your neural interface to the world of AI models.\nCompare, chat, and discover the perfect AI for\nany task — all in one place.',
      color: const Color(0xFF00B8FF),
    ),
    _OnboardPage(
      icon: Icons.compare_arrows,
      title: 'COMPARE MODELS',
      desc: 'Browse 12+ AI models with real pricing,\nbenchmark scores, context windows, and\nstrengths. Tap BENEFITS for detailed\nanalysis with user reviews.',
      color: const Color(0xFF7C4DFF),
    ),
    _OnboardPage(
      icon: Icons.chat_bubble_outline,
      title: 'AI CHAT',
      desc: 'Connect your API key and chat with any\nsupported model. Streaming responses,\nmodel switching, and full conversation\nhistory.',
      color: const Color(0xFF00C853),
    ),
    _OnboardPage(
      icon: Icons.trending_up,
      title: 'DISCOVER & LEARN',
      desc: 'Use Model Advisor to find the right AI for\nyour needs. Follow Market Trends for the\nlatest industry updates. Tap any term\nfor a helpful explanation.',
      color: const Color(0xFFFF6B6B),
    ),
  ];

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () async {
                    await markOnboardingComplete();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => widget.home));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderSubtle),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('SKIP', style: GoogleFonts.orbitron(
                      fontSize: 10, color: AppColors.textMuted, letterSpacing: 2)),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _pages.map((p) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: p.color.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(color: p.color.withOpacity(0.2)),
                          boxShadow: [BoxShadow(
                            color: p.color.withOpacity(0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )],
                        ),
                        child: Icon(p.icon, color: p.color, size: 56),
                      ),
                      const SizedBox(height: 32),
                      Text(p.title, style: GoogleFonts.orbitron(
                        fontSize: 20, fontWeight: FontWeight.bold,
                        color: Colors.white, letterSpacing: 1, height: 1.3),
                        textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text(p.desc, style: GoogleFonts.inter(
                        fontSize: 14, color: const Color(0xFF8888AA),
                        height: 1.5), textAlign: TextAlign.center),
                    ],
                  ),
                )).toList(),
              ),
            ),

            // Dots + Get Started
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                // Dot indicators
                Row(mainAxisAlignment: MainAxisAlignment.center, children:
                  List.generate(_pages.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? _pages[_page].color : AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const SizedBox(height: 24),
                // Button
                SizedBox(width: double.infinity, height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_pages[_page].color, _pages[_page].color.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(
                        color: _pages[_page].color.withOpacity(0.3),
                        blurRadius: 12,
                      )],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_page < _pages.length - 1) {
                          _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                        } else {
                          await markComplete();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => widget.home));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        _page < _pages.length - 1 ? 'NEXT' : 'GET STARTED',
                        style: GoogleFonts.orbitron(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: Colors.black, letterSpacing: 2),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  _OnboardPage({required this.icon, required this.title, required this.desc, required this.color});
}
