import 'package:flutter/material.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class StudentChallengesPage extends StatelessWidget {
  const StudentChallengesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weekly Challenges",
          style: TextDesign.h2.copyWith(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Challenge Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          AppLocalizations.of(
                                context,
                              )?.translate('assignment_master') ??
                              "Assignment Master",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)
                            ?.translate('solve_assignments')
                            .replaceAll('{count}', '20') ??
                        "Solve 20 Assignments",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(
                          context,
                        )?.translate('complete_tasks_badge') ??
                        "Complete all assigned tasks to earn the 'Problem Solver' badge!",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Progress: 9/20",
                        style: TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      Text(
                        "45%",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: 9 / 20,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context)?.translate('daily_tasks') ??
                  "Daily Tasks",
              style: TextDesign.h2.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailedTaskCard(
              context,
              AppLocalizations.of(context)?.translate('daily_quiz') ??
                  "Daily Quiz",
              "1/3",
              0.33,
              const Color(0xFF10B981), // Emerald
              Icons.quiz_rounded,
              AppLocalizations.of(context)?.translate('test_knowledge') ??
                  "Test your knowledge with quick daily quizzes.",
            ),
            const SizedBox(height: 12),
            _buildDetailedTaskCard(
              context,
              AppLocalizations.of(context)?.translate('attendance') ??
                  "Attendance",
              "4/5",
              0.8,
              const Color(0xFFF59E0B), // Amber
              Icons.event_available_rounded,
              AppLocalizations.of(context)?.translate('maintain_attendance') ??
                  "Maintain high attendance to unlock extra credits.",
            ),
            const SizedBox(height: 12),
            _buildDetailedTaskCard(
              context,
              AppLocalizations.of(context)?.translate('reading') ?? "Reading",
              "2/4",
              0.5,
              const Color(0xFFEC4899), // Pink
              Icons.menu_book_rounded,
              AppLocalizations.of(context)?.translate('complete_reading') ??
                  "Complete your weekly reading assignments.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTaskCard(
    BuildContext context,
    String title,
    String progress,
    double pValue,
    Color color,
    IconData icon,
    String desc,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
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
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      progress,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: pValue,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
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
