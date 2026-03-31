import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../models/chat_session.dart';
import '../providers/user_provider.dart';
import '../services/chat_service.dart';

class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final TextEditingController _nameController = TextEditingController();
  final ChatService _chatService = ChatService();
  
  List<ChatUser> _allUsers = [];
  final List<ChatUser> _selectedUsers = [];
  bool _isLoadingUsers = true;
  String? _selectedImagePath;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _chatService.getAllUsers();
    final currentUserEmail = Provider.of<UserProvider>(context, listen: false).email;
    
    if (mounted) {
      setState(() {
        _allUsers = users.where((u) => u.email != currentUserEmail).toList();
        _isLoadingUsers = false;
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    
    bool hasFile = result != null && (kIsWeb ? result.files.single.bytes != null : result.files.single.path != null);

    if (hasFile) {
      setState(() {
        if (kIsWeb) {
          _selectedImageBytes = result.files.single.bytes;
          _selectedImageName = result.files.single.name;
        } else {
          _selectedImagePath = result.files.single.path;
        }
      });
    }
  }

  void _createGroup() async {
    final groupName = _nameController.text.trim();
    if (groupName.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a group name'), backgroundColor: Colors.red),
       );
       return;
    }
    
    if (_selectedUsers.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one member'), backgroundColor: Colors.red),
       );
       return;
    }

    setState(() => _isCreating = true);

    final currentUserEmail = Provider.of<UserProvider>(context, listen: false).email;
    if (currentUserEmail != null) {
      final memberEmails = _selectedUsers.map((u) => u.email).toList();
      final groupId = await _chatService.createGroupChat(
        groupName, 
        currentUserEmail, 
        memberEmails, 
        imagePath: _selectedImagePath,
        bytes: _selectedImageBytes,
        fileName: _selectedImageName,
      );
      
      if (mounted) {
        setState(() => _isCreating = false);
        if (groupId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.translate('group_created_successfully') ?? 'Group created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // true indicates a refresh is needed
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create group'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)?.translate('create_group') ?? 'Create Group',
                style: TextDesign.h2.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: Theme.of(context).iconTheme.color),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Group Image Placeholder
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      image: (_selectedImageBytes != null || _selectedImagePath != null)
                          ? DecorationImage(
                              image: kIsWeb 
                                  ? MemoryImage(_selectedImageBytes!) as ImageProvider
                                  : FileImage(File(_selectedImagePath!)) as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (_selectedImageBytes == null && _selectedImagePath == null)
                        ? const Icon(
                            Icons.groups_rounded,
                            size: 50,
                            color: AppColors.primary,
                          )
                        : null,
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
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)?.translate('tap_to_change_photo') ?? 'Tap to change photo',
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
              labelText: AppLocalizations.of(context)?.translate('group_name') ?? 'Group Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
          ),
          const SizedBox(height: 24),

          // Members Selection
          Text(
            AppLocalizations.of(context)?.translate('select_members') ?? 'Select Members',
            style: TextDesign.h3.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _isLoadingUsers
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _allUsers.length,
                    itemBuilder: (context, index) {
                      final user = _allUsers[index];
                      final isSelected = _selectedUsers.contains(user);
                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: AppColors.primary,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedUsers.add(user);
                            } else {
                              _selectedUsers.remove(user);
                            }
                          });
                        },
                        secondary: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.5),
                          radius: 18,
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(user.fullName, style: TextDesign.body.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
                        subtitle: Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),

          // Create Button
          _isCreating
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
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
