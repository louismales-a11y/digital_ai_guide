import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../models/ai_model.dart';
import '../services/scraping_service.dart';
import '../services/advisor_service.dart';

class AdvisorScreen extends StatefulWidget {
  const AdvisorScreen({super.key});
  @override
  State<AdvisorScreen> createState() => _AdvisorScreenState();
}

class _AdvisorScreenState extends State<AdvisorScreen> {
  List<AIModel> _models = [];
  bool _isLoading = true;
  List<String> _selectedTasks = [];
  double _budget = 0.5;
  String _contextLength = 'medium';
  List<ModelScore>? _results;
  bool _showResults = false;

  final List<Map<String, dynamic>> _tasks = [
    {'id': 'coding', 'icon': Icons.code, 'label': 'CODING', 'color': const Color(0xFF00C853)},
    {'id': 'writing', 'icon': Icons.edit, 'label': 'WRITING', 'color': const Color(0xFF448AFF)},
    {'id': 'analysis', 'icon': Icons.analytics, 'label': 'ANALYSIS', 'color': const Color(0xFFFF6D00)},
    {'id': 'creative', 'icon': Icons.palette, 'label': 'CREATIVE', 'color': const Color(0xFFE040FB)},
    {'id': 'chat', 'icon': Icons.chat, 'label': 'CHAT', 'color': const Color(0xFF00B8FF)},
    {'id': 'vision', 'icon': Icons.image, 'label': 'VISION', 'color': const Color(0xFF7C4DFF)},
    {'id': 'reasoning', 'icon': Icons.psychology, 'label': 'REASONING', 'color': const Color(0xFFFF1744)},
  ];

  @override
  void initState() { super.initState(); _loadModels(); }

  Future<void> _loadModels() async {
    setState(() => _isLoading = true);
    final service = ScrapingService();
    final models = await service.getModels();
    if (mounted) setState(() { _models = models; _isLoading = false; });
  }

