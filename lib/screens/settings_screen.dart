import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../services/version_service.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _baseUrlCtrl;
  late String _selectedModel;
  bool _obscureKey = true;
  bool _isSaving = false;

  final List<String> _modelOptions = [
    'gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo',
    'claude-3-5-sonnet-20241022', 'claude-3-5-haiku-20241022',
    'gemini-2.0-flash', 'gemini-2.0-pro', 'grok-2',
    'deepseek-chat', 'deepseek-coder',
  ];

  @override
  void initState() {
    super.initState();
    final api = Provider.of<ApiService>(context, listen: false);
    _apiKeyCtrl = TextEditingController(text: api.apiKey ?? '');
    _baseUrlCtrl = TextEditingController(text: api.baseUrl);
    _selectedModel = api.selectedModel;
  }

  @override
  void dispose() { _apiKeyCtrl.dispose(); _baseUrlCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      await api.setApiKey(_apiKeyCtrl.text.trim());
      await api.setBaseUrl(_baseUrlCtrl.text.trim());
      await api.setSelectedModel(_selectedModel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: const Color(0xFF00FF88),
          content: Text('CONFIG SAVED',
            style: GoogleFonts.orbitron(fontSize: 11, letterSpacing: 1, color: Colors.black)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppColors.neonRed,
          content: Text('ERROR: ${e.toString()}',
            style: GoogleFonts.orbitron(fontSize: 9, letterSpacing: 1)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
              border: Border.all(color: AppColors.neonBlue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.settings, color: AppColors.neonBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text('CONFIG', style: GoogleFonts.orbitron(letterSpacing: 2), overflow: TextOverflow.ellipsis),
          ),
        ]),
        backgroundColor: AppColors.bgDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Section header
          Text('PROVIDER', style: GoogleFonts.orbitron(fontSize: 12, color: AppColors.neonBlue, letterSpacing: 2)),
          const SizedBox(height: 8),
          Row(children: [
            _presetBtn('OpenAI', 'https://api.openai.com/v1', Icons.code, Color(0xFF00C853)),
            const SizedBox(width: 6),
            _presetBtn('DeepSeek', 'https://api.deepseek.com/v1', Icons.code, Color(0xFF536DFE)),
            const SizedBox(width: 6),
            _presetBtn('OpenRouter', 'https://openrouter.ai/api/v1', Icons.api, Color(0xFFFF6D00)),
          ]),
          const SizedBox(height: 20),

          // AUTHENTICATION
          const SizedBox(height: 16),
          _buildField(
            label: 'API KEY',
            hint: 'sk-...',
            child: TextField(
              controller: _apiKeyCtrl, obscureText: _obscureKey,
              style: GoogleFonts.inter(color: AppColors.neonBlue, fontSize: 13),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureKey ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textMuted, size: 18),
                  onPressed: () => setState(() => _obscureKey = !_obscureKey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _sectionHeader(Icons.link, 'ENDPOINT'),
          const SizedBox(height: 16),
          _buildField(
            label: 'BASE URL',
            hint: 'https://api.openai.com/v1',
            child: TextField(
              controller: _baseUrlCtrl,
              style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),

          _sectionHeader(Icons.memory, 'DEFAULT MODEL'),
          const SizedBox(height: 16),
          _buildField(
            label: 'MODEL ID',
            hint: '',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
                color: AppColors.bgCard,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedModel,
                  isExpanded: true,
                  dropdownColor: AppColors.bgCard,
                  style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13),
                  icon: const Icon(Icons.expand_more, color: AppColors.neonBlue),
                  items: _modelOptions.map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(m, style: GoogleFonts.inter(fontSize: 13)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedModel = v ?? _selectedModel),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Save
          SizedBox(width: double.infinity, height: 50,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B8FF), Color(0xFF0088FF)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF00B8FF).withOpacity(0.3),
                  blurRadius: 12,
                )],
              ),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('DEPLOY CONFIG',
                      style: GoogleFonts.orbitron(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: Colors.black, letterSpacing: 2)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neonBlue.withOpacity(0.15)),
              borderRadius: BorderRadius.circular(10),
              color: AppColors.neonBlue.withOpacity(0.03),
            ),
            child: Row(children: [
              const Icon(Icons.security, color: AppColors.neonBlue, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'Your API key is encrypted and stored locally. No data leaves your device except API calls.',
                style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textMuted, height: 1.4),
              )),
            ]),
          ),
        ]),
      ),
    );
  }


  Widget _presetBtn(String label, String url, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _baseUrlCtrl.text = url;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label + " URL set", style: GoogleFonts.inter(fontSize: 12, color: Colors.white)), backgroundColor: Color(0xFF00FF88), duration: Duration(seconds: 1)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.orbitron(fontSize: 8, color: color, letterSpacing: 1)),
          ]),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.neonBlue),
      const SizedBox(width: 8),
      Text(title, style: GoogleFonts.orbitron(
        fontSize: 12, color: AppColors.neonBlue, letterSpacing: 2)),
      const SizedBox(width: 12),
      Expanded(child: Container(height: 0.5, color: AppColors.borderSubtle)),
    ]);
  }

  Widget _buildField({required String label, required String hint, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(label, style: GoogleFonts.orbitron(
          fontSize: 9, color: AppColors.textMuted, letterSpacing: 1.5)),
      ),
      child,
    ]);
  }
}
