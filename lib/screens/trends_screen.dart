import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../services/trends_service.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});
  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final TrendsService _service = TrendsService();
  List<AITrend> _trends = [];
  bool _isLoading = true;
  String _selectedCategory = 'ALL';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final trends = await _service.getTrends(forceRefresh: true);
      if (mounted) setState(() { _trends = trends; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  List<AITrend> get _filtered {
    if (_selectedCategory == 'ALL') return _trends;
    return _trends.where((t) => t.category.toUpperCase() == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(border: Border.all(color: Color(0xFFFF6B6B).withOpacity(0.3)), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.trending_up, color: Color(0xFFFF6B6B), size: 18)),
          const SizedBox(width: 12),
          Text('TRENDS', style: GoogleFonts.orbitron(letterSpacing: 2)),
        ]),
        backgroundColor: AppColors.bgDark, elevation: 0,
        actions: [Container(margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(border: Border.all(color: AppColors.borderSubtle), borderRadius: BorderRadius.circular(8)), child: IconButton(icon: const Icon(Icons.refresh, color: AppColors.neonBlue, size: 20), onPressed: _isLoading ? null : _load))],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
        : Column(children: [
            SizedBox(height: 44, child: ListView.builder(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 4,
              itemBuilder: (ctx, i) {
                final cats = ['ALL', 'PRICE', 'NEW_MODEL', 'INDUSTRY'];
                final sel = cats[i] == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cats[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? Color(0xFFFF6B6B).withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? Color(0xFFFF6B6B).withOpacity(0.4) : AppColors.borderSubtle),
                      ),
                      child: Text(cats[i] == 'NEW_MODEL' ? 'NEW MODEL' : cats[i], style: GoogleFonts.orbitron(fontSize: 10, letterSpacing: 1.5, color: sel ? Color(0xFFFF6B6B) : AppColors.textMuted)),
                    ),
                  ),
                );
              },
            )),
            Expanded(
              child: _filtered.isEmpty
                ? Center(child: Text('No trends loaded (' + _trends.length.toString() + ' loaded)', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted)))
                : RefreshIndicator(
                    color: AppColors.neonBlue,
                    onRefresh: _load,
                    child: ListView.builder(padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(context).padding.bottom), itemCount: _filtered.length, itemBuilder: (ctx, i) => _buildTrendCard(_filtered[i])),
                  ),
            ),
          ]),
    );
  }

  Widget _buildTrendCard(AITrend trend) {
    final catColor = trend.category == 'price' ? const Color(0xFFFF6B6B) : trend.category == 'new_model' ? const Color(0xFF00B8FF) : const Color(0xFF7C4DFF);
    final icon = trend.category == 'price' ? Icons.attach_money : trend.category == 'new_model' ? Icons.new_releases : Icons.business;
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: catColor.withOpacity(0.2))), child: Icon(icon, color: catColor, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(trend.title, style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.5)), Text(trend.date, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted))])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(trend.category.toUpperCase().replaceAll('_', ' '), style: GoogleFonts.orbitron(fontSize: 7, color: catColor, letterSpacing: 1))),
        ]),
        const SizedBox(height: 10),
        Text(trend.description, style: GoogleFonts.inter(fontSize: 13, color: Color(0xFF8888AA), height: 1.4)),
        if (trend.source != null) ...[const SizedBox(height: 8), Row(children: [Icon(Icons.link, size: 10, color: AppColors.textMuted), const SizedBox(width: 4), Text(trend.source!, style: GoogleFonts.inter(fontSize: 10, color: catColor.withOpacity(0.6)))])],
      ]),
    );
  }
}