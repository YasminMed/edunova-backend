import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../widgets/animated_background.dart';
import '../services/chatbot_service.dart';

class StudentChatbotPage extends StatefulWidget {
  const StudentChatbotPage({super.key});

  @override
  State<StudentChatbotPage> createState() => _StudentChatbotPageState();
}

class _StudentChatbotPageState extends State<StudentChatbotPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isListening = false;
  String _selectedModel = 'groq';
  final ScrollController _bgScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add initial welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage(
        AppLocalizations.of(context)?.translate('chatbot_welcome') ??
            'Hi! I am your AI Study Assistant. Ask me anything about your lectures or studies.',
      );
    });
  }

  @override
  void dispose() {
    _bgScrollController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add({'isUser': true, 'text': text, 'time': DateTime.now()});
      _isTyping = true;
    });
    _scrollToBottom();

    // Convert messages to format expected by ChatbotService
    List<Map<String, String>> history = _messages.map((m) {
      return {
        'role': m['isUser'] ? 'user' : 'assistant',
        'content': m['text'].toString(),
      };
    }).toList();

    String responseText = await ChatbotService.sendMessage(
      messages: history,
      modelType: _selectedModel,
      userRole: 'student',
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

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      // Mock listening duration then input text
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isListening) {
          setState(() {
            _isListening = false;
            _textController.text = "When is my next exam?"; // Mock voice input
          });
          _handleSubmitted(_textController.text);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background
          AnimatedBackground(scrollController: _bgScrollController),

          // Content
          Column(
            children: [
              // AppBar spacer
              const SizedBox(height: 60),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "EduNova AI",
                            style: TextDesign.h2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)?.translate('online') ??
                                'Online',
                            style: TextDesign.body.copyWith(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedModel,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                          style: TextDesign.body.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 12),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedModel = newValue;
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 'groq', child: Text("Groq (DeepSeek API)")),
                            DropdownMenuItem(value: 'gemini', child: Text("Google Gemini")),
                            DropdownMenuItem(value: 'deepseek', child: Text("DeepSeek Official")),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Chat List
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    final message = _messages[index];
                    return _buildMessageBubble(
                      message['text'],
                      message['isUser'],
                      message['time'],
                    );
                  },
                ),
              ),

              // Input Area
              _buildInputArea(),

              // Bottom Nav Spacer
              const SizedBox(height: 100),
            ],
          ),

          // Listening Overlay
          if (_isListening)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)?.translate('listening') ??
                          'Listening...',
                      style: TextDesign.h2.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, DateTime time) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : Theme.of(context).cardColor.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                text,
                style: TextDesign.body.copyWith(
                  color: isUser
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText:
                    AppLocalizations.of(context)?.translate('chatbot_hint') ??
                    'Ask a question...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_rounded, color: AppColors.primary),
            onPressed: _toggleListening,
          ),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}