  void _recommend() {
    setState(() {
      _results = AdvisorService.recommend(
        models: _models,
        taskTypes: _selectedTasks,
        budgetPreference: _budget,
        contextLength: _contextLength,
      );
      _showResults = true;
    });
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
              border: Border.all(color: AppColors.electricPurple.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb, color: AppColors.electricPurple, size: 18),
          ),
          const SizedBox(width: 12),
          Text('ADVISOR', style: GoogleFonts.orbitron(letterSpacing: 2)),
        ]),
        backgroundColor: AppColors.bgDark,
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
        : ListView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
            children: [
              if (!_showResults) ...[
                // Task selection
                Text('TASK TYPE', style: GoogleFonts.orbitron(
                  fontSize: 11, color: AppColors.neonBlue, letterSpacing: 2)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8,
                  children: _tasks.map((t) => GestureDetector(
                    onTap: () => setState(() {
                      final id = t['id'] as String;
                      if (_selectedTasks.contains(id)) {
                        _selectedTasks.remove(id);
                      } else if (_selectedTasks.length < 3) {
                        _selectedTasks.add(id);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedTasks.contains(t['id'])
                          ? (t['color'] as Color).withOpacity(0.15)
                          : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedTasks.contains(t['id'])
                            ? (t['color'] as Color).withOpacity(0.4)
                            : AppColors.borderSubtle,
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(t['icon'] as IconData, size: 16,
                          color: _selectedTasks.contains(t['id'])
                            ? t['color'] as Color
                            : AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(t['label'] as String, style: GoogleFonts.orbitron(
                          fontSize: 10, letterSpacing: 1.5,
                          color: _selectedTasks.contains(t['id'])
                            ? t['color'] as Color
                            : AppColors.textMuted)),
                      ]),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                        Text('Select up to 3 tasks', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                        const SizedBox(height: 20),

                // Budget slider
                Text('BUDGET', style: GoogleFonts.orbitron(
                  fontSize: 11, color: const Color(0xFFFF6D00), letterSpacing: 2)),
                const SizedBox(height: 8),
                Row(children: [
                  Text('ECONOMY', style: GoogleFonts.orbitron(
                    fontSize: 8, color: AppColors.textMuted, letterSpacing: 1)),
                  Expanded(child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color(0xFFFF6D00),
                      inactiveTrackColor: AppColors.borderSubtle,
                      thumbColor: const Color(0xFFFF6D00),
                      overlayColor: const Color(0xFFFF6D00).withOpacity(0.1),
                      trackHeight: 3,
                    ),
                    child: Slider(value: _budget, onChanged: (v) => setState(() => _budget = v)),
                  )),
                  Text('PREMIUM', style: GoogleFonts.orbitron(
                    fontSize: 8, color: AppColors.textMuted, letterSpacing: 1)),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Cheapest', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                  Text('Balanced', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                  Text('Best', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
                ]),
                const SizedBox(height: 28),

                // Context length
                Text('CONTEXT WINDOW', style: GoogleFonts.orbitron(
                  fontSize: 11, color: const Color(0xFF7C4DFF), letterSpacing: 2)),
                const SizedBox(height: 12),
                Row(children: [
                  _contextChip('SHORT', '32K', 'short'),
                  const SizedBox(width: 8),
                  _contextChip('MEDIUM', '128K', 'medium'),
                  const SizedBox(width: 8),
                  _contextChip('LONG', '1M+', 'long'),
                ]),
                const SizedBox(height: 32),

                // Recommend button
                SizedBox(width: double.infinity, height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF00B8FF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(
                        color: const Color(0xFF7C4DFF).withOpacity(0.3),
                        blurRadius: 12,
                      )],
                    ),
                    child: ElevatedButton(
                      onPressed: _recommend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('RECOMMEND',
                        style: GoogleFonts.orbitron(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: Colors.black, letterSpacing: 2)),
                    ),
                  ),
                ),
              ],

              if (_showResults && _results != null) ...[
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.check, color: Color(0xFF00FF88), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text('TOP PICKS', style: GoogleFonts.orbitron(
                    fontSize: 16, fontWeight: FontWeight.bold,
                    color: const Color(0xFF00FF88), letterSpacing: 2)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() { _showResults = false; _results = null; }),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderSubtle),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.refresh, color: AppColors.textMuted, size: 18),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Wrap(spacing: 6, runSpacing: 6, children: [
                    ..._selectedTasks.map((t) => _summaryChip(Icons.check, t.toUpperCase(), const Color(0xFF00C853))),
                    _summaryChip(Icons.attach_money,
                      _budget < 0.3 ? 'ECONOMY' : _budget < 0.7 ? 'BALANCED' : 'PREMIUM',
                      const Color(0xFFFF6D00)),
                    _summaryChip(Icons.auto_stories, _contextLength.toUpperCase(), const Color(0xFF7C4DFF)),
                  ]),
                ),
                const SizedBox(height: 16),
                ..._buildResultCards(),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderSubtle),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      onPressed: () => setState(() { _showResults = false; _results = null; }),
                      child: Text('NEW SEARCH', style: GoogleFonts.orbitron(
                        fontSize: 11, color: AppColors.textMuted, letterSpacing: 2)),
                    ),
                  ),
                ),
              ],
            ],
          ),
    );
  }

  List<Widget> _buildResultCards() {
    return List.generate(_results!.length, (i) {
      final r = _results![i];
      final pColor = _getProviderColor(r.model.provider);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: i == 0 ? const Color(0xFF00FF88).withOpacity(0.3) : AppColors.borderSubtle,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: i == 0 ? const Color(0xFF00FF88) : i == 1 ? const Color(0xFF448AFF) : const Color(0xFFFF6D00),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text('${i + 1}', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.model.name, style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              Text(r.model.provider, style: GoogleFonts.inter(fontSize: 11, color: pColor)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)), borderRadius: BorderRadius.circular(6)),
              child: Text('${r.score.toStringAsFixed(0)}%', style: GoogleFonts.orbitron(fontSize: 11, color: const Color(0xFF00FF88))),
            ),
          ]),
          const SizedBox(height: 12),
          ...r.reasons.map((reason) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check, size: 12, color: Color(0xFF00FF88)),
              const SizedBox(width: 6),
              Expanded(child: Text(reason, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8888AA), height: 1.3))),
            ]),
          )),
          const SizedBox(height: 8),
          Row(children: [
            Text(r.model.priceDisplay, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            if (r.model.contextWindow != null) ...[
              const SizedBox(width: 12),
              Text('${(r.model.contextWindow! / 1000).toStringAsFixed(0)}K ctx', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted)),
            ],
          ]),
        ]),
      );
    });
  }

  Widget _contextChip(String label, String hint, String value) {
    final sel = _contextLength == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _contextLength = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFF7C4DFF).withOpacity(0.1) : AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: sel ? const Color(0xFF7C4DFF).withOpacity(0.4) : AppColors.borderSubtle),
          ),
          child: Column(children: [
            Text(label, style: GoogleFonts.orbitron(fontSize: 10, color: sel ? const Color(0xFF7C4DFF) : AppColors.textMuted, letterSpacing: 1.5)),
            const SizedBox(height: 2),
            Text(hint, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textMuted)),
          ]),
        ),
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.orbitron(fontSize: 8, color: color, letterSpacing: 1)),
      ]),
    );
  }

  Color _getProviderColor(String provider) {
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
