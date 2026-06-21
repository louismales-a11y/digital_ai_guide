import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../models/ai_model.dart';
import '../services/scraping_service.dart';

class CompareScreen extends StatefulWidget {
  final AIModel? initialModel;
  const CompareScreen({super.key, this.initialModel});
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<AIModel> _models = [];
  bool _isLoading = true;
  AIModel? _modelA;
  AIModel? _modelB;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final service = ScrapingService();
    final models = await service.getModels();
    if (mounted) {
      setState(() {
        _models = models;
        _isLoading = false;
        if (widget.initialModel != null) {
          _modelA = widget.initialModel;
          _modelB = models.length > 1 ? models[1] : null;
        } else {
          if (models.isNotEmpty) _modelA = models[0];
          if (models.length > 1) _modelB = models[1];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.compare_arrows, color: Color(0xFF00FF88), size: 18),
          ),
          const SizedBox(width: 12),
          Text('COMPARE', style: GoogleFonts.orbitron(letterSpacing: 2)),
        ]),
        backgroundColor: AppColors.bgDark,
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
        : Column(children: [
            // Selectors
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(children: [
                Expanded(child: _buildSelector(isA: true)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.compare_arrows, color: Color(0xFFFF1744), size: 24),
                ),
                Expanded(child: _buildSelector(isA: false)),
              ]),
            ),
            const SizedBox(height: 8),
            // Comparison table
            Expanded(child: _modelA != null && _modelB != null
              ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Score bar
                    _buildScoreBar(),
                    const SizedBox(height: 20),
                    // Specs
                    _compareRow('Provider', _modelA!.provider, _modelB!.provider, icon: Icons.business),
                    _compareRow('Category', _modelA!.category, _modelB!.category, icon: Icons.category),
                    _compareRow('Price (Input)', _formatPrice(_modelA!.inputPricePer1kTokens), _formatPrice(_modelB!.inputPricePer1kTokens), icon: Icons.attach_money),
                    _compareRow('Price (Output)', _formatPrice(_modelA!.outputPricePer1kTokens), _formatPrice(_modelB!.outputPricePer1kTokens), icon: Icons.attach_money),
                    _compareRow('Context Window', _formatContext(_modelA!.contextWindow), _formatContext(_modelB!.contextWindow), icon: Icons.auto_stories),
                    _compareRow('Benchmark', _modelA!.benchmarkScore ?? 'N/A', _modelB!.benchmarkScore ?? 'N/A', icon: Icons.analytics),
                    _compareRow('Vision', _boolIcon(_modelA!.supportsVision), _boolIcon(_modelB!.supportsVision), icon: Icons.image),
                    _compareRow('Function Calling', _boolIcon(_modelA!.supportsFunctionCalling), _boolIcon(_modelB!.supportsFunctionCalling), icon: Icons.functions),
                    _compareRow('Streaming', _boolIcon(_modelA!.supportsStreaming), _boolIcon(_modelB!.supportsStreaming), icon: Icons.stream),
                    const SizedBox(height: 16),
                    // Strengths side by side
                    _strengthsSection(_modelA!, _modelB!),
                  ],
                )
              : Center(child: Text('Select two models to compare', style: GoogleFonts.inter(color: AppColors.textMuted))),
            ),
          ]),
    );
  }

  Widget _buildSelector({required bool isA}) {
    final selected = isA ? _modelA : _modelB;
    return GestureDetector(
      onTap: () => _pickModel(isA),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isA ? const Color(0xFF00B8FF).withOpacity(0.3) : const Color(0xFFFF1744).withOpacity(0.3),
          ),
        ),
        child: Column(children: [
          Text(isA ? 'MODEL A' : 'MODEL B', style: GoogleFonts.orbitron(
            fontSize: 9, color: isA ? const Color(0xFF00B8FF) : const Color(0xFFFF1744), letterSpacing: 2)),
          const SizedBox(height: 6),
          Text(selected?.name ?? 'SELECT', style: GoogleFonts.orbitron(
            fontSize: 12, color: selected != null ? Colors.white : AppColors.textMuted,
            letterSpacing: 0.5), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  void _pickModel(bool isA) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        height: 400,
        child: Column(children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 12), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.all(16), child: Text('SELECT MODEL', style: GoogleFonts.orbitron(
            fontSize: 14, color: AppColors.neonBlue, letterSpacing: 2))),
          Expanded(child: ListView.builder(
            itemCount: _models.length,
            itemBuilder: (c, i) => ListTile(
              leading: Icon(Icons.memory, color: _getColor(_models[i].provider), size: 20),
              title: Text(_models[i].name, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
              subtitle: Text(_models[i].provider, style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11)),
              selected: _models[i] == (isA ? _modelA : _modelB),
              onTap: () { setState(() { if (isA) _modelA = _models[i]; else _modelB = _models[i]; }); Navigator.pop(ctx); },
            ),
          )),
        ]),
      ),
    );
  }

  Widget _buildScoreBar() {
    if (_modelA == null || _modelB == null) return const SizedBox();
    final aScore = _extractScore(_modelA!.benchmarkScore);
    final bScore = _extractScore(_modelB!.benchmarkScore);
    if (aScore == null || bScore == null) return const SizedBox();
    final total = aScore + bScore;
    final aPct = total > 0 ? aScore / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(children: [
        Text('BENCHMARK COMPARISON', style: GoogleFonts.orbitron(fontSize: 10, color: const Color(0xFFFFA726), letterSpacing: 2)),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(
          height: 28,
          child: Row(children: [
            Expanded(flex: (aPct * 100).round(), child: Container(
              alignment: Alignment.center,
              color: const Color(0xFF00B8FF),
              child: Text('${aScore.toStringAsFixed(0)}%', style: GoogleFonts.orbitron(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold)),
            )),
            Expanded(flex: ((1 - aPct) * 100).round(), child: Container(
              alignment: Alignment.center,
              color: const Color(0xFFFF1744),
              child: Text('${bScore.toStringAsFixed(0)}%', style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
            )),
          ]),
        )),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_modelA!.name.length > 18 ? '${_modelA!.name.substring(0, 16)}..' : _modelA!.name, style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFF00B8FF))),
          Text(_modelB!.name.length > 18 ? '${_modelB!.name.substring(0, 16)}..' : _modelB!.name, style: GoogleFonts.inter(fontSize: 9, color: const Color(0xFFFF1744))),
        ]),
      ]),
    );
  }

  Widget _compareRow(String label, String valA, String valB, {required IconData icon}) {
    final bool aWins = _aIsBetter(label, valA, valB);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.borderSubtle, width: 0.5))),
      child: Row(children: [
        Icon(icon, size: 12, color: AppColors.textMuted),
        const SizedBox(width: 6),
        SizedBox(width: 80, child: Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted))),
        Expanded(child: Text(valA, style: GoogleFonts.inter(
          fontSize: 11, color: aWins ? const Color(0xFF00FF88) : const Color(0xFF8888AA),
          fontWeight: aWins ? FontWeight.w600 : FontWeight.normal),
          textAlign: TextAlign.center)),
        const SizedBox(width: 8),
        Container(width: 1, height: 20, color: AppColors.borderSubtle),
        const SizedBox(width: 8),
        Expanded(child: Text(valB, style: GoogleFonts.inter(
          fontSize: 11, color: !aWins ? const Color(0xFF00FF88) : const Color(0xFF8888AA),
          fontWeight: !aWins ? FontWeight.w600 : FontWeight.normal),
          textAlign: TextAlign.center)),
      ]),
    );
  }

  Widget _strengthsSection(AIModel a, AIModel b) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('STRENGTHS', style: GoogleFonts.orbitron(fontSize: 10, color: const Color(0xFF00FF88), letterSpacing: 2)),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: _strengthList(a.strengthsList, const Color(0xFF00B8FF))),
          const SizedBox(width: 8),
          Container(width: 1, height: 100, color: AppColors.borderSubtle),
          const SizedBox(width: 8),
          Expanded(child: _strengthList(b.strengthsList, const Color(0xFFFF1744))),
        ]),
      ]),
    );
  }

  Widget _strengthList(List<String> items, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children:
      items.take(4).map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.check, size: 10, color: color),
          const SizedBox(width: 4),
          Expanded(child: Text(s, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF8888AA)))),
        ]),
      )).toList(),
    );
  }

  bool _aIsBetter(String label, String a, String b) {
    if (label == 'Price (Input)' || label == 'Price (Output)') {
      final aP = _extractNum(a); final bP = _extractNum(b);
      if (aP != null && bP != null) return aP < bP;
    }
    if (label == 'Context Window') {
      final aC = _extractNum(a); final bC = _extractNum(b);
      if (aC != null && bC != null) return aC > bC;
    }
    if (label == 'Benchmark') {
      final aS = _extractScore(a); final bS = _extractScore(b);
      if (aS != null && bS != null) return aS > bS;
    }
    if (label == 'Vision' || label == 'Function Calling' || label == 'Streaming') {
      return a == 'Yes' && b != 'Yes';
    }
    return false;
  }

  double? _extractScore(String? s) {
    if (s == null) return null;
    final n = double.tryParse(s.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (n == null) return null;
    if (n > 1 && n <= 100) return n;
    if (n <= 1) return n * 100;
    return null;
  }

  double? _extractNum(String s) {
    return double.tryParse(s.replaceAll(RegExp(r'[^0-9.eE\-]'), ''));
  }

  String _formatPrice(double? p) {
    if (p == null) return 'N/A';
    return '\$${p.toStringAsFixed(4)}/1K';
  }

  String _formatContext(int? c) {
    if (c == null) return 'N/A';
    if (c >= 1000000) return '${(c / 1000000).toStringAsFixed(1)}M tokens';
    return '${(c / 1000).toStringAsFixed(0)}K tokens';
  }

  String _boolIcon(bool v) => v ? 'Yes' : 'No';

  Color _getColor(String provider) {
    switch (provider) {
      case 'OpenAI': return const Color(0xFF00C853);
      case 'Anthropic': return const Color(0xFFFF6D00);
      case 'Google': return const Color(0xFF448AFF);
      case 'Meta': return const Color(0xFF2979FF);
      case 'Mistral': return const Color(0xFFFF9100);
      case 'DeepSeek': return const Color(0xFF536DFE);
      case 'xAI': return const Color(0xFF18FFFF);
      case 'Cohere': return const Color(0xFF651FFF);
      default: return AppColors.neonBlue;
    }
  }
}
