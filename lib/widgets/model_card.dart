import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../app_colors.dart';
import '../models/ai_model.dart';
import '../screens/compare_screen.dart';
import '../services/favorites_service.dart';
import 'tilt_card.dart';

class ModelCard extends StatelessWidget {
  final AIModel model;
  const ModelCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final pc = _getColor(model.provider);
    return TiltCard(tiltAngle: 8, elevation: 12, depth: 20, borderRadius: 14, shadowColor: pc,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.bgCard, AppColors.bgCard.withValues(alpha: 0.95), const Color(0xFF0E0E18)]),
          borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderSubtle, width: 0.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: pc.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: pc.withOpacity(0.2))), child: Icon(Icons.memory, color: pc, size: 20)),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                FavoritesService.toggleFavorite(model.name);
              },
              child: FutureBuilder<bool>(
                future: FavoritesService.isFavorite(model.name),
                builder: (ctx, snap) => Icon(
                  snap.data == true ? Icons.star : Icons.star_border,
                  size: 16, color: Color(0xFFFFA726)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(model.name, style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: 0.5), overflow: TextOverflow.ellipsis, maxLines: 1),
              Text(model.provider, style: GoogleFonts.inter(fontSize: 11, color: pc, letterSpacing: 1)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(border: Border.all(color: pc.withOpacity(0.2)), borderRadius: BorderRadius.circular(4)), child: Text(model.category.toUpperCase(), style: GoogleFonts.orbitron(fontSize: 8, color: pc, letterSpacing: 1.5))),
          ]),
          const SizedBox(height: 12),
          Text(model.description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Wrap(spacing: 6, runSpacing: 6, children: model.strengthsList.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.bgCardHover, borderRadius: BorderRadius.circular(4), border: Border.all(color: AppColors.borderSubtle)), child: Text(s, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)))).toList()),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.attach_money, size: 14, color: AppColors.neonBlue), const SizedBox(width: 4),
            Expanded(child: Text(model.priceDisplay, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis, maxLines: 1)),
            if (model.contextWindow != null) ...[const SizedBox(width: 8), Icon(Icons.auto_stories, size: 14, color: Color(0xFF7C4DFF)), const SizedBox(width: 4), Text(model.contextWindow.toString() + "K", style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted))],
          ]),
          if (model.benchmarkScore != null) ...[const SizedBox(height: 8), Row(children: [Icon(Icons.analytics, size: 14, color: Color(0xFFFF6D00)), const SizedBox(width: 4), Text(model.benchmarkScore!, style: GoogleFonts.inter(fontSize: 11, color: Color(0xFFFF6D00)))])],
          const SizedBox(height: 10),
          Row(children: [
            if (model.supportsVision) _chip(Icons.image, "VISION"),
            if (model.supportsFunctionCalling) _chip(Icons.functions, "TOOLS"),
            if (model.supportsStreaming) _chip(Icons.stream, "STREAM"),
          ]),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _btn(Icons.arrow_upward, "BENEFITS", AppColors.electricPurple, () => _showBenefits(context, model)),
            const SizedBox(width: 8),
            _btn(Icons.compare_arrows, "COMPARE", Color(0xFF00FF88), () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompareScreen(initialModel: model)))),
            const SizedBox(width: 8),
            _btn(Icons.open_in_new, "MORE", pc, () => _launchUrl(model.displayUrl)),
          ]),
        ]),
      ),
    );
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: label == "MORE" ? const EdgeInsets.symmetric(horizontal: 14, vertical: 6) : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.3)), borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (label != "MORE") Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.orbitron(fontSize: label == "MORE" ? 9 : 8, color: color, letterSpacing: label == "MORE" ? 2 : 1.5)),
          if (label == "MORE") ...[const SizedBox(width: 6), Icon(Icons.open_in_new, size: 12, color: color)],
        ]),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Padding(padding: const EdgeInsets.only(right: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.electricPurple), const SizedBox(width: 3),
      Text(label, style: GoogleFonts.orbitron(fontSize: 8, color: AppColors.textMuted, letterSpacing: 1)),
    ]));
  }

  void _showBenefits(BuildContext context, AIModel m) {
    final pc = _getColor(m.provider);
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: const BoxDecoration(color: Color(0xFF0F0F1A), borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: Color(0xFF1E1E30)))),
        child: Column(children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: pc.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: pc.withOpacity(0.2))), child: Icon(Icons.memory, color: pc, size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.name, style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
              Text(m.provider, style: GoogleFonts.inter(fontSize: 12, color: pc)),
            ])),
          ])),
          const SizedBox(height: 8), const Divider(color: Color(0xFF1E1E30), height: 1),
          Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
            if (m.bestFor != null) _ic(Icons.star, "BEST FOR", m.bestFor!, Color(0xFFFFA726)),
            if (m.speed != null) _ic(Icons.speed, "SPEED", m.speed!, Color(0xFF00B8FF)),
            if (m.languages != null) _ic(Icons.language, "LANGUAGES", m.languages!, Color(0xFF7C4DFF)),
            if (m.inputPricePer1kTokens != null || m.outputPricePer1kTokens != null) _ic(Icons.attach_money, "PRICING", m.priceDisplay, Color(0xFF00C853)),
            if (m.easeOfUse != null) _ic(Icons.sentiment_satisfied, "EASE OF USE", m.easeOfUse!, Color(0xFFFFA726)),
            const SizedBox(height: 16),
            _sec(Icons.arrow_upward, "STRENGTHS", Color(0xFF00FF88), m.strengthsList),
            const SizedBox(height: 20),
            if (m.weaknesses.isNotEmpty) _sec(Icons.arrow_downward, "WEAKNESSES", Color(0xFFFF1744), m.weaknesses),
            if (m.weaknesses.isNotEmpty) const SizedBox(height: 20),
            if (m.reviews.isNotEmpty) ...[
              Row(children: [Icon(Icons.star, size: 16, color: Color(0xFFFFA726)), const SizedBox(width: 6), Text("USER REVIEWS", style: GoogleFonts.orbitron(fontSize: 11, color: Color(0xFFFFA726), letterSpacing: 2)), const SizedBox(width: 10), Expanded(child: Container(height: 0.5, color: Color(0xFF1E1E30)))]),
              const SizedBox(height: 12),
              ...m.reviews.map((r) => _rc(r, pc)),
            ],
          ])),
        ]),
      ),
    );
  }

  Widget _ic(IconData icon, String label, String value, Color color) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
      Icon(icon, size: 16, color: color), const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.orbitron(fontSize: 10, color: color, letterSpacing: 1)),
        Text(value, style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
      ])),
    ]));
  }

  Widget _sec(IconData icon, String title, Color color, List<String> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 6), Text(title, style: GoogleFonts.orbitron(fontSize: 11, color: color, letterSpacing: 2)), const SizedBox(width: 10), Expanded(child: Container(height: 0.5, color: Color(0xFF1E1E30)))]),
      const SizedBox(height: 10),
      ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 6), child: Container(width: 4, height: 4, decoration: BoxDecoration(color: color.withOpacity(0.5), borderRadius: BorderRadius.circular(2)))),
        const SizedBox(width: 10),
        Text(item, style: GoogleFonts.inter(fontSize: 13, color: Color(0xFF8888AA), height: 1.4)),
      ]))),
    ]);
  }

  Widget _rc(AIReview r, Color pc) {
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Color(0xFF12121A), borderRadius: BorderRadius.circular(12), border: Border.all(color: Color(0xFF1E1E30))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [...List.generate(5, (i) => Icon(i < r.rating.round() ? Icons.star : Icons.star_border, size: 14, color: Color(0xFFFFA726))), Spacer(), Text(r.rating.toString(), style: GoogleFonts.orbitron(fontSize: 12, color: Color(0xFFFFA726)))]),
        const SizedBox(height: 8), Text(r.text, style: GoogleFonts.inter(fontSize: 13, color: Color(0xFFCCCCDD), height: 1.4)),
        const SizedBox(height: 8), Row(children: [Icon(Icons.person, size: 12, color: Color(0xFF555577)), const SizedBox(width: 4), Text(r.author, style: GoogleFonts.inter(fontSize: 11, color: Color(0xFF555577))), if (r.source != null) ...[const SizedBox(width: 8), Icon(Icons.link, size: 10, color: Color(0xFF555577)), const SizedBox(width: 3), Text(r.source!, style: GoogleFonts.inter(fontSize: 10, color: pc.withOpacity(0.5)))]]),
      ]),
    );
  }

  Future<void> _launchUrl(String url) async {
    try { await launchUrlString(url, mode: LaunchMode.externalApplication); }
    catch (_) { try { await launchUrlString(url); } catch (_) {} }
  }

  Color _getColor(String p) {
    switch (p) {
      case "OpenAI": return const Color(0xFF00C853);
      case "Anthropic": return const Color(0xFFFF6D00);
      case "Google": return const Color(0xFF448AFF);
      case "Meta": return const Color(0xFF2979FF);
      case "Mistral": return const Color(0xFFFF9100);
      case "DeepSeek": return const Color(0xFF536DFE);
      case "xAI": return const Color(0xFF18FFFF);
      case "Cohere": return const Color(0xFF651FFF);
      default: return AppColors.neonBlue;
    }
  }
}