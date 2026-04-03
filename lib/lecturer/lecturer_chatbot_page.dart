import 'package:edunova_application/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../widgets/animated_background.dart';
import '../services/chatbot_service.dart';

class LecturerChatbotPage extends StatefulWidget {
  const LecturerChatbotPage({super.key});

  @override
  State<LecturerChatbotPage> createState() => _LecturerChatbotPageState();
}

class _LecturerChatbotPageState extends State<LecturerChatbotPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  String _selectedModel = 'groq';

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to access context safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage(
        AppLocalizations.of(context)?.translate('hello_prof') ??
            "Hello Professor! I am your AI assistant for managing lectures and materials. How can I help you today?",
      );
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'isUser': false, 'text': text, 'time': DateTime.now()});
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add({'isUser': true, 'text': text, 'time': DateTime.now()});
      _isTyping = true;
    });
    _scrollToBottom();

    // Convert to API format
    List<Map<String, String>> history = _messages.map((m) {
      return {
        'role': m['isUser'] ? 'user' : 'assistant',
        'content': m['text'].toString(),
      };
    }).toList();

    String responseText = await ChatbotService.sendMessage(
      messages: history,
      modelType: _selectedModel,
      userRole: 'lecturer',
    );

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'isUser': false,
          'text': responseText,
          'time': DateTime.now(),
        });
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          Column(
            children: [
              const SizedBox(height: 60),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.smart_toy_rounded,
                      color: AppColors.secondary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(
                              context,
                            )?.translate('lecturer_ai') ??
                            "Lecturer AI",
                        style: TextDesign.h2.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedModel,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppColors.secondary,
                          ),
                          style: TextDesign.body.copyWith(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 12,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedModel = newValue;
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'groq',
                              child: Text("Groq (DeepSeek API)"),
                            ),
                            DropdownMenuItem(
                              value: 'gemini',
                              child: Text("Google Gemini"),
                            ),
                            DropdownMenuItem(
                              value: 'deepseek',
                              child: Text("DeepSeek Official"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    final msg = _messages[index];
                    return _buildBubble(msg['text'], msg['isUser']);
                  },
                ),
              ),
              _buildInput(),
              const SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? AppColors.secondary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.primaryText),
          ),
        ),
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    AppLocalizations.of(context)?.translate('lecturer_hint') ??
                    'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.secondary),
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}
