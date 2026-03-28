import 'package:flutter/material.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

import '../services/material_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class StudentChallengesPage extends StatefulWidget {
  const StudentChallengesPage({super.key});

  @override
  State<StudentChallengesPage> createState() => _StudentChallengesPageState();
}

class _StudentChallengesPageState extends State<StudentChallengesPage> {
  final MaterialService _materialService = MaterialService();
  bool _isLoading = true;
  Map<String, dynamic> _status = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStatus();
    });
  }

  Future<void> _fetchStatus() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final email = userProvider.email;
      if (email == null) return;
      final data = await _materialService.getWeeklyChallengeStatus(email);
      if (mounted) {
        setState(() {
          _status = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(body: Center(child: Text(_errorMessage!)));
    }

    final quizCurr = _status['quizzes']?['current'] ?? 0;
    final quizTarget = _status['quizzes']?['target'] ?? 3;
    final assignCurr = _status['assignments']?['current'] ?? 0;
    final assignTarget = _status['assignments']?['target'] ?? 5;
    final attRate = (_status['attendance']?['current_rate'] ?? 0.0).toDouble();
    final attTarget = (_status['attendance']?['target_rate'] ?? 0.8).toDouble();
    final totalMarks = _status['total_marks'] ?? 0;

    // Overall progress for the big card (just a simple average or count)
    double overallProgress = (quizCurr + assignCurr + (attRate >= attTarget ? 1 : 0)) / (quizTarget + assignTarget + 1);

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
      body: RefreshIndicator(
        onRefresh: _fetchStatus,
        child: SingleChildScrollView(
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
                            "Total Academic Marks: $totalMarks",
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
                      "Weekly Master Challenge",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Complete all tasks this week to earn 2 bonus academic marks!",
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Overall Tasks Progress",
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        Text(
                          "${(overallProgress * 100).toInt()}%",
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
                        value: overallProgress.clamp(0.0, 1.0),
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
                    "Weekly Tasks",
                style: TextDesign.h2.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailedTaskCard(
                context,
                "Submit Quizzes",
                "$quizCurr/$quizTarget",
                (quizCurr / quizTarget).clamp(0.0, 1.0),
                const Color(0xFF10B981), // Emerald
                Icons.quiz_rounded,
                "Goal: Submit $quizTarget quizzes this week.",
              ),
              const SizedBox(height: 12),
              _buildDetailedTaskCard(
                context,
                "Submit Assignments",
                "$assignCurr/$assignTarget",
                (assignCurr / assignTarget).clamp(0.0, 1.0),
                const Color(0xFFF59E0B), // Amber
                Icons.assignment_turned_in_rounded,
                "Goal: Submit $assignTarget assignments this week.",
              ),
              const SizedBox(height: 12),
              _buildDetailedTaskCard(
                context,
                "Weekly Attendance",
                "${(attRate * 100).toInt()}%",
                attRate.clamp(0.0, 1.0),
                const Color(0xFFEC4899), // Pink
                Icons.event_available_rounded,
                "Goal: Maintain at least ${(attTarget * 100).toInt()}% attendance.",
              ),
            ],
          ),
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
