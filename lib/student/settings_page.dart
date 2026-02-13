import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import 'support_page.dart';
import 'contact_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

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
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 30),

            // General Section
            Text(
              AppLocalizations.of(context)?.translate('general') ?? 'General',
              style: TextDesign.h3.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 10),

            // Dark Mode
            _buildSwitchTile(
              title:
                  AppLocalizations.of(context)?.translate('dark_mode') ??
                  'Dark Mode',
              icon: Icons.dark_mode_rounded,
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),

            // Notifications
            _buildSwitchTile(
              title:
                  AppLocalizations.of(context)?.translate('notifications') ??
                  'Notifications',
              icon: Icons.notifications_active_rounded,
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? AppLocalizations.of(
                                  context,
                                )?.translate('notifications_unmuted') ??
                                'Notifications Unmuted'
                          : AppLocalizations.of(
                                  context,
                                )?.translate('notifications_muted') ??
                                'Notifications Muted',
                    ),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),

            // Language
            _buildLanguageTile(localeProvider),

            const SizedBox(height: 30),

            // Support Section
            Text(
              AppLocalizations.of(context)?.translate('support') ?? 'Support',
              style: TextDesign.h3.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 10),

            _buildActionTile(
              title:
                  AppLocalizations.of(context)?.translate('about_app') ??
                  'About App',
              icon: Icons.info_outline_rounded,
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'EduNova',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    Icons.school_rounded,
                    size: 50,
                    color: AppColors.primary,
                  ),
                  children: [
                    Text(
                      AppLocalizations.of(
                            context,
                          )?.translate('about_app_description') ??
                          'EduNova is a comprehensive educational platform...',
                      style: TextDesign.body,
                      textAlign: TextAlign.justify,
                    ),
                  ],
                );
              },
            ),

            _buildActionTile(
              title:
                  AppLocalizations.of(context)?.translate('contact_us') ??
                  'Contact Us',
              icon: Icons.mail_outline_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsPage(),
                  ),
                );
              },
            ),

            _buildActionTile(
              title:
                  AppLocalizations.of(context)?.translate('support') ??
                  'Support',
              icon: Icons.help_outline_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupportPage()),
                );
              },
            ),

            _buildActionTile(
              title:
                  AppLocalizations.of(context)?.translate('version') ??
                  'Version',
              icon: Icons.verified_rounded,
              onTap: () {},
              trailing: Text(
                "1.0.0",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: TextDesign.body.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
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
        onTap: onTap,
        title: Text(
          title,
          style: TextDesign.body.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
      ),
    );
  }

  Widget _buildLanguageTile(LocaleProvider localeProvider) {
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
        title: Text(
          AppLocalizations.of(context)?.translate('language') ?? 'Language',
          style: TextDesign.body.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.language_rounded, color: AppColors.primary),
        ),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: localeProvider.locale.languageCode,
            icon: const Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.primary,
            ),
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text(
                  AppLocalizations.of(context)?.translate('english') ??
                      'English',
                ),
              ),
              DropdownMenuItem(
                value: 'ar',
                child: Text(
                  AppLocalizations.of(context)?.translate('arabic') ?? 'Arabic',
                ),
              ),
              DropdownMenuItem(
                value: 'ckb',
                child: Text(
                  AppLocalizations.of(context)?.translate('kurdish') ??
                      'Kurdish',
                ),
              ),
            ],
            onChanged: (String? newValue) {
              if (newValue != null) {
                localeProvider.setLocale(Locale(newValue));
              }
            },
          ),
        ),
      ),
    );
  }
}
