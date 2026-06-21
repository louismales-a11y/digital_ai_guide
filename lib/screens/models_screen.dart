import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_colors.dart';
import '../models/ai_model.dart';
import '../services/scraping_service.dart';
import '../widgets/model_card.dart';
import '../services/favorites_service.dart';
import '../services/glossary_service.dart';

class ModelsScreen extends StatefulWidget {
  const ModelsScreen({super.key});
  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  List<AIModel> _models = [];
  List<AIModel> _filteredModels = [];
  Set<String> _favorites = {};
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'ALL';
  String _sortBy = 'Name';
  bool _showFavoritesOnly = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> _categories = ['ALL', 'General', 'Chat', 'Vision', 'Code', 'Reasoning'];

  @override
  void initState() { super.initState(); _loadFavorites(); _loadModels(); }

  Future<void> _loadFavorites() async {
    final favs = await FavoritesService.getFavorites();
    if (mounted) setState(() { _favorites = favs; });
  }
  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }


  Future<void> _refreshModels() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final service = ScrapingService();
      final models = await service.getModels(forceRefresh: true);
      if (mounted) {
        setState(() { _models = models; _filteredModels = models; _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: const Color(0xFF00FF88),
          duration: const Duration(seconds: 1),
          content: Text('MODELS UPDATED', style: GoogleFonts.orbitron(fontSize: 10, color: Colors.black, letterSpacing: 1)),
        ));
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }


  void _applySort() {
    _filteredModels.sort((a, b) {
      switch (_sortBy) {
        case 'Name':
          return a.name.compareTo(b.name);
        case 'Price':
          final aP = a.inputPricePer1kTokens ?? 999;
          final bP = b.inputPricePer1kTokens ?? 999;
          return aP.compareTo(bP);
        case 'Context':
          return (b.contextWindow ?? 0).compareTo(a.contextWindow ?? 0);
        case 'Benchmark':
          final aB = double.tryParse((a.benchmarkScore ?? '0').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          final bB = double.tryParse((b.benchmarkScore ?? '0').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          return bB.compareTo(aB);
        default:
          return 0;
      }
    });
  }


  Future<void> _loadModels() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final service = ScrapingService();
      final models = await service.getModels(forceRefresh: true);
      if (mounted) setState(() { _models = models; _filteredModels = models; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _filter() {
    setState(() {
      _filteredModels = _models.where((m) {
        final cat = _selectedCategory == 'ALL' || m.category.toUpperCase() == _selectedCategory.toUpperCase();
        final search = _searchQuery.isEmpty
          || m.name.toLowerCase().contains(_searchQuery.toLowerCase())
          || m.provider.toLowerCase().contains(_searchQuery.toLowerCase());
        final fav = !_showFavoritesOnly || _favorites.contains(m.name);
        return cat && search && fav;
      }).toList();
      _applySort();
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
              border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.compare_arrows, color: AppColors.neonBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text('MODELS', style: GoogleFonts.orbitron(letterSpacing: 2), overflow: TextOverflow.ellipsis),
          ),
        ]),
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderSubtle),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.help_outline, color: AppColors.neonBlue, size: 20),
              onPressed: () => _showGlossary(context),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderSubtle),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.neonBlue, size: 20),
              onPressed: _isLoading ? null : _refreshModels,
            ),
          ),
        ],
      ),
      body: Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
              color: AppColors.bgCard,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) { _searchQuery = v; _filter(); },
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'SCAN MODELS...',
                hintStyle: GoogleFonts.orbitron(
                  color: AppColors.textMuted, fontSize: 11, letterSpacing: 1),
                prefixIcon: const Icon(Icons.search, color: AppColors.neonBlue, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                      onPressed: () { _searchCtrl.clear(); _searchQuery = ''; _filter(); },
                    )
                  : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // Category chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categories.length,
            itemBuilder: (ctx, i) {
              final cat = _categories[i];
              final sel = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () { _selectedCategory = cat; _filter(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.neonBlue.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? AppColors.neonBlue.withOpacity(0.4) : AppColors.borderSubtle,
                      ),
                    ),
                    child: Text(cat, style: GoogleFonts.orbitron(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: sel ? AppColors.neonBlue : AppColors.textMuted,
                    )),
                  ),
                ),
              );
            },
          ),
        ),

        
            // Sort + Favorites bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(children: [
                GestureDetector(
                  onTap: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: _showFavoritesOnly ? Color(0xFFFFA726).withOpacity(0.5) : AppColors.borderSubtle),
                      borderRadius: BorderRadius.circular(8),
                      color: _showFavoritesOnly ? Color(0xFFFFA726).withOpacity(0.1) : Colors.transparent,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_showFavoritesOnly ? Icons.star : Icons.star_border, size: 14, color: _showFavoritesOnly ? Color(0xFFFFA726) : AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text('Favorites', style: GoogleFonts.inter(fontSize: 11, color: _showFavoritesOnly ? Color(0xFFFFA726) : AppColors.textMuted)),
                    ]),
                  ),
                ),
                const Spacer(),
                Icon(Icons.sort, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    dropdownColor: AppColors.bgCard,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted),
                    icon: Icon(Icons.expand_more, size: 14, color: AppColors.textMuted),
                    items: ['Name', 'Price', 'Context', 'Benchmark'].map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s, style: GoogleFonts.inter(fontSize: 11)),
                    )).toList(),
                    onChanged: (v) { _sortBy = v ?? 'Name'; _filter(); },
                  ),
                ),
              ]),
            ),
        // Results
        Expanded(child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.neonBlue))
          : _error != null
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.error_outline, color: AppColors.neonRed, size: 48),
                const SizedBox(height: 16),
                Text('CONNECTION ERROR', style: GoogleFonts.orbitron(
                  color: AppColors.neonRed, fontSize: 14, letterSpacing: 1)),
                const SizedBox(height: 8),
                Text('Failed to load model data', style: GoogleFonts.inter(color: AppColors.textMuted)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: _loadModels,
                    child: Text('RETRY', style: GoogleFonts.orbitron(
                      color: AppColors.neonBlue, fontSize: 11, letterSpacing: 2)),
                  ),
                ),
              ]))
            : _filteredModels.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.search_off, color: AppColors.textMuted, size: 48),
                  const SizedBox(height: 16),
                  Text('NO MATCHES', style: GoogleFonts.orbitron(
                    color: AppColors.textMuted, fontSize: 14, letterSpacing: 1)),
                  Text('Try different search terms', style: GoogleFonts.inter(color: AppColors.textMuted)),
                ]))
              : RefreshIndicator(
                  color: AppColors.neonBlue,
                  onRefresh: _loadModels,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + MediaQuery.of(context).padding.bottom),
                    itemCount: _filteredModels.length,
                    itemBuilder: (ctx, i) => ModelCard(model: _filteredModels[i]),
                  ),
                )),
      ]),
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
                border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.menu_book, color: AppColors.neonBlue, size: 18)),
              const SizedBox(width: 12),
              Text('AI GLOSSARY', style: GoogleFonts.orbitron(fontSize: 16, color: AppColors.neonBlue, letterSpacing: 2)),
            ]),
          ),
          const Divider(color: Color(0xFF1E1E30), height: 1),
          Expanded(child: ListView(
            padding: const EdgeInsets.all(16),
            children: GlossaryService.terms.map((term) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF12121A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E1E30)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(term.icon, size: 16, color: AppColors.neonBlue),
                  const SizedBox(width: 8),
                  Text(term.term, style: GoogleFonts.orbitron(fontSize: 13, color: Colors.white, letterSpacing: 1)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _copyTerm(term.term, term.definition),
                    child: Icon(Icons.copy, size: 14, color: AppColors.textMuted),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(term.definition, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF8888AA), height: 1.4)),
                if (term.example != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.neonBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.neonBlue.withOpacity(0.1)),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(Icons.lightbulb, size: 12, color: AppColors.neonBlue),
                      const SizedBox(width: 6),
                      Expanded(child: Text(term.example!, style: GoogleFonts.inter(
                        fontSize: 11, color: const Color(0xFFAAAAAA), height: 1.3))),
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
    // Clip to clipboard functionality
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: const Color(0xFF00FF88),
      duration: const Duration(seconds: 1),
      content: Text('$term definition ready for copying',
        style: GoogleFonts.inter(fontSize: 12, color: Colors.black)),
    ));
  }
}
