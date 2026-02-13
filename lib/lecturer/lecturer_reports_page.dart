import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';

class LecturerReportsPage extends StatefulWidget {
  const LecturerReportsPage({super.key});

  @override
  State<LecturerReportsPage> createState() => _LecturerReportsPageState();
}

class _LecturerReportsPageState extends State<LecturerReportsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.primaryText;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Faculty Reports",
          style: TextDesign.h2.copyWith(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportSummary(isDark),
            const SizedBox(height: 30),
            Text(
              "Monthly Insights",
              style: TextDesign.h2.copyWith(color: textColor),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              "Student Progress",
              "8% increase in average marks compared to last month",
              Icons.trending_up,
              Colors.green,
            ),
            _buildInsightItem(
              "Material Engagement",
              "Assignments have 94% submission rate",
              Icons.assignment_turned_in,
              Colors.blue,
            ),
            _buildInsightItem(
              "Course Feedback",
              "Students requested more video content in Quizzes",
              Icons.feedback_rounded,
              Colors.orange,
            ),
            const SizedBox(height: 30),
            _buildDownloadSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Overall Success Rate",
                style: TextStyle(color: Colors.white70),
              ),
              Icon(Icons.more_horiz, color: Colors.white),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "89.5%",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat("A Grades", "42"),
              _buildSimpleStat("B Grades", "68"),
              _buildSimpleStat("C Grades", "30"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
    String title,
    String desc,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.picture_as_pdf_rounded,
            color: AppColors.secondary,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            "Generate Full Academic Report",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            "PDF format, includes all subject statistics",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Download Report",
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
