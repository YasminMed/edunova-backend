import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../services/material_service.dart';
import '../providers/user_provider.dart';

class LecturerReportsPage extends StatefulWidget {
  const LecturerReportsPage({super.key});

  @override
  State<LecturerReportsPage> createState() => _LecturerReportsPageState();
}

class _LecturerReportsPageState extends State<LecturerReportsPage> {
  final MaterialService _materialService = MaterialService();
  Map<String, dynamic>? _reportData;
  bool _isLoading = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;

    try {
      final data = await _materialService.fetchFacultyReports(userProvider.email!);
      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch report data")),
        );
      }
    }
  }

  Future<void> _downloadReport() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;

    setState(() => _isDownloading = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = "Faculty_Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final filePath = "${directory.path}/$fileName";
      
      final savedPath = await _materialService.downloadFacultyReport(
        userProvider.email!, 
        filePath
      );

      if (savedPath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Report downloaded successfully"),
            action: SnackBarAction(
              label: "Open",
              onPressed: () => OpenFilex.open(savedPath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to download report")),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

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
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchReportData,
              child: SingleChildScrollView(
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
                      _reportData?['insights']['progress'] ?? "No data",
                      Icons.trending_up,
                      Colors.green,
                    ),
                    _buildInsightItem(
                      "Material Engagement",
                      _reportData?['insights']['engagement'] ?? "No data",
                      Icons.assignment_turned_in,
                      Colors.blue,
                    ),
                    _buildInsightItem(
                      "Course Feedback",
                      _reportData?['insights']['feedback'] ?? "No data",
                      Icons.feedback_rounded,
                      Colors.orange,
                    ),
                    const SizedBox(height: 30),
                    _buildDownloadSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildReportSummary(bool isDark) {
    final successRate = _reportData?['success_rate']?.toString() ?? "0";
    final grades = _reportData?['grades'] ?? {"A": 0, "B": 0, "C": 0};

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
          Text(
            "$successRate%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat("A Grades", grades['A'].toString()),
              _buildSimpleStat("B Grades", grades['B'].toString()),
              _buildSimpleStat("C Grades", grades['C'].toString()),
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
          _isDownloading 
            ? const CircularProgressIndicator()
            : TextButton(
                onPressed: _downloadReport,
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
