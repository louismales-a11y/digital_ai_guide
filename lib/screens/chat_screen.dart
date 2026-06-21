import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../app_colors.dart';
import '../services/api_service.dart';
import '../services/search_service.dart';
import '../services/free_chat_service.dart';
import '../services/search_service.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<_ChatBubble> _messages = [];
  bool _isLoading = false;
  bool _isStreaming = false;
  bool _webSearch = false;
  List<SearchResult>? _searchR;
  String? _streamingContent;

  @override
  void dispose() { _msgCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }



  Future<void> _useFreeAI(String text) async {
    setState(() {
      _messages.add(_ChatBubble('user', text));
      _msgCtrl.clear();
      _isLoading = true;
    });
    try {
      final response = await FreeChatService.getResponse(text);
      if (mounted) setState(() {
        _messages.add(_ChatBubble('assistant', response));
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _messages.add(_ChatBubble('assistant', 'Error: ${e.toString()}', isError: true));
        _isLoading = false;
      });
    }
  }

  void _editMessage(_ChatBubble msg) {
    final controller = TextEditingController(text: msg.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12121A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E1E30)),
        ),
        title: Row(children: [
          Icon(Icons.edit, color: Color(0xFF00B8FF), size: 18),
          const SizedBox(width: 8),
          Text('EDIT MESSAGE', style: GoogleFonts.orbitron(fontSize: 14, color: Color(0xFF00B8FF), letterSpacing: 1)),
        ]),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0D1117),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.orbitron(color: Color(0xFF555577), fontSize: 11, letterSpacing: 2)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00B8FF), Color(0xFF0088FF)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () {
                final newText = controller.text.trim();
                if (newText.isNotEmpty) {
                  setState(() { msg.content = newText; });
                  Navigator.pop(ctx);
                  _resendFrom(msg);
                }
              },
              child: Text('UPDATE & RESEND', style: GoogleFonts.orbitron(color: Colors.black, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _resendFrom(_ChatBubble editedMsg) {
    final idx = _messages.indexOf(editedMsg);
    if (idx >= 0) {
      setState(() { _messages.removeRange(idx, _messages.length); });
      _send(editedMsg.content);
    }
  }


  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send([String? overrideText]) async {
    final text = overrideText ?? _msgCtrl.text.trim();
    if (text.isEmpty) return;
    if (overrideText == null && _isLoading) return;
    final api = Provider.of<ApiService>(context, listen: false);
    if (!api.hasApiKey) {
      _useFreeAI(text);
      return;
    }
    setState(() {
      _messages.add(_ChatBubble('user', text));
      _msgCtrl.clear();
      _isLoading = true;
      _isStreaming = false;
      _streamingContent = '';
    });
    _scrollDown();
    final history = _messages.map((m) => ChatMessage(role: m.role, content: m.content)).toList();
    try {
      String full = '';
      await api.sendMessage(messages: history, onStream: (chunk) {
        full += chunk;
        setState(() { _streamingContent = full; _isStreaming = true; });
        _scrollDown();
      });
      setState(() {
        _messages.add(_ChatBubble('assistant', full));
        _isLoading = false; _isStreaming = false; _streamingContent = null;
      });
      _scrollDown();
    } catch (e) {
      setState(() {
        _messages.add(_ChatBubble('assistant', 'ERROR: ${e.toString()}', isError: true));
        _isLoading = false; _isStreaming = false; _streamingContent = null;
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
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF00B8FF)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(
                color: const Color(0xFF7C4DFF).withOpacity(0.3),
                blurRadius: 8,
              )],
            ),
            child: const Icon(Icons.chat, color: Colors.black, size: 16),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text('AI CHAT', style: GoogleFonts.orbitron(letterSpacing: 2), overflow: TextOverflow.ellipsis),
          ),
        ]),
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.key, color: Color(0xFFFF6D00), size: 20),
              tooltip: 'Change API Key',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            const SizedBox(width: 4),
            Consumer<ApiService>(builder: (ctx, api, _) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderSubtle),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.memory, color: AppColors.neonBlue, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(api.selectedModel.length > 18
                    ? '${api.selectedModel.substring(0, 16)}..'
                    : api.selectedModel,
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis),
                )
              ]),
            ),
          )),
        ],
      ),
      body: Column(children: [
        // Messages
        Expanded(child: _messages.isEmpty && !_isLoading
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonBlue.withOpacity(0.2)),
                ),
                child: const Icon(Icons.chat_bubble_outline,
                  color: AppColors.neonBlue, size: 48),
              ),
              const SizedBox(height: 20),
              Text('INITIATE CHAT', style: GoogleFonts.orbitron(
                fontSize: 16, color: AppColors.neonBlue, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text('Send a message to begin the neural link',
                style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13)),
            ]))
          : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isStreaming ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (_isStreaming && i == _messages.length) {
                  return _BubbleWidget(
                    msg: _ChatBubble('assistant', _streamingContent ?? ''),
                    streaming: true);
                }
                return _BubbleWidget(msg: _messages[i]);
              },
            )),
        // Input area
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          decoration: const BoxDecoration(
            color: AppColors.bgDark,
            border: Border(top: BorderSide(color: AppColors.borderSubtle)),
          ),
          child: Row(children: [
            Expanded(child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderSubtle),
                color: AppColors.bgDark,
              ),
              child: TextField(
                controller: _msgCtrl,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'TYPE YOUR MESSAGE...',
                  hintStyle: GoogleFonts.orbitron(
                    color: AppColors.textMuted, fontSize: 10, letterSpacing: 1),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            )),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B8FF), Color(0xFF0088FF)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF00B8FF).withOpacity(0.3),
                  blurRadius: 10,
                )],
              ),
              child: IconButton(
                icon: _isLoading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.send, color: Colors.black),
                onPressed: _isLoading ? null : _send,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _ChatBubble {
  final String role;
  String content;
  final bool isError;
  final String id;
  static int _counter = 0;
  _ChatBubble(this.role, this.content, {this.isError = false}) : id = 'msg_${_counter++}';
}

class _BubbleWidget extends StatelessWidget {
  final _ChatBubble msg;
  final bool streaming;
  final bool isDark;
  final void Function(_ChatBubble)? onEdit;
  const _BubbleWidget({required this.msg, this.streaming = false, this.isDark = true, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00B8FF), Color(0xFF7C4DFF)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF7C4DFF).withOpacity(0.3),
                  blurRadius: 6,
                )],
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.black, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUser
                ? const Color(0xFF00B8FF).withOpacity(0.08)
                : (msg.isError
                  ? const Color(0xFFFF1744).withOpacity(0.08)
                  : AppColors.bgCard),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isUser ? 16 : 4),
                topRight: Radius.circular(isUser ? 4 : 16),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
              border: Border.all(
                color: isUser
                  ? const Color(0xFF00B8FF).withOpacity(0.2)
                  : (msg.isError
                    ? const Color(0xFFFF1744).withOpacity(0.3)
                    : AppColors.borderSubtle),
              ),
            ),
            child: Text(
              msg.content + (streaming ? ' █' : ''),
              style: GoogleFonts.inter(fontSize: 14,
                color: isUser
                  ? const Color(0xFF00B8FF)
                  : (msg.isError
                    ? const Color(0xFFFF1744)
                    : AppColors.textPrimary),
                height: 1.5,
              )),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.neonRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neonRed.withOpacity(0.2)),
              ),
              child: const Icon(Icons.person, color: AppColors.neonRed, size: 14),
            ),
          ],
        ],
      ),
    );
  }
}
