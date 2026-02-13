import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../auth/change_password_student.dart';
import '../auth/welcome_page.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  String _name = "Student Name"; // Mock Name
  String _email = "student@university.com"; // Mock Email

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: _name,
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
            onPressed: () {
              setState(() {
                _name = nameController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)?.translate('name_updated') ??
                        'Name updated successfully',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
    final TextEditingController emailController = TextEditingController(
      text: _email,
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
            onPressed: () {
              setState(() {
                _email = emailController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)?.translate('email_updated') ??
                        'Email updated successfully',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
              // Navigate to Welcome Page and remove all previous routes
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
            onPressed: () {
              // Mock Delete -> Go to Welcome
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomePage()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('account_deleted') ??
                        'Account deleted',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
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

  @override
  Widget build(BuildContext context) {
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
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/300',
                    ), // Mock Image
                    backgroundColor: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Change Photo Logic (Mock)
                  },
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
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _name,
              style: TextDesign.h2.copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Text(
              AppLocalizations.of(context)?.translate('student_role') ??
                  'Student',
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
                    builder: (context) => const ChangePasswordStudentPage(),
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
    Color color = AppColors.primary,
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
