import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import 'group_info_page.dart';

class ChatDetailPage extends StatefulWidget {
  final String name;
  final Color avatarColor;
  final bool isGroup;

  const ChatDetailPage({
    super.key,
    required this.name,
    required this.avatarColor,
    required this.isGroup,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isMuted = false;

  // Mock Messages
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text': 'Hello! How are you doing today?',
      'time': '10:00 AM',
    },
    {
      'isMe': true,
      'text': 'I am doing great, thanks! Just working on the project.',
      'time': '10:05 AM',
    },
    {
      'isMe': false,
      'text': 'That sounds good. Let me know if you need any help.',
      'time': '10:10 AM',
    },
    {'isMe': true, 'text': 'Will do! Thanks.', 'time': '10:12 AM'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'isMe': true,
        'text': _messageController.text,
        'time': 'Now',
      });
      _messageController.clear();
    });
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isMuted
              ? AppLocalizations.of(
                      context,
                    )?.translate('notifications_muted') ??
                    'Notifications Muted'
              : AppLocalizations.of(
                      context,
                    )?.translate('notifications_unmuted') ??
                    'Notifications Unmuted',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _openChatInfo() {
    if (widget.isGroup) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupInfoPage(
            name: widget.name,
            avatarColor: widget.avatarColor,
            isAdmin: true, // Mock logic
          ),
        ),
      );
    } else {
      // Open User Profile logic (Placeholder)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        leadingWidth: 40,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).iconTheme.color,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: InkWell(
          onTap: _openChatInfo,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.avatarColor.withOpacity(0.2),
                radius: 18,
                child: Icon(
                  widget.isGroup ? Icons.groups_rounded : Icons.person_rounded,
                  color: widget.avatarColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextDesign.h3.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.isGroup
                          ? AppLocalizations.of(
                                  context,
                                )?.translate('tap_for_info') ??
                                'Tap for info'
                          : AppLocalizations.of(context)?.translate('online') ??
                                'Online',
                      style: TextDesign.body.copyWith(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isMuted
                  ? Icons.notifications_off_rounded
                  : Icons.notifications_active_rounded,
              color: _isMuted ? Colors.grey : AppColors.primary,
            ),
            onPressed: _toggleMute,
            tooltip: _isMuted
                ? AppLocalizations.of(
                        context,
                      )?.translate('unmute_notifications') ??
                      'Unmute Notifications'
                : AppLocalizations.of(
                        context,
                      )?.translate('mute_notifications') ??
                      'Mute Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] as bool;
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isMe
                          ? AppColors.primary
                          : Theme.of(context).cardColor.withOpacity(0.9),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: isMe
                            ? Radius.zero
                            : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'],
                          style: TextDesign.body.copyWith(
                            color: isMe
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message['time'],
                          style: TextStyle(
                            color: isMe ? Colors.white70 : Colors.black45,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.mutedText,
            ),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context)?.translate('type_message') ??
                      'Type a message...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.mutedText),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
