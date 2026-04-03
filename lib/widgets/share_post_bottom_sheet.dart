import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../providers/user_provider.dart';
import '../models/chat_session.dart';
import '../models/group_chat.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';

class SharePostBottomSheet extends StatefulWidget {
  final Map<String, dynamic> post;

  const SharePostBottomSheet({super.key, required this.post});

  @override
  State<SharePostBottomSheet> createState() => _SharePostBottomSheetState();
}

class _SharePostBottomSheetState extends State<SharePostBottomSheet> {
  final ChatService _chatService = ChatService();
  bool _isLoading = true;
  List<ChatSession> _recentChats = [];
  List<GroupChat> _groups = [];

  @override
  void initState() {
    super.initState();
    _fetchShareOptions();
  }

  Future<void> _fetchShareOptions() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final email = userProvider.email;
    if (email == null) return;

    try {
      final chatsResp = await _chatService.getUserChatSessions(email);
      final groupsResp = await _chatService.getUserGroupChats(email);
      if (mounted) {
        setState(() {
          _recentChats = chatsResp;
          _groups = groupsResp;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _shareToSession(ChatSession session) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;

    final content = "Check out this post: ${widget.post['title']}";
    try {
      await _chatService.sendChatMessage(session.sessionId, userProvider.email!, content);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shared successfully!")));
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to share post")));
       }
    }
  }

  Future<void> _shareToGroup(GroupChat group) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;

    final content = "Check out this post: ${widget.post['title']}";
    try {
      await _chatService.sendGroupMessage(group.id, userProvider.email!, content);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Shared successfully!")));
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to share post")));
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_recentChats.isEmpty && _groups.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        child: Center(child: Text("No chats or groups available to share to.", style: TextDesign.h3)),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text("Share with...", style: TextDesign.h2),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (_recentChats.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text("Recent Chats", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  ),
                  ..._recentChats.map((chat) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.secondary),
                    ),
                    title: Text(chat.otherUser.fullName),
                    trailing: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onTap: () => _shareToSession(chat),
                  )),
                ],
                if (_groups.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text("Groups", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  ),
                  ..._groups.map((group) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.withValues(alpha: 0.1),
                      child: const Icon(Icons.group, color: Colors.teal),
                    ),
                    title: Text(group.name),
                    trailing: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onTap: () => _shareToGroup(group),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
