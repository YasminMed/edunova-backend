import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class SavedMessagesPage extends StatelessWidget {
  const SavedMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> savedMessages = [
      {
        'name': 'Dr. Sarah Smith',
        'message': 'Please submit your assignment by Friday.',
        'time': 'Oct 12',
        'avatarColor': Colors.blueAccent,
      },
      {
        'name': 'Programming Group',
        'message': 'The link to the resource is https://example.com/flutter',
        'time': 'Oct 10',
        'avatarColor': Colors.purple,
      },
      {
        'name': 'Alice Johnson',
        'message': 'See you at the study session!',
        'time': 'Oct 08',
        'avatarColor': Colors.orange,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.translate('saved_messages') ?? 'Saved Messages',
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
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        itemCount: savedMessages.length,
        itemBuilder: (context, index) {
          final msg = savedMessages[index];
          return _buildSavedMessageTile(context, msg);
        },
      ),
    );
  }

  Widget _buildSavedMessageTile(
    BuildContext context,
    Map<String, dynamic> msg,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: (msg['avatarColor'] as Color).withOpacity(0.2),
            child: Icon(
              Icons.person_rounded,
              color: msg['avatarColor'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      msg['name'],
                      style: TextDesign.h3.copyWith(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      msg['time'],
                      style: TextDesign.body.copyWith(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  msg['message'],
                  style: TextDesign.body.copyWith(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
