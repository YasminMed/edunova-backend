import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../services/chat_service.dart';
import '../models/chat_session.dart';
import 'chat_detail_page.dart';
import 'group_chat_detail_page.dart';
import 'create_group_sheet.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = "";
  bool _isLoading = true;

  final ChatService _chatService = ChatService();
  final List<Map<String, dynamic>> _allChats = [];
  final List<Map<String, dynamic>> _allGroups =
      []; // Keeping groups mock for now

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadChats();
  }

  void _loadChats() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;

    final sessions = await _chatService.getUserChatSessions(
      userProvider.email!,
    );
    final groups = await _chatService.getUserGroupChats(userProvider.email!);

    if (!mounted) return;
    setState(() {
      _allChats.clear();
      for (var s in sessions) {
        _allChats.add({
          'session_id': s.sessionId,
          'other_user_id': s.otherUser.id,
          'other_user_email': s.otherUser.email,
          'name': s.otherUser.fullName,
          'photo_url': s.otherUser.photoUrl,
          'message': s.latestMessage.isEmpty ? 'Say Hi!' : s.latestMessage,
          'time': _formatTime(s.latestMessageTime),
          'unread': s.unreadCount > 0,
          'unreadCount': s.unreadCount,
          'avatarColor': Colors.blueAccent,
        });
      }

      _allGroups.clear();
      for (var g in groups) {
        _allGroups.add({
          'group_id': g.id,
          'name': g.name,
          'photo_url': g.photoUrl,
          'admin_id': g.adminId,
          'message': g.latestMessage.isEmpty
              ? 'Group created'
              : g.latestMessage,
          'time': _formatTime(g.latestMessageTime),
          'unread': g.unreadCount > 0,
          'unreadCount': g.unreadCount,
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
              AppLocalizations.of(context)?.translate('add_friend') ??
                  'Add Friend',
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
                      hintText:
                          AppLocalizations.of(
                            context,
                          )?.translate('enter_email') ??
                          'Enter email or username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () async {
                          if (searchQuery.isEmpty) return;
                          setDialogState(() => isSearching = true);
                          final results = await _chatService.searchUsers(
                            searchQuery,
                          );
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
                              final currentUserEmail =
                                  Provider.of<UserProvider>(
                                    context,
                                    listen: false,
                                  ).email;
                              if (currentUserEmail != null) {
                                final session = await _chatService
                                    .startChatSession(
                                      currentUserEmail,
                                      user.id,
                                    );
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

  void _openCreateGroupSheet(BuildContext context) async {
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

  void _markAllAsRead() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email != null) {
      await _chatService.markAllChatSessionsRead(userProvider.email!);
    }
    setState(() {
      for (var chat in _allChats) {
        chat['unread'] = false;
        chat['unreadCount'] = 0;
      }
      for (var group in _allGroups) {
        group['unread'] = false;
        group['unreadCount'] = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.of(context)?.translate('search_chats') ??
                      'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                ),
              )
            : Text(
                AppLocalizations.of(context)?.translate('messages') ??
                    'Messages',
                style: TextDesign.h2.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = "";
                }
              });
            },
          ),
          if (!_isSearching)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              onSelected: (value) {
                if (value == 'mark_read') {
                  _markAllAsRead();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'mark_read',
                    child: Text(
                      AppLocalizations.of(
                            context,
                          )?.translate('mark_all_read') ??
                          'Mark all as read',
                    ),
                  ),
                ];
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.mutedText,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: TextDesign.h3.copyWith(fontSize: 16),
          tabs: [
            Tab(
              text: AppLocalizations.of(context)?.translate('chats') ?? 'Chats',
            ),
            Tab(
              text:
                  AppLocalizations.of(context)?.translate('groups') ?? 'Groups',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildChatsList(), _buildGroupsList()],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () {
            if (_tabController.index == 0) {
              _showAddFriendDialog(context);
            } else {
              _openCreateGroupSheet(context);
            }
          },
          backgroundColor: AppColors.primary,
          child: Icon(
            _tabController.index == 0
                ? Icons.person_add_rounded
                : Icons.group_add_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    if (_allChats.isEmpty) {
      return const Center(
        child: Text("No chats yet. Click the + button to start one!"),
      );
    }
    final filteredChats = _allChats.where((chat) {
      final name = chat['name'].toString().toLowerCase();
      final message = chat['message'].toString().toLowerCase();
      return name.contains(_searchQuery) || message.contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 80),
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return _buildChatTile(
          context: context,
          sessionId: chat['session_id'],
          otherUserEmail: chat['other_user_email'],
          name: chat['name'],
          message: chat['message'],
          time: chat['time'],
          unread: chat['unread'],
          unreadCount: chat['unreadCount'],
          avatarColor: chat['avatarColor'],
          isGroup: false,
          photoUrl: chat['photo_url'],
        );
      },
    );
  }

  Widget _buildGroupsList() {
    if (_allGroups.isEmpty) {
      return const Center(
        child: Text("No groups yet. Click the + button to create one!"),
      );
    }
    final filteredGroups = _allGroups.where((group) {
      final name = group['name'].toString().toLowerCase();
      final message = group['message'].toString().toLowerCase();
      return name.contains(_searchQuery) || message.contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 100),
      itemCount: filteredGroups.length,
      itemBuilder: (context, index) {
        final group = filteredGroups[index];
        return _buildChatTile(
          context: context,
          sessionId: group['group_id'],
          otherUserEmail:
              "", // Group doesn't have otherUserEmail in this context
          name: group['name'],
          message: group['message'],
          time: group['time'],
          unread: group['unread'] ?? false,
          unreadCount: group['unreadCount'] ?? 0,
          avatarColor: group['avatarColor'],
          isGroup: true,
          photoUrl: group['photo_url'],
        );
      },
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required int sessionId,
    required String otherUserEmail,
    required String name,
    required String message,
    required String time,
    required bool unread,
    required int unreadCount,
    required Color avatarColor,
    required bool isGroup,
    String? photoUrl,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.primaryText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          if (isGroup) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupChatDetailPage(
                  groupId: sessionId,
                  groupName: name,
                  photoUrl: photoUrl,
                  adminId: 0, // Placeholder
                ),
              ),
            ).then((_) => _loadChats());
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                  sessionId: sessionId,
                  otherUserEmail: otherUserEmail,
                  name: name,
                  avatarColor: avatarColor,
                  isGroup: false,
                  photoUrl: photoUrl,
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
                  ? AppColors.primary.withOpacity(0.2)
                  : (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.02)),
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
                      image: photoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(
                                "${ChatService.baseUrl}$photoUrl",
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: photoUrl == null
                        ? Icon(
                            isGroup
                                ? Icons.groups_rounded
                                : Icons.person_rounded,
                            color: avatarColor,
                            size: 28,
                          )
                        : null,
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
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
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
                            name,
                            style: TextDesign.h3.copyWith(
                              fontSize: 16,
                              fontWeight: unread
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: unread
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: unread
                                ? AppColors.primary
                                : AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message,
                            style: TextDesign.body.copyWith(
                              fontSize: 14,
                              color: unread
                                  ? titleColor.withOpacity(0.9)
                                  : AppColors.mutedText,
                              fontWeight: unread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
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
  }
}
