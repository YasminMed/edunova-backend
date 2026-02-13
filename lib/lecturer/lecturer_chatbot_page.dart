import 'package:edunova_application/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';

import '../widgets/animated_background.dart';

class LecturerChatbotPage extends StatefulWidget {
  const LecturerChatbotPage({super.key});

  @override
  State<LecturerChatbotPage> createState() => _LecturerChatbotPageState();
}

class _LecturerChatbotPageState extends State<LecturerChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

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

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    setState(() {
      _messages.add({'isUser': true, 'text': text, 'time': DateTime.now()});
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            'isUser': false,
            'text':
                AppLocalizations.of(
                  context,
                )?.translate('lecturer_ai_response') ??
                "That sounds interesting! I can help you organize that material or schedule the next quiz.",
            'time': DateTime.now(),
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      AppLocalizations.of(context)?.translate('lecturer_ai') ??
                          "Lecturer AI",
                      style: TextDesign.h2.copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
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
