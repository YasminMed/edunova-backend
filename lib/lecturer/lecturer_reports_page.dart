import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String? _selectedDepartment;
  String? _selectedStage;
  List<String> _deptList = [];
  List<String> _stageList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFilters();
      _fetchReportData();
    });
  }

  void _initFilters() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.department != null) {
      _deptList = userProvider.department!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (userProvider.stage != null) {
      _stageList = userProvider.stage!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    setState(() {});
  }

  Future<void> _fetchReportData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email == null) return;

    setState(() => _isLoading = true);

    try {
      final data = await _materialService.fetchFacultyReports(
        userProvider.email!,
        department: _selectedDepartment,
        stage: _selectedStage,
      );
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
                    _buildFilterSection(isDark),
                    const SizedBox(height: 24),
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


  Widget _buildFilterSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Filter Reports",
              style: TextDesign.h3.copyWith(
                color: isDark ? Colors.white : AppColors.primaryText,
              ),
            ),
            if (_selectedDepartment != null || _selectedStage != null)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedDepartment = null;
                    _selectedStage = null;
                  });
                  _fetchReportData();
                },
                icon: const Icon(Icons.clear_rounded, size: 16, color: Colors.redAccent),
                label: const Text(
                  "Clear Filters",
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFilterDropdown(
                label: "Department",
                value: _selectedDepartment,
                items: _deptList,
                onChanged: (val) {
                  setState(() => _selectedDepartment = val);
                  _fetchReportData();
                },
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFilterDropdown(
                label: "Stage",
                value: _selectedStage,
                items: _stageList,
                onChanged: (val) {
                  setState(() => _selectedStage = val);
                  _fetchReportData();
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey[200]!,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          isExpanded: true,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }
}
