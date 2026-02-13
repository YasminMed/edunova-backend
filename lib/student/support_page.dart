import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.translate('support') ?? 'Support',
          style: TextDesign.h2.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSupportSection(
            context,
            title:
                AppLocalizations.of(context)?.translate('general_help') ??
                'General Help',
            items: [
              'How to join a group?',
              'How to contact a lecturer?',
              'Where to find my grades?',
            ],
          ),
          const SizedBox(height: 20),
          _buildSupportSection(
            context,
            title:
                AppLocalizations.of(context)?.translate('account_privacy') ??
                'Account & Privacy',
            items: [
              'Changing your email',
              'Resetting your password',
              'Data protection policy',
            ],
          ),
          const SizedBox(height: 20),
          _buildSupportSection(
            context,
            title:
                AppLocalizations.of(context)?.translate('app_features') ??
                'App Features',
            items: [
              'Using the AI Chatbot',
              'Managing notifications',
              'Dark mode settings',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextDesign.h3.copyWith(color: AppColors.primary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: items
                .map(
                  (item) => Column(
                    children: [
                      ListTile(
                        title: Text(
                          item,
                          style: TextDesign.body.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey[400],
                        ),
                        onTap: () {},
                      ),
                      if (item != items.last)
                        Divider(
                          height: 1,
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.1),
                        ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
