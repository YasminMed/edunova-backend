import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.translate('contact_us') ?? 'Contact Us',
          style: TextDesign.h2.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.headset_mic_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)?.translate('how_can_we_help') ??
                  "How can we help you?",
              style: TextDesign.h2.copyWith(
                color: isDark ? Colors.white : AppColors.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(
                    context,
                  )?.translate('contact_subtitle') ??
                  "Feel free to reach out to us through any of these platforms.",
              style: TextDesign.body.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Social & Contact Links
            _buildContactItem(
              context,
              icon: Icons.email_rounded,
              title: "Email Support",
              subtitle: "support@edunova.com",
              onTap: () => _launchURL('mailto:support@edunova.com'),
            ),
            _buildContactItem(
              context,
              icon: Icons.language_rounded,
              title: "Visit Website",
              subtitle: "www.edunova.com",
              onTap: () => _launchURL('https://www.edunova.com'),
            ),
            _buildContactItem(
              context,
              icon: Icons.camera_alt_rounded,
              title: "Instagram",
              subtitle: "@edunova_app",
              onTap: () => _launchURL('https://instagram.com/edunova_app'),
            ),
            _buildContactItem(
              context,
              icon: Icons.facebook_rounded,
              title: "Facebook",
              subtitle: "EduNova Official",
              onTap: () => _launchURL('https://facebook.com/edunova'),
            ),
            _buildContactItem(
              context,
              icon: Icons.snapchat_rounded,
              title: "Snapchat",
              subtitle: "edunova_team",
              onTap: () => _launchURL('https://www.snapchat.com/add/edunova'),
            ),

            const SizedBox(height: 40),
            Text(
              "EduNova Education © 2026",
              style: TextDesign.caption.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          title: Text(
            title,
            style: TextDesign.body.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primaryText,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextDesign.caption.copyWith(color: Colors.grey),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
