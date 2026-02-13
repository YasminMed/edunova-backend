import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
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

  // Mock data moved to state for filtering
  final List<Map<String, dynamic>> _allChats = [
    {
      'name': 'Dr. Sarah Smith',
      'message': 'Please submit your assignment by Friday.',
      'time': '10:30 AM',
      'unread': true,
      'avatarColor': Colors.blueAccent,
    },
    {
      'name': 'John Doe',
      'message': 'Hey, did you finish the project?',
      'time': 'Yesterday',
      'unread': false,
      'avatarColor': Colors.green,
    },
    {
      'name': 'Alice Johnson',
      'message': 'Thanks for the help!',
      'time': 'Yesterday',
      'unread': false,
      'avatarColor': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _allGroups = [
    {
      'name': 'Computer Science 101',
      'message': 'New lecture notes uploaded.',
      'time': '11:45 AM',
      'unread': true,
      'avatarColor': Colors.purple,
    },
    {
      'name': 'Project Team A',
      'message': 'Meeting at 3 PM in the library.',
      'time': '9:15 AM',
      'unread': true,
      'avatarColor': Colors.teal,
    },
    {
      'name': 'University Events',
      'message': 'Don\'t miss the career fair tomorrow!',
      'time': 'Mon',
      'unread': false,
      'avatarColor': Colors.redAccent,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.translate('add_friend') ?? 'Add Friend',
          style: TextDesign.h3,
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText:
                AppLocalizations.of(context)?.translate('enter_email') ??
                'Enter email or username',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          ElevatedButton(
            onPressed: () {
              // TODO: Implement Add Friend logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)?.translate('add') ?? 'Add',
            ),
          ),
        ],
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
                      AppLocalizations.of(
                            context,
                          )?.translate('mark_all_read') ??
                          'Mark all as read',
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'saved',
                    child: Text(
                      AppLocalizations.of(
                            context,
                          )?.translate('saved_messages') ??
                          'Saved Messages',
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
      body: TabBarView(
        controller: _tabController,
        children: [_buildChatsList(), _buildGroupsList()],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Avoid Nav Bar overlap
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
          name: chat['name'],
          message: chat['message'],
          time: chat['time'],
          unread: chat['unread'],
          avatarColor: chat['avatarColor'],
          isGroup: false,
        );
      },
    );
  }

  Widget _buildGroupsList() {
    final filteredGroups = _allGroups.where((group) {
      final name = group['name'].toString().toLowerCase();
      final message = group['message'].toString().toLowerCase();
      return name.contains(_searchQuery) || message.contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 80),
      itemCount: filteredGroups.length,
      itemBuilder: (context, index) {
        final group = filteredGroups[index];
        return _buildChatTile(
          context: context,
          name: group['name'],
          message: group['message'],
          time: group['time'],
          unread: group['unread'],
          avatarColor: group['avatarColor'],
          isGroup: true,
        );
      },
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required String name,
    required String message,
    required String time,
    required bool unread,
    required Color avatarColor,
    required bool isGroup,
  }) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(
              name: name,
              avatarColor: avatarColor,
              isGroup: isGroup,
            ),
          ),
        );
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
          if (unread) ...[
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '1', // Mock unread count
                style: TextStyle(
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
