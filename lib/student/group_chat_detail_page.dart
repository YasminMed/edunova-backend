import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../services/chat_service.dart';
import '../models/chat_session.dart';
import 'group_settings_page.dart';

class GroupChatDetailPage extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String? photoUrl;
  final int adminId;

  const GroupChatDetailPage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.photoUrl,
    required this.adminId,
  });

  @override
  State<GroupChatDetailPage> createState() => _GroupChatDetailPageState();
}

class _GroupChatDetailPageState extends State<GroupChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isMuted = false;

  final ChatService _chatService = ChatService();
  List<ChatMessage> _messages = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadMessages(isPolling: true);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages({bool isPolling = false}) async {
    final msgs = await _chatService.getGroupMessages(widget.groupId);
    if (!mounted) return;

    setState(() {
      _messages = msgs;
    });

    if (!isPolling) {
      _scrollToBottom();
    }
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    // Optimistic UI
    final tempMsg = ChatMessage(
      id: 0,
      senderId: -1,
      senderName: 'Me',
      senderEmail: userProvider.email,
      content: content,
      createdAt: DateTime.now().toIso8601String(),
      isRead: false,
    );
    setState(() {
      _messages.add(tempMsg);
    });
    _scrollToBottom();

    await _chatService.sendGroupMessage(
      widget.groupId,
      userProvider.email!,
      content,
    );
    _loadMessages();
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

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  ImageProvider _getGroupImage() {
    if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      return NetworkImage("${ChatService.baseUrl}${widget.photoUrl}");
    }
    return const AssetImage('assets/edunova_logo.png') as ImageProvider;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              radius: 18,
              backgroundImage: widget.photoUrl != null
                  ? _getGroupImage()
                  : null,
              child: widget.photoUrl == null
                  ? const Icon(
                      Icons.groups_rounded,
                      color: AppColors.primary,
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    style: TextDesign.h3.copyWith(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Group',
                    style: TextDesign.body.copyWith(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupSettingsPage(
                    groupId: widget.groupId,
                    groupName: widget.groupName,
                    photoUrl: widget.photoUrl,
                    adminId: widget.adminId,
                  ),
                ),
              ).then((shouldReload) {
                if (shouldReload == true) {
                  // If the user modified info (like group name or photo),
                  // we might want to reload or pop back to ChatPage to refresh.
                  // For now let's just pop and let ChatPage reload on resume.
                  Navigator.pop(context, true);
                }
              });
            },
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

                bool senderIsMe =
                    message.senderId == -1 ||
                    (userProvider.email != null &&
                        message.senderEmail == userProvider.email);

                String displayName = message.senderName;
                if (message.senderId == widget.adminId) {
                  displayName = "$displayName (Owner)";
                }

                return Align(
                  alignment: senderIsMe
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
                      color: senderIsMe
                          ? AppColors.primary
                          : Theme.of(context).cardColor.withOpacity(0.9),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: senderIsMe
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: senderIsMe
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
                        if (!senderIsMe)
                          Text(
                            displayName,
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (!senderIsMe) const SizedBox(height: 4),
                        Text(
                          message.content,
                          style: TextDesign.body.copyWith(
                            color: senderIsMe
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.createdAt),
                              style: TextStyle(
                                color: senderIsMe
                                    ? Colors.white70
                                    : Colors.black45,
                                fontSize: 10,
                              ),
                            ),
                          ],
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
                  hintStyle: const TextStyle(color: AppColors.mutedText),
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
