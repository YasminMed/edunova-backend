import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../student/support_page.dart';
import '../student/contact_page.dart';

class LecturerSettingsPage extends StatefulWidget {
  const LecturerSettingsPage({super.key});

  @override
  State<LecturerSettingsPage> createState() => _LecturerSettingsPageState();
}

class _LecturerSettingsPageState extends State<LecturerSettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.translate('settings_page') ??
                  'Settings',
              style: TextDesign.h1.copyWith(
                color: isDark ? Colors.white : AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 30),
            _buildSectionTitle('General'),

            _buildSwitchTile(
              title:
                  AppLocalizations.of(context)?.translate('dark_mode') ??
                  'Dark Mode',
              icon: Icons.dark_mode_rounded,
              value: themeProvider.isDarkMode,
              onChanged: (v) => themeProvider.toggleTheme(v),
            ),

            _buildSwitchTile(
              title:
                  AppLocalizations.of(context)?.translate('notifications') ??
                  'Notifications',
              icon: Icons.notifications_active_rounded,
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),

            _buildLanguageTile(localeProvider),

            const SizedBox(height: 30),
            _buildSectionTitle('Support & Info'),

            _buildActionTile(
              title: 'About EduNova',
              icon: Icons.info_outline_rounded,
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'EduNova Lecturer',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    Icons.school,
                    color: AppColors.secondary,
                  ),
                );
              },
            ),

            _buildActionTile(
              title:
                  AppLocalizations.of(context)?.translate('contact_us') ??
                  'Contact Us',
              icon: Icons.mail_outline_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactUsPage()),
              ),
            ),

            _buildActionTile(
              title:
                  AppLocalizations.of(context)?.translate('support') ??
                  'Support',
              icon: Icons.help_outline_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: TextDesign.h3.copyWith(color: AppColors.secondary),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextDesign.body.copyWith(
            color: isDark ? Colors.white : AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: AppColors.secondary),
        activeColor: AppColors.secondary,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.secondary),
        title: Text(
          title,
          style: TextDesign.body.copyWith(
            color: isDark ? Colors.white : AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLanguageTile(LocaleProvider localeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.language_rounded, color: AppColors.secondary),
        title: Text(
          AppLocalizations.of(context)?.translate('language') ?? 'Language',
          style: TextDesign.body.copyWith(
            color: isDark ? Colors.white : AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: localeProvider.locale.languageCode,
            onChanged: (v) {
              if (v != null) localeProvider.setLocale(Locale(v));
            },
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ar', child: Text('Arabic')),
              DropdownMenuItem(value: 'ckb', child: Text('Kurdish')),
            ],
          ),
        ),
      ),
    );
  }
}
