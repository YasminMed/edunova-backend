import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../auth/change_password_lecturer.dart';
import '../auth/welcome_page.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import 'package:file_picker/file_picker.dart';

class LecturerProfilePage extends StatefulWidget {
  const LecturerProfilePage({super.key});

  @override
  State<LecturerProfilePage> createState() => _LecturerProfilePageState();
}

class _LecturerProfilePageState extends State<LecturerProfilePage> {
  final AuthService _authService = AuthService();

  void _showEditNameDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final TextEditingController nameController = TextEditingController(
      text: userProvider.fullName,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.translate('edit_name') ?? 'Edit Name',
          style: TextDesign.h3.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
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
            onPressed: () async {
              final userProvider = context.read<UserProvider>();
              try {
                await _authService.updateProfile(
                  fullName: nameController.text.trim(),
                  email: userProvider.email!,
                  role: 'lecturer',
                );
                await userProvider.setUser(
                  userProvider.userId!,
                  nameController.text.trim(),
                  userProvider.email!,
                  'lecturer',
                );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)?.translate('name_updated') ??
                          'Name updated successfully',
                    ),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AppLocalizations.of(context)?.translate('save') ?? 'Save',
            ),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final TextEditingController emailController = TextEditingController(
      text: userProvider.email,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.translate('edit_email') ?? 'Edit Email',
          style: TextDesign.h3.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
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
            onPressed: () async {
              final userProvider = context.read<UserProvider>();
              try {
                await _authService.updateProfile(
                  fullName: userProvider.fullName!,
                  email: emailController.text.trim(),
                  role: 'lecturer',
                );

                if (!mounted) return;
                Navigator.pop(context);

                _logoutWithReloginMessage();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AppLocalizations.of(context)?.translate('save') ?? 'Save',
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.translate('logout') ?? 'Logout',
          style: TextDesign.h3.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)?.translate('logout_confirm') ??
              'Are you sure you want to logout?',
          style: TextDesign.body.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
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
              // Clear user provider
              context.read<UserProvider>().clearUser();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomePage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AppLocalizations.of(context)?.translate('logout') ?? 'Logout',
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)?.translate('delete_account') ??
              'Delete Account',
          style: TextDesign.h3.copyWith(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(
                    context,
                  )?.translate('delete_account_confirm') ??
                  'Are you sure you want to delete your account?',
              style: TextDesign.body.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)?.translate('delete_warning') ??
                  'This action cannot be undone.',
              style: TextDesign.body.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
            onPressed: () async {
              final userProvider = context.read<UserProvider>();
              try {
                // Call backend to delete account
                await _authService.deleteAccount(
                  email: userProvider.email!,
                  role: 'lecturer',
                );

                if (!mounted) return;
                userProvider.clearUser();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AppLocalizations.of(context)?.translate('confirm') ?? 'Confirm',
            ),
          ),
        ],
      ),
    );
  }

  void _logoutWithReloginMessage() {
    context.read<UserProvider>().clearUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Email updated. Please login with your new email."),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final userProvider = context.read<UserProvider>();
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      bool hasFile =
          result != null &&
          (kIsWeb
              ? result.files.single.bytes != null
              : result.files.single.path != null);

      if (hasFile) {
        // Show loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading photo...'),
            duration: Duration(seconds: 2),
          ),
        );

        final newPhotoUrl = await _authService.updateProfilePhoto(
          email: userProvider.email!,
          role: 'lecturer',
          filePath: kIsWeb ? null : result.files.single.path,
          bytes: kIsWeb ? result.files.single.bytes : null,
          fileName: result.files.single.name,
        );

        await userProvider.setUser(
          userProvider.userId!,
          userProvider.fullName!,
          userProvider.email!,
          'lecturer',
          department: userProvider.department,
          stage: userProvider.stage,
          photoUrl: newPhotoUrl,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.translate('photo_updated') ??
                  'Photo updated successfully',
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final name = userProvider.fullName ?? "Lecturer";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: userProvider.photoUrl != null
                        ? NetworkImage(
                            userProvider.photoUrl!.startsWith('http')
                                ? userProvider.photoUrl!
                                : "${AuthService.baseUrl}${userProvider.photoUrl!}",
                          )
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: userProvider.photoUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                GestureDetector(
                  onTap: _pickAndUploadPhoto,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: TextDesign.h2.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              AppLocalizations.of(context)?.translate('lecturer') ?? 'Lecturer',
              style: TextDesign.body.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 40),

            // Actions
            _buildProfileItem(
              icon: Icons.edit_rounded,
              title:
                  AppLocalizations.of(context)?.translate('edit_name') ??
                  'Edit Name',
              onTap: _showEditNameDialog,
            ),
            _buildProfileItem(
              icon: Icons.email_outlined,
              title:
                  AppLocalizations.of(context)?.translate('edit_email') ??
                  'Edit Email',
              onTap: _showEditEmailDialog,
            ),
            _buildProfileItem(
              icon: Icons.lock_outline_rounded,
              title:
                  AppLocalizations.of(context)?.translate('change_password') ??
                  'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordLecturerPage(),
                  ),
                );
              },
            ),
            _buildProfileItem(
              icon: Icons.logout_rounded,
              title:
                  AppLocalizations.of(context)?.translate('logout') ?? 'Logout',
              onTap: _logout,
              color: Colors.orange,
            ),
            _buildProfileItem(
              icon: Icons.delete_outline_rounded,
              title:
                  AppLocalizations.of(context)?.translate('delete_account') ??
                  'Delete Account',
              onTap: _deleteAccount,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.secondary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        tileColor: Theme.of(context).cardColor,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextDesign.h3.copyWith(
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}
