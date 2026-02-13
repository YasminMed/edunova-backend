import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../student/chat_detail_page.dart';
import '../student/create_group_sheet.dart';
import '../student/saved_messages_page.dart';

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

  final List<Map<String, dynamic>> _allChats = [
    {
      'name': 'Student: Ali Hassan',
      'message': 'Professor, I have a question about the task.',
      'time': '10:30 AM',
      'unread': true,
      'avatarColor': Colors.blueAccent,
    },
    {
      'name': 'Dr. Sarah Ahmed',
      'message': 'Did you review the research paper?',
      'time': 'Yesterday',
      'unread': false,
      'avatarColor': Colors.green,
    },
  ];

  final List<Map<String, dynamic>> _allGroups = [
    {
      'name': 'Faculty Board',
      'message': 'Meeting at 11 AM.',
      'time': 'Yesterday',
      'unread': true,
      'avatarColor': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
              if (value == 'saved') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedMessagesPage(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_read',
                child: Text('Mark all as read'),
              ),
              const PopupMenuItem(
                value: 'saved',
                child: Text('Saved Messages'),
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
      body: TabBarView(
        controller: _tabController,
        children: [_buildList(_allChats), _buildList(_allGroups)],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          backgroundColor: AppColors.secondary,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const CreateGroupSheet(),
            );
          },
          child: const Icon(Icons.add_comment_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = list
        .where((m) => m['name'].toLowerCase().contains(_searchQuery))
        .toList();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final chat = filtered[index];
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailPage(
                  name: chat['name'],
                  avatarColor: chat['avatarColor'],
                  isGroup: false,
                ),
              ),
            );
          },
          leading: CircleAvatar(
            backgroundColor: (chat['avatarColor'] as Color).withOpacity(0.1),
            child: Icon(Icons.person, color: chat['avatarColor']),
          ),
          title: Text(
            chat['name'],
            style: TextDesign.h3.copyWith(
              color: isDark ? Colors.white : AppColors.primaryText,
            ),
          ),
          subtitle: Text(
            chat['message'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppColors.bodyText,
            ),
          ),
          trailing: Text(
            chat['time'],
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}
