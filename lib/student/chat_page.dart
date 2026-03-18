import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../services/chat_service.dart';
import '../models/chat_session.dart';
import 'chat_detail_page.dart';
import 'create_group_sheet.dart';
import 'saved_messages_page.dart';

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
  final List<Map<String, dynamic>> _allGroups = []; // Keeping groups mock for now

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

    final sessions = await _chatService.getUserChatSessions(userProvider.email!);

    if (!mounted) return;
    setState(() {
      _allChats.clear();
      for (var s in sessions) {
        _allChats.add({
          'session_id': s.sessionId,
          'other_user_id': s.otherUser.id,
          'other_user_email': s.otherUser.email,
          'name': s.otherUser.fullName,
          'message': s.latestMessage.isEmpty ? 'Say Hi!' : s.latestMessage,
          'time': _formatTime(s.latestMessageTime),
          'unread': s.unreadCount > 0,
          'unreadCount': s.unreadCount,
          'avatarColor': Colors.blueAccent,
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

  void _openCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateGroupSheet(),
    );
  }

  void _markAllAsRead() {
    // Actually we should hit backend for this, but for now just local UI
    setState(() {
      for (var chat in _allChats) {
        chat['unread'] = false;
      }
      for (var group in _allGroups) {
        group['unread'] = false;
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
                  hintText: AppLocalizations.of(context)?.translate('search_chats') ?? 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                ),
              )
            : Text(
                AppLocalizations.of(context)?.translate('messages') ?? 'Messages',
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
                } else if (value == 'saved') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedMessagesPage(),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'mark_read',
                    child: Text(
                      AppLocalizations.of(context)?.translate('mark_all_read') ?? 'Mark all as read',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'saved',
                    child: Text(
                      AppLocalizations.of(context)?.translate('saved_messages') ?? 'Saved Messages',
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
            Tab(text: AppLocalizations.of(context)?.translate('chats') ?? 'Chats'),
            Tab(text: AppLocalizations.of(context)?.translate('groups') ?? 'Groups'),
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
            _tabController.index == 0 ? Icons.person_add_rounded : Icons.group_add_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildChatsList() {
    if (_allChats.isEmpty) {
      return const Center(child: Text("No chats yet. Click the + button to start one!"));
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
        );
      },
    );
  }

  Widget _buildGroupsList() {
    return const Center(child: Text("Groups coming soon"));
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
  }) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              sessionId: sessionId,
              otherUserEmail: otherUserEmail,
              name: name,
              avatarColor: avatarColor,
              isGroup: isGroup,
            ),
          ),
        ).then((_) => _loadChats()); // reload chats on return
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: avatarColor.withOpacity(0.2),
            child: Icon(
              isGroup ? Icons.groups_rounded : Icons.person_rounded,
              color: avatarColor,
              size: 28,
            ),
          ),
          if (unread)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextDesign.h3.copyWith(
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          message,
          style: TextDesign.body.copyWith(
            color: unread
                ? Theme.of(context).textTheme.bodyLarge?.color
                : AppColors.mutedText,
            fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: TextDesign.body.copyWith(
              color: unread ? AppColors.primary : AppColors.mutedText,
              fontWeight: unread ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
          if (unread && unreadCount > 0) ...[
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
