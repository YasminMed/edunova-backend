import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final TextEditingController _nameController = TextEditingController();
  final List<Map<String, dynamic>> _friends = [
    {'name': 'Dr. Sarah Smith', 'selected': false, 'avatarColor': Colors.blue},
    {'name': 'John Doe', 'selected': false, 'avatarColor': Colors.green},
    {'name': 'Alice Johnson', 'selected': false, 'avatarColor': Colors.orange},
    {'name': 'Bob Wilson', 'selected': false, 'avatarColor': Colors.purple},
    {'name': 'Emily Davis', 'selected': false, 'avatarColor': Colors.teal},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createGroup() {
    if (_nameController.text.trim().isEmpty) return;

    // final selectedMembers = _friends.where((f) => f['selected']).toList();
    // Simulate group creation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(
                context,
              )?.translate('group_created_successfully') ??
              'Group created successfully!',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.translate('create_group') ??
                    'Create Group',
                style: TextDesign.h2,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Group Image Placeholder
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
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
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)?.translate('tap_to_change_photo') ??
                'Tap to change photo',
            textAlign: TextAlign.center,
            style: TextDesign.body.copyWith(
              color: AppColors.mutedText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),

          // Group Name Input
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText:
                  AppLocalizations.of(context)?.translate('group_name') ??
                  'Group Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
          ),
          const SizedBox(height: 24),

          // Members Selection
          Text(
            AppLocalizations.of(context)?.translate('select_members') ??
                'Select Members',
            style: TextDesign.h3,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _friends.length,
              itemBuilder: (context, index) {
                final friend = _friends[index];
                return CheckboxListTile(
                  value: friend['selected'],
                  activeColor: AppColors.primary,
                  onChanged: (bool? value) {
                    setState(() {
                      friend['selected'] = value!;
                    });
                  },
                  secondary: CircleAvatar(
                    backgroundColor: friend['avatarColor'],
                    radius: 18,
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(friend['name'], style: TextDesign.body),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Create Button
          ElevatedButton(
            onPressed: _createGroup,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              shadowColor: AppColors.primary.withOpacity(0.4),
            ),
            child: Text(
              AppLocalizations.of(context)?.translate('create') ?? 'Create',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
