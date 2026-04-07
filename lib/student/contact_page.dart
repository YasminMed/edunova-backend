import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _subjectController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.translate('send_us_message') ??
                  'Send us a message',
              style: TextDesign.h3.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.translate('contact_subtitle') ??
                  'We would love to hear from you!',
              style: TextDesign.body.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _subjectController,
                    label:
                        AppLocalizations.of(context)?.translate('subject') ??
                        'Subject',
                    hint: 'Report an issue / Feedback',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _messageController,
                    label:
                        AppLocalizations.of(context)?.translate('message') ??
                        'Message',
                    hint: 'Tell us more...',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                      context,
                                    )?.translate('message_sent') ??
                                    'Message sent!',
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.translate('send') ??
                            'Send Message',
                        style: TextDesign.h3.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context)?.translate('other_ways') ??
                  'Other ways to connect',
              style: TextDesign.h3.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            _buildContactInfoTile(Icons.email_outlined, 'support@edunova.com'),
            _buildContactInfoTile(Icons.language_rounded, 'www.edunova.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextDesign.body.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) =>
              value!.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildContactInfoTile(IconData icon, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextDesign.body.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
