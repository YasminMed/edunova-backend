import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
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
                        if (message.content.isNotEmpty)
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
                          if (message.content.isNotEmpty) const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final url = Uri.parse('${ChatService.baseUrl}/api/files/${message.attachmentId}');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.white24 : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.attachment, color: isMe ? Colors.white : AppColors.primary, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    "View Attachment",
                                    style: TextStyle(color: isMe ? Colors.white : AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.mutedText,
            ),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (userProvider.email == null) return;
                
                final fileId = await _chatService.uploadFile(
                  filePath: kIsWeb ? null : result.files.single.path,
                  bytes: kIsWeb ? result.files.single.bytes : null,
                  fileName: result.files.single.name,
                );
                
                if (fileId != null) {
                  final textContent = _messageController.text.trim();
                  _messageController.clear();
                  final newMessage = await _chatService.sendChatMessage(
                    widget.sessionId,
                    userProvider.email!,
                    textContent.isEmpty ? "Attachment" : textContent,
                    attachmentId: fileId,
                  );
                  if (newMessage != null) {
                    setState(() {
                      _messages.add(newMessage);
                    });
                    _scrollToBottom();
                  }
                }
              }
            },
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
