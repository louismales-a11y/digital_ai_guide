import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../services/api_service.dart';
import '../widgets/tilt_card.dart';

import '../screens/advisor_screen.dart';
import '../screens/trends_screen.dart';
import '../screens/guide_screen.dart';
import '../services/glossary_service.dart';
import '../services/version_service.dart';
import 'models_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // 3D Depth Header
            _buildHeader(),
            const SizedBox(height: 20),
            // Quick Action Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildActionCard(
                      icon: Icons.compare_arrows,
                      title: 'MODEL COMPARISON',
                      subtitle: 'Analyze pricing, benchmarks & capabilities across all AIs',
                      glowColor: const Color(0xFF00B8FF),
                      onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const ModelsScreen()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildActionCard(
                      icon: Icons.chat_bubble_outline,
                      title: 'AI CHAT INTERFACE',
                      subtitle: 'Connect to any model with your API key and chat',
                      glowColor: const Color(0xFF7C4DFF),
                      onTap: () {
                        final api = Provider.of<ApiService>(context, listen: false);
                        Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const ChatScreen()),
                          );
                      },
                    ),
                    const SizedBox(height: 14),
                    _buildActionCard(
                      icon: Icons.trending_up,
                      title: 'MARKET TRENDS',
                      subtitle: 'Real-time AI industry pricing shifts & intelligence',
                      glowColor: const Color(0xFFFF1744),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrendsScreen())),
                    ),
                    const SizedBox(height: 14),
                    _buildActionCard(
                      icon: Icons.lightbulb_outline,
                      title: 'MODEL ADVISOR',
                      subtitle: 'Neural matchmaking - find your ideal AI model',
                      glowColor: const Color(0xFFFF6D00),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvisorScreen())),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFBBDEFB),
            Color(0xFFE3F2FD),
            Color(0xFFBBDEFB),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFF00B8FF), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 3D icon with depth shadow + floating effect
              TiltCard(
                tiltAngle: 15,
                elevation: 15,
                depth: 30,
                borderRadius: 12,
                shadowColor: const Color(0xFF00B8FF),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B8FF), Color(0xFF0088FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset("assets/logo.png", width: 28, height: 28, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DIGITAL AI GUIDE',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00B8FF),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppVersion.label + ' - NEURAL CORE',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Popup menu
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                color: AppColors.bgCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF1E1E30)),
                ),
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF1E1E30)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.more_vert, color: Color(0xFF00B8FF), size: 20),
                ),
                onSelected: (value) {
                  switch (value) {
                    case "settings":
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      break;
                    case "guide":
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideScreen()));
                      break;
                    case "glossary":
                      _showGlossary(context);
                      break;
                    case "about":
                      _showAboutDialog(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: "settings", child: Row(children: [
                    Icon(Icons.settings, color: Color(0xFF00B8FF), size: 18),
                    const SizedBox(width: 10),
                    Text("Settings", style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
                  ])),
                  PopupMenuItem(value: "guide", child: Row(children: [
                    Icon(Icons.school, color: Color(0xFF7C4DFF), size: 18),
                    const SizedBox(width: 10),
                    Text("Getting Started", style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
                  ])),
                  PopupMenuItem(value: "glossary", child: Row(children: [
                    Icon(Icons.menu_book, color: Color(0xFFE040FB), size: 18),
                    const SizedBox(width: 10),
                    Text("AI Glossary", style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
                  ])),
                  PopupMenuItem(value: "about", child: Row(children: [
                    Icon(Icons.info_outline, color: Color(0xFF00FF88), size: 18),
                    const SizedBox(width: 10),
                    Text("About App", style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14)),
                  ])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Status line with 3D dots
          Row(
            children: [
              // 3D glowing dot
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF88).withOpacity(0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: const Color(0xFF00FF88).withOpacity(0.2),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SYSTEM ONLINE // READY',
                style: GoogleFonts.inter(
                  fontSize: 10, color: AppColors.textSecondary, letterSpacing: 2),
              ),
              const Spacer(),
              Text(
                'CONNECTED',
                style: GoogleFonts.inter(
                  fontSize: 10, color: const Color(0xFF00FF88).withOpacity(0.6), letterSpacing: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return TiltCard(
        tiltAngle: 10,
        elevation: 10,
        depth: 25,
        borderRadius: 14,
        shadowColor: glowColor,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E1E30), width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: glowColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: glowColor.withOpacity(0.2), width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.05),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(icon, color: glowColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                      style: GoogleFonts.orbitron(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary, letterSpacing: 1.5)),
                    const SizedBox(height: 5),
                    Text(subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(color: glowColor.withOpacity(0.2), width: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.chevron_right, color: glowColor.withOpacity(0.5), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }



  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
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
            child: const Icon(Icons.auto_awesome, color: Colors.black, size: 22),
          ),
          const SizedBox(width: 12),
          Text('ABOUT', style: GoogleFonts.orbitron(color: Color(0xFF00B8FF), fontSize: 18, letterSpacing: 2)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Digital AI Guide', style: GoogleFonts.orbitron(fontSize: 16, color: Colors.white, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(AppVersion.label, style: GoogleFonts.inter(fontSize: 12, color: Color(0xFF8888AA))),
          const SizedBox(height: 4),
          Text('Released June 2026', style: GoogleFonts.inter(fontSize: 11, color: Color(0xFF555577))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0A0A0F), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.person, size: 14, color: Color(0xFF00B8FF)),
              const SizedBox(width: 6),
              Expanded(child: Text('Created by LittleLouis aka Louis Males', style: GoogleFonts.inter(fontSize: 11, color: Color(0xFFCCCCDD)))),
            ]),
          ),
          const SizedBox(height: 12),
          Text('Built with:', style: GoogleFonts.orbitron(fontSize: 11, color: Color(0xFF7C4DFF), letterSpacing: 1)),
          const SizedBox(height: 8),
          _toolRow(Icons.code, 'Flutter 3.44.2 (Dart 3.12.2)'),
          const SizedBox(height: 4),
          _toolRow(Icons.android, 'Android SDK 36'),
          const SizedBox(height: 4),
          _toolRow(Icons.auto_awesome, 'OpenRouter.ai API'),
          const SizedBox(height: 4),
          _toolRow(Icons.terminal, 'pi Coding Agent'),
          const SizedBox(height: 4),
          _toolRow(Icons.code_off, 'Visual Studio Code'),
          const SizedBox(height: 4),
          _toolRow(Icons.storage, 'SharedPreferences (local data)'),
          const SizedBox(height: 4),
          _toolRow(Icons.cloud, 'GitHub (source hosting)'),
          const SizedBox(height: 12),
          Text('Description:', style: GoogleFonts.orbitron(fontSize: 11, color: Color(0xFF7C4DFF), letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('A futuristic cyberpunk AI model comparison and chat app. Browse 12+ AI models, compare pricing and benchmarks, chat with your API key, and get smart recommendations.',
            style: GoogleFonts.inter(fontSize: 12, color: Color(0xFF8888AA), height: 1.4)),
        ]),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00B8FF).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CLOSE', style: GoogleFonts.orbitron(color: Color(0xFF00B8FF), fontSize: 11, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }




  void _showGlossary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFF0F0F1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Color(0xFF1E1E30))),
        ),
        child: Column(children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.menu_book, color: Colors.blue, size: 18)),
              const SizedBox(width: 12),
              Text('AI GLOSSARY', style: GoogleFonts.orbitron(fontSize: 16, color: Colors.blue, letterSpacing: 2)),
            ]),
          ),
          const Divider(color: Color(0xFF1E1E30), height: 1),
          Expanded(child: ListView(
            padding: const EdgeInsets.all(16),
            children: GlossaryService.terms.map((term) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF12121A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E1E30))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(term.icon, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(term.term, style: GoogleFonts.orbitron(fontSize: 13, color: Colors.white, letterSpacing: 1)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _copyTerm(term.term, term.definition),
                    child: Icon(Icons.copy, size: 14, color: Colors.grey),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(term.definition, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8888AA), height: 1.4)),
                if (term.example != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.withOpacity(0.1))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.lightbulb, size: 12, color: Colors.blue),
                      const SizedBox(width: 6),
                      Expanded(child: Text(term.example!, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFAAAAAA), height: 1.3))),
                    ]),
                  ),
                ],
              ]),
            )).toList(),
          )),
        ]),
      ),
    );
  }

  void _copyTerm(String term, String def) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: const Color(0xFF00FF88),
      duration: const Duration(seconds: 1),
      content: Text('$term definition info', style: GoogleFonts.inter(fontSize: 12, color: Colors.black)),
    ));
  }




  Widget _toolRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 12, color: Color(0xFF555577)),
      const SizedBox(width: 6),
      Text(text, style: GoogleFonts.inter(fontSize: 11, color: Color(0xFF8888AA))),
    ]);
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E1E30)),
        ),
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF1744).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFF1744).withOpacity(0.3)),
            ),
            child: const Icon(Icons.lock, color: Color(0xFFFF1744), size: 18),
          ),
          const SizedBox(width: 10),
          Text('ACCESS DENIED', style: GoogleFonts.orbitron(
            color: const Color(0xFFFF1744), fontSize: 16, letterSpacing: 1)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('No API key detected.', style: GoogleFonts.inter(
            color: const Color(0xFFCCCCDD), fontSize: 14)),
          const SizedBox(height: 8),
          Text('To use AI Chat, you need to enter your API key in Settings first.',
            style: GoogleFonts.inter(color: const Color(0xFF8888AA), fontSize: 13, height: 1.4)),
          const SizedBox(height: 4),
          Text('Your key stays stored locally on your device.',
            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
        ]),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF1E1E30)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CANCEL', style: GoogleFonts.orbitron(
                color: AppColors.textSecondary, fontSize: 11, letterSpacing: 2)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00B8FF), Color(0xFF0088FF)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
              child: Text('GO TO SETTINGS', style: GoogleFonts.orbitron(
                color: Colors.black, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }


  void _showDialog(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E1E30)),
        ),
        title: Text(title, style: GoogleFonts.orbitron(
          color: const Color(0xFF00B8FF), fontSize: 16, letterSpacing: 1)),
        content: Text(msg, style: GoogleFonts.inter(
          color: const Color(0xFF8888AA), fontSize: 13)),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00B8FF).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('ACKNOWLEDGED',
                style: GoogleFonts.orbitron(
                  color: const Color(0xFF00B8FF), fontSize: 11, letterSpacing: 2)),
            ),
          ),
        ],
      ),
    );
  }
}
