import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../services/chat_service.dart';
import '../models/chat_session.dart';
import 'group_info_page.dart';

class ChatDetailPage extends StatefulWidget {
  final int sessionId;
  final String otherUserEmail;
  final String name;
  final Color avatarColor;
  final bool isGroup;
  final String? photoUrl;

  const ChatDetailPage({
    super.key,
    required this.sessionId,
    required this.otherUserEmail,
    required this.name,
    required this.avatarColor,
    required this.isGroup,
    this.photoUrl,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isMuted = false;

  final ChatService _chatService = ChatService();
  List<ChatMessage> _messages = [];
  Timer? _pollingTimer;
  Timer? _statusTimer;
  Timer? _heartbeatTimer;
  String _statusText = 'Loading...';
  Color _statusColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startTimers();
  }

  void _startTimers() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _loadMessages(isPolling: true);
    });
    _statusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _updateUserStatus();
    });
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      _sendHeartbeat();
    });
    _updateUserStatus();
    _sendHeartbeat();
  }

  void _updateUserStatus() async {
    if (widget.isGroup) {
      setState(() {
        _statusText = AppLocalizations.of(context)?.translate('tap_for_info') ?? 'Tap for info';
        _statusColor = Colors.grey;
      });
      return;
    }

    try {
      final status = await _chatService.getUserStatus(widget.otherUserEmail);
      if (!mounted) return;
      setState(() {
        if (status['is_online']) {
          _statusText = AppLocalizations.of(context)?.translate('online') ?? 'Online';
          _statusColor = Colors.green;
        } else {
          try {
            final lastSeen = DateTime.parse(status['last_seen']).toLocal();
            final now = DateTime.now();
            final diff = now.difference(lastSeen);
            if (diff.inMinutes < 1) {
              _statusText = 'Last seen: just now';
            } else if (diff.inMinutes < 60) {
              _statusText = 'Last seen: ${diff.inMinutes}m ago';
            } else if (diff.inHours < 24) {
              _statusText = 'Last seen: ${diff.inHours}h ago';
            } else {
              _statusText = 'Last seen: ${diff.inDays}d ago';
            }
          } catch (e) {
            _statusText = 'Offline';
          }
          _statusColor = Colors.grey;
        }
      });
    } catch (e) {
      // ignore
    }
  }

  void _sendHeartbeat() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email != null) {
      await _chatService.sendHeartbeat(userProvider.email!);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _statusTimer?.cancel();
    _heartbeatTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages({bool isPolling = false}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;

    final msgs = await _chatService.getChatMessages(
      widget.sessionId,
      userProvider.email!,
    );
    if (!mounted) return;

    setState(() {
      _messages = msgs;
    });

    if (!isPolling) {
      // scroll down only initially
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
      senderId: -1, // current user temp
      senderName: 'Me',
      content: content,
      createdAt: DateTime.now().toIso8601String(),
      isRead: false,
    );
    setState(() {
      _messages.add(tempMsg);
    });
    _scrollToBottom();

    await _chatService.sendChatMessage(
      widget.sessionId,
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

  void _openChatInfo() {
    if (widget.isGroup) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupInfoPage(
            name: widget.name,
            avatarColor: widget.avatarColor,
            isAdmin: true,
          ),
        ),
      );
    }
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
        title: InkWell(
          onTap: _openChatInfo,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.avatarColor.withOpacity(0.2),
                radius: 18,
                backgroundImage: widget.photoUrl != null
                    ? NetworkImage("${ChatService.baseUrl}${widget.photoUrl}")
                    : null,
                child: widget.photoUrl == null
                    ? Icon(
                        widget.isGroup
                            ? Icons.groups_rounded
                            : Icons.person_rounded,
                        color: widget.avatarColor,
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
                      widget.name,
                      style: TextDesign.h3.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _statusText,
                      style: TextDesign.body.copyWith(
                        color: _statusColor,
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
                final isMe =
                    message.senderId == -1 ||
                    (userProvider.email != null &&
                        _messages[index].senderName != widget.name);
                // We assume if senderName != otherUser's name (which is widget.name), it's probably me.
                // A better check would be senderEmail, but we don't have it in ChatMessage. We can check by ID if we stored current user ID.
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
                        if (message.content.isNotEmpty && message.content != "Attachment")
                          Text(
                            message.content,
                            style: TextDesign.body.copyWith(
                              color: isMe
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                              height: 1.4,
                            ),
                          ),
                        if (message.attachmentId != null) ...[
                          if (message.content.isNotEmpty && message.content != "Attachment") const SizedBox(height: 8),
                          _buildAttachment(message, isMe),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.createdAt),
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.black45,
                                fontSize: 10,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                message.isRead ? Icons.done_all : Icons.check,
                                size: 12,
                                color: message.isRead
                                    ? Colors.blue[200]
                                    : Colors.white70,
                              ),
                            ],
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

  Widget _buildAttachment(ChatMessage message, bool isMe) {
    if (message.attachmentId == null) return const SizedBox.shrink();

    final url = '${ChatService.baseUrl}/api/files/${message.attachmentId}';

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 250,
                maxHeight: 250,
                minWidth: 100,
                minHeight: 100,
              ),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to a card for documents
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.white24 : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMe
                            ? Colors.white30
                            : AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file_rounded,
                          color: isMe ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Document File",
                              style: TextStyle(
                                color: isMe ? Colors.white : AppColors.primaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "Click to open",
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
