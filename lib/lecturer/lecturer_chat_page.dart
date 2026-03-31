import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../services/chat_service.dart';
import '../models/chat_session.dart';
import '../student/chat_detail_page.dart';
import '../student/group_chat_detail_page.dart';
import '../student/create_group_sheet.dart';

class LecturerChatPage extends StatefulWidget {
  const LecturerChatPage({super.key});

  @override
  State<LecturerChatPage> createState() => _LecturerChatPageState();
}

class _LecturerChatPageState extends State<LecturerChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";
  bool _isLoading = true;

  final ChatService _chatService = ChatService();
  final List<Map<String, dynamic>> _allChats = [];
  final List<Map<String, dynamic>> _allGroups = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadChats();
  }

  void _loadChats() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;

    final sessions = await _chatService.getUserChatSessions(userProvider.email!);
    final groups = await _chatService.getUserGroupChats(userProvider.email!);

    if (!mounted) return;
    setState(() {
      _allChats.clear();
      for (var s in sessions) {
        _allChats.add({
          'session_id': s.sessionId,
          'other_user_id': s.otherUser.id,
          'other_user_email': s.otherUser.email,
          'name': s.otherUser.role == 'student' ? 'Student: ${s.otherUser.fullName}' : s.otherUser.fullName,
          'message': s.latestMessage.isEmpty ? 'Say Hi!' : s.latestMessage,
          'time': _formatTime(s.latestMessageTime),
          'unread': s.unreadCount > 0,
          'unreadCount': s.unreadCount,
          'avatarColor': Colors.blueAccent,
          'photo_url': s.otherUser.photoUrl,
        });
      }
      
      _allGroups.clear();
      for (var g in groups) {
        _allGroups.add({
          'group_id': g.id,
          'name': g.name,
          'photo_url': g.photoUrl,
          'admin_id': g.adminId,
          'message': g.latestMessage.isEmpty ? 'Group created' : g.latestMessage,
          'time': _formatTime(g.latestMessageTime),
          'unread': false,
          'unreadCount': 0,
          'avatarColor': Colors.green, // default color
        });
      }
      
      _isLoading = false;
    });
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
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _markAllAsRead() {
    setState(() {
      for (var chat in _allChats) {
        chat['unread'] = false;
      }
      for (var group in _allGroups) {
        group['unread'] = false;
      }
    });
  }

  void _showAddFriendDialog(BuildContext context) {
    String searchQuery = "";
    List<ChatUser> searchResults = [];
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context)?.translate('add_friend') ?? 'Add Friend',
              style: TextDesign.h3,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) => searchQuery = value,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.translate('enter_email') ?? 'Enter email or username',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          if (searchQuery.isEmpty) return;
                          setDialogState(() => isSearching = true);
                          final results = await _chatService.searchUsers(searchQuery);
                          setDialogState(() {
                            searchResults = results;
                            isSearching = false;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isSearching)
                    const CircularProgressIndicator()
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final user = searchResults[index];
                          return ListTile(
                            title: Text(user.fullName),
                            subtitle: Text(user.email),
                            onTap: () async {
                              final currentUserEmail = Provider.of<UserProvider>(context, listen: false).email;
                              if (currentUserEmail != null) {
                                final session = await _chatService.startChatSession(currentUserEmail, user.id);
                                if (session != null && mounted) {
                                  Navigator.pop(context); // close dialog
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatDetailPage(
                                        sessionId: session.sessionId,
                                        otherUserEmail: session.otherUser.email,
                                        name: session.otherUser.fullName,
                                        avatarColor: Colors.blueAccent,
                                        isGroup: false,
                                        photoUrl: session.otherUser.photoUrl,
                                      ),
                                    ),
                                  ).then((_) => _loadChats());
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel',
                  style: const TextStyle(color: AppColors.mutedText),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.primaryText;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()),
              )
            : Text(
                AppLocalizations.of(context)?.translate('messages') ??
                    'Messages',
                style: TextDesign.h2.copyWith(color: textColor),
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() => _isSearching = !_isSearching),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'mark_read') _markAllAsRead();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_read',
                child: Text('Mark all as read'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.secondary,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildList(_allChats, false), _buildList(_allGroups, true)],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: AppColors.secondary,
          onPressed: () async {
            if (_tabController.index == 0) {
              _showAddFriendDialog(context);
            } else {
              final shouldRefresh = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CreateGroupSheet(),
              );
              if (shouldRefresh == true) {
                _loadChats();
              }
            }
          },
          child: const Icon(Icons.add_comment_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list, bool isGroupView) {
    if (list.isEmpty) {
      return Center(child: Text(isGroupView ? "No groups yet. Click the + button to create one!" : "No chats yet. Click the + button to start one!"));
    }
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = list
        .where((m) => m['name'].toLowerCase().contains(_searchQuery) || m['message'].toLowerCase().contains(_searchQuery))
        .toList();
        
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final chat = filtered[index];
        final bool unread = chat['unread'] ?? false;
        final int unreadCount = chat['unreadCount'] ?? 0;
        final avatarColor = chat['avatarColor'] as Color;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: InkWell(
            onTap: () {
              if (isGroupView) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupChatDetailPage(
                      groupId: chat['group_id'],
                      groupName: chat['name'],
                      photoUrl: chat['photo_url'],
                      adminId: chat['admin_id'],
                    ),
                  ),
                ).then((_) => _loadChats());
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailPage(
                      sessionId: chat['session_id'],
                      otherUserEmail: chat['other_user_email'],
                      name: chat['name'],
                      avatarColor: avatarColor,
                      isGroup: false,
                      photoUrl: chat['photo_url'],
                    ),
                  ),
                ).then((_) => _loadChats());
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withOpacity(0.04) 
                    : const Color(0xFFFBFDFF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: unread 
                      ? AppColors.secondary.withOpacity(0.2) 
                      : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar Section
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: avatarColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(18),
                          image: chat['photo_url'] != null 
                              ? DecorationImage(
                                  image: NetworkImage("${ChatService.baseUrl}${chat['photo_url']}"),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: (isGroupView && chat['photo_url'] == null) 
                            ? Icon(Icons.groups_rounded, color: avatarColor, size: 28)
                            : (!isGroupView && chat['photo_url'] == null 
                                ? Icon(Icons.person_rounded, color: avatarColor, size: 28) 
                                : null),
                      ),
                      if (unread)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Content Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                chat['name'],
                                style: TextDesign.h3.copyWith(
                                  fontSize: 16,
                                  fontWeight: unread ? FontWeight.w900 : FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.primaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              chat['time'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: unread ? FontWeight.w800 : FontWeight.w500,
                                color: unread ? AppColors.secondary : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chat['message'],
                                style: TextDesign.body.copyWith(
                                  fontSize: 14,
                                  color: unread 
                                      ? (isDark ? Colors.white : AppColors.primaryText) 
                                      : (isDark ? Colors.white60 : AppColors.mutedText),
                                  fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (unread && unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
