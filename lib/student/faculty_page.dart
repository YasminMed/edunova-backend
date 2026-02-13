import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class FacultyPage extends StatelessWidget {
  const FacultyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> teachers = [
      {
        'name': 'Dr. Sarah Ahmed',
        'dept': 'Computer Science',
        'exp': 12,
        'image': 'https://i.pravatar.cc/150?u=sarah',
        'color': Colors.blue,
      },
      {
        'name': 'Prof. James Wilson',
        'dept': 'Mathematics',
        'exp': 20,
        'image': 'https://i.pravatar.cc/150?u=james',
        'color': Colors.purple,
      },
      {
        'name': 'Ms. Elena Rodriguez',
        'dept': 'English Literature',
        'exp': 8,
        'image': 'https://i.pravatar.cc/150?u=elena',
        'color': Colors.orange,
      },
      {
        'name': 'Dr. Robert Chen',
        'dept': 'Physics',
        'exp': 15,
        'image': 'https://i.pravatar.cc/150?u=robert',
        'color': Colors.teal,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n?.translate('faculty') ?? 'Teaching Staff',
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
        padding: const EdgeInsets.all(24),
        itemCount: teachers.length,
        itemBuilder: (context, index) {
          return _buildTeacherCard(context, teachers[index]);
        },
      ),
    );
  }

  Widget _buildTeacherCard(BuildContext context, Map<String, dynamic> teacher) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (teacher['color'] as Color).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Teacher Photo with dynamic border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      teacher['color'],
                      (teacher['color'] as Color).withOpacity(0.3),
                    ],
                  ),
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(teacher['image']),
                ),
              ),
              const SizedBox(width: 20),
              // Name and Experience
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher['name'],
                      style: TextDesign.h3.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher['dept'],
                      style: TextDesign.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n
                              ?.translate('years_exp')
                              .replaceAll(
                                '{count}',
                                teacher['exp'].toString(),
                              ) ??
                          "${teacher['exp']} Years Experience",
                      style: TextDesign.body.copyWith(
                        color: AppColors.mutedText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              // View Details - Premium Style
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Coming Soon: ${teacher['name']} Details",
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          teacher['color'],
                          (teacher['color'] as Color).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: (teacher['color'] as Color).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        l10n?.translate('view_details') ?? 'View Details',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Feedback Button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n?.translate('feedback_submitted') ??
                            'Feedback Submitted!',
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.rate_review_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
