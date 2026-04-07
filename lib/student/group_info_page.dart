import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class GroupInfoPage extends StatefulWidget {
  final String name;
  final Color avatarColor;
  final bool isAdmin;

  const GroupInfoPage({
    super.key,
    required this.name,
    required this.avatarColor,
    this.isAdmin = true, // Mock admin status
  });

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  // Mock Members Data
  final List<Map<String, dynamic>> _members = [
    {'name': 'You', 'isAdmin': true, 'color': Colors.blue},
    {'name': 'Dr. Sarah Smith', 'isAdmin': true, 'color': Colors.red},
    {'name': 'John Doe', 'isAdmin': false, 'color': Colors.green},
    {'name': 'Alice Johnson', 'isAdmin': false, 'color': Colors.orange},
    {'name': 'Bob Wilson', 'isAdmin': false, 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.translate('group_settings') ??
              'Group Settings',
          style: TextDesign.h2.copyWith(color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header: Photo & Name
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: widget.avatarColor.withOpacity(0.2),
                    child: Icon(
                      Icons.groups_rounded,
                      size: 60,
                      color: widget.avatarColor,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.name, style: TextDesign.h2),
                IconButton(
                  icon: const Icon(
                    Icons.edit_rounded,
                    color: AppColors.mutedText,
                    size: 20,
                  ),
                  onPressed: () {
                    // Edit Name Logic
                  },
                ),
              ],
            ),
            Text(
              "${_members.length} ${AppLocalizations.of(context)?.translate('members') ?? 'Members'}",
              style: TextDesign.body.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 32),

            // Members Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)?.translate('members') ??
                        'Members',
                    style: TextDesign.h3.copyWith(color: AppColors.primary),
                  ),
                  if (widget.isAdmin)
                    TextButton.icon(
                      onPressed: () {
                        // Add Members Logic
                      },
                      icon: const Icon(Icons.person_add_rounded, size: 18),
                      label: Text(
                        AppLocalizations.of(context)?.translate('add') ?? 'Add',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: member['color'],
                    radius: 20,
                    child: Text(
                      member['name'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        member['name'],
                        style: TextDesign.body.copyWith(fontSize: 16),
                      ),
                      if (member['isAdmin']) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            AppLocalizations.of(context)?.translate('admin') ??
                                'Admin',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: widget.isAdmin && member['name'] != 'You'
                      ? PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: AppColors.mutedText,
                          ),
                          onSelected: (value) {
                            // Member management logic
                          },
                          itemBuilder: (context) => [
                            if (!member['isAdmin'])
                              PopupMenuItem(
                                value: 'promote',
                                child: Text(
                                  AppLocalizations.of(
                                        context,
                                      )?.translate('make_admin') ??
                                      'Make Admin',
                                ),
                              ),
                            PopupMenuItem(
                              value: 'remove',
                              child: Text(
                                AppLocalizations.of(
                                      context,
                                    )?.translate('remove_from_group') ??
                                    'Remove from Group',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),
            const SizedBox(height: 40),

            // Leave Group
            TextButton(
              onPressed: () {
                // Leave Group Logic
              },
              child: Text(
                AppLocalizations.of(context)?.translate('leave_group') ??
                    'Leave Group',
                style: TextDesign.h3.copyWith(color: Colors.red),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
