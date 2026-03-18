import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../providers/user_provider.dart';
import '../services/chat_service.dart';

class GroupSettingsPage extends StatefulWidget {
  final int groupId;
  final String groupName;
  final String? photoUrl;
  final int adminId;

  const GroupSettingsPage({
    super.key,
    required this.groupId,
    required this.groupName,
    this.photoUrl,
    required this.adminId,
  });

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _nameController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  String? _selectedImagePath;
  
  Map<String, dynamic>? _groupDetails;
  List<dynamic> _members = [];
  late String _currentGroupName;

  @override
  void initState() {
    super.initState();
    _currentGroupName = widget.groupName;
    _nameController.text = _currentGroupName;
    _loadGroupDetails();
  }

  Future<void> _loadGroupDetails() async {
    setState(() => _isLoading = true);
    final details = await _chatService.getGroupDetails(widget.groupId);
    if (details != null && mounted) {
      setState(() {
        _groupDetails = details;
        _members = details['members'] ?? [];
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  bool _isCurrentUserOwner() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_groupDetails == null || userProvider.email == null) return false;
    // Find the owner user entry in members to compare email, or we assume if current user has matched adminId
    // since we don't have current user ID easily available, we check if our email belongs to admin_id.
    final ownerMember = _members.firstWhere(
      (m) => m['id'] == _groupDetails!['admin_id'], 
      orElse: () => null
    );
    return ownerMember != null && ownerMember['email'] == userProvider.email;
  }
  
  String? _getOwnerEmail() {
    if (_groupDetails == null) return null;
    final ownerMember = _members.firstWhere(
      (m) => m['id'] == _groupDetails!['admin_id'], 
      orElse: () => null
    );
    return ownerMember?['email'];
  }

  Future<void> _pickImage() async {
    if (!_isCurrentUserOwner()) return;
    
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedImagePath = result.files.single.path;
      });
    }
  }

  Future<void> _updateGroup() async {
    final ownerEmail = _getOwnerEmail();
    if (ownerEmail == null) return;

    setState(() => _isSaving = true);
    
    final nameToUpdate = _nameController.text.trim() != _currentGroupName 
        ? _nameController.text.trim() 
        : null;

    final success = await _chatService.updateGroupChat(
      widget.groupId, 
      ownerEmail,
      name: nameToUpdate,
      imagePath: _selectedImagePath,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group updated successfully!')),
        );
        Navigator.pop(context, true); // true indicates a refresh is needed
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update group')),
        );
      }
    }
  }

  void _showAddMemberSheet() async {
    final ownerEmail = _getOwnerEmail();
    if (ownerEmail == null) return;

    final allUsers = await _chatService.getAllUsers();
    // Filter out existing members
    final existingEmails = _members.map((m) => m['email'] as String).toList();
    final availableUsers = allUsers.where((u) => !existingEmails.contains(u.email)).toList();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        final List<String> selectedEmails = [];
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Add Members", style: TextDesign.h2),
                  const SizedBox(height: 10),
                  Expanded(
                    child: availableUsers.isEmpty
                        ? const Center(child: Text("No users to add."))
                        : ListView.builder(
                            itemCount: availableUsers.length,
                            itemBuilder: (context, index) {
                              final user = availableUsers[index];
                              final isSelected = selectedEmails.contains(user.email);
                              return CheckboxListTile(
                                activeColor: AppColors.primary,
                                title: Text(user.fullName),
                                subtitle: Text(user.role),
                                value: isSelected,
                                onChanged: (val) {
                                  setSheetState(() {
                                    if (val == true) {
                                      selectedEmails.add(user.email);
                                    } else {
                                      selectedEmails.remove(user.email);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: selectedEmails.isEmpty ? null : () async {
                        Navigator.pop(context); // close sheet
                        setState(() => _isLoading = true);
                        await _chatService.addGroupMembers(widget.groupId, ownerEmail, selectedEmails);
                        _loadGroupDetails();
                      },
                      child: const Text('Add Selected', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Future<void> _removeMember(String memberEmail) async {
    final ownerEmail = _getOwnerEmail();
    if (ownerEmail == null) return;

    setState(() => _isLoading = true);
    await _chatService.removeGroupMember(widget.groupId, ownerEmail, memberEmail);
    _loadGroupDetails();
  }

  Future<void> _transferOwnership(String newOwnerEmail) async {
    final ownerEmail = _getOwnerEmail();
    if (ownerEmail == null) return;

    setState(() => _isLoading = true);
    await _chatService.transferGroupOwnership(widget.groupId, ownerEmail, newOwnerEmail);
    _loadGroupDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final isOwner = _isCurrentUserOwner();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Group Settings",
          style: TextDesign.h3.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        actions: [
          if (isOwner)
            TextButton(
              onPressed: _isSaving ? null : _updateGroup,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: isOwner ? _pickImage : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      backgroundImage: _selectedImagePath != null
                          ? FileImage(File(_selectedImagePath!))
                          : (widget.photoUrl != null ? NetworkImage("${ChatService.baseUrl}${widget.photoUrl}") : null) as ImageProvider?,
                      child: (_selectedImagePath == null && widget.photoUrl == null)
                          ? const Icon(Icons.groups_rounded, size: 50, color: AppColors.primary)
                          : null,
                    ),
                    if (isOwner)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            Text("Group Details", style: TextDesign.h3),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              enabled: isOwner,
              decoration: InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Members", style: TextDesign.h3),
                if (isOwner)
                  TextButton.icon(
                    onPressed: _showAddMemberSheet,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text("Add"),
                  ),
              ],
            ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                final bool isMemberAdmin = member['id'] == _groupDetails!['admin_id'];
                
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withOpacity(0.2),
                    child: const Icon(Icons.person, color: AppColors.secondary),
                  ),
                  title: Text(member['full_name']),
                  subtitle: Text(member['email'] + (isMemberAdmin ? " (Owner)" : "")),
                  trailing: (isOwner && !isMemberAdmin) 
                      ? PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'remove') {
                              _removeMember(member['email']);
                            } else if (val == 'make_owner') {
                              _transferOwnership(member['email']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text('Remove Member', style: TextStyle(color: Colors.red)),
                            ),
                            const PopupMenuItem(
                              value: 'make_owner',
                              child: Text('Make Owner'),
                            ),
                          ],
                        )
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
