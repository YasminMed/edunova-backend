import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../services/material_service.dart';
import '../providers/user_provider.dart';

class StudentAnalysisPage extends StatefulWidget {
  const StudentAnalysisPage({super.key});

  @override
  State<StudentAnalysisPage> createState() => _StudentAnalysisPageState();
}

class _StudentAnalysisPageState extends State<StudentAnalysisPage> {
  final MaterialService _materialService = MaterialService();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _analysisData;

  String _selectedDepartment = 'All';
  String _selectedStage = 'All';
  List<String> _availableDepartments = ['All'];
  List<String> _availableStages = ['All'];

  @override
  void initState() {
    super.initState();
    _initFilters();
    _loadAnalysis();
  }

  void _initFilters() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.department != null) {
      final depts = userProvider.department!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      _availableDepartments.addAll(depts);
    }
    if (userProvider.stage != null) {
      final stages = userProvider.stage!
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      _availableStages.addAll(stages);
    }
  }

  Future<void> _loadAnalysis() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final email = userProvider.email;

    if (email == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Lecturer email not found";
      });
      return;
    }

    try {
      final data = await _materialService.fetchStudentAnalysis(
        email,
        department: _selectedDepartment == 'All' ? null : _selectedDepartment,
        stage: _selectedStage == 'All' ? null : _selectedStage,
      );
      setState(() {
        _analysisData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
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
          "Student Analysis",
          style: TextDesign.h2.copyWith(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            )
          : RefreshIndicator(
              onRefresh: _loadAnalysis,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilters(isDark),
                    const SizedBox(height: 24),
                    _buildChartCard(isDark),
                    const SizedBox(height: 32),
                    Text(
                      "Attendance Analytics",
                      style: TextDesign.h2.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    _buildAttendanceAnalytics(isDark),
                    const SizedBox(height: 32),
                    Text(
                      "Detailed Statistics",
                      style: TextDesign.h2.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    _buildStatGrid(isDark),
                    const SizedBox(height: 32),
                    Text(
                      "Top Performers",
                      style: TextDesign.h2.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 16),
                    _buildTopPerformers(isDark),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildChartCard(bool isDark) {
    final trend =
        (_analysisData?['performance_trend'] as List?)?.cast<num>() ??
        [0, 0, 0, 0, 0, 0, 0];
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return Container(
      padding: const EdgeInsets.all(24),
      height: 320,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Class Performance Trend",
            style: TextDesign.h3.copyWith(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= days.length)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[index],
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: trend
                        .asMap()
                        .entries
                        .map(
                          (e) => FlSpot(e.key.toDouble(), e.value.toDouble()),
                        )
                        .toList(),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, Color(0xFF38BDF8)],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: AppColors.secondary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.2),
                          AppColors.secondary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceAnalytics(bool isDark) {
    final stats = _analysisData?['attendance_analytics'] ?? {};
    final attended = (stats['attended'] ?? 0.0) / 100.0;
    final late = (stats['late'] ?? 0.0) / 100.0;
    final absent = (stats['absent'] ?? 0.0) / 100.0;
    final avgRate = stats['average_rate'] ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttendanceCircle("Attended", attended, Colors.green),
              _buildAttendanceCircle("Late", late, Colors.orange),
              _buildAttendanceCircle("Absent", absent, Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Average Attendance Rate: ${avgRate.toStringAsFixed(0)}%",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCircle(String label, double percentage, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 70,
              width: 70,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color.withOpacity(0.1),
                ),
              ),
            ),
            SizedBox(
              height: 70,
              width: 70,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        Text(
          "${(percentage * 100).toInt()}%",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid(bool isDark) {
    final stats = _analysisData?['detailed_stats'] ?? {};
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildMiniStat(
          "Average Mark",
          "${stats['average_mark'] ?? 0}%",
          Icons.star_rounded,
          Colors.green,
        ),
        _buildMiniStat(
          "Engagement",
          "${stats['engagement'] ?? 0}%",
          Icons.bolt_rounded,
          Colors.amber,
        ),
        _buildMiniStat(
          "Attendance",
          "${stats['attendance'] ?? 0}%",
          Icons.calendar_today_rounded,
          Colors.blue,
        ),
        _buildMiniStat(
          "Materials Used",
          "${stats['materials_used'] ?? 0}",
          Icons.book_rounded,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformers(bool isDark) {
    final performers = (_analysisData?['top_performers'] as List?) ?? [];

    if (performers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No performers yet",
            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: performers.map((p) {
        final grade = p['grade'] as String;
        Color gradeColor;
        if (grade.startsWith('A'))
          gradeColor = Colors.green;
        else if (grade.startsWith('B'))
          gradeColor = Colors.blue;
        else if (grade.startsWith('C'))
          gradeColor = Colors.orange;
        else
          gradeColor = Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: gradeColor.withOpacity(0.1),
                child: Text(
                  grade[0],
                  style: TextStyle(
                    color: gradeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                p['name'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              Text(
                grade,
                style: TextStyle(
                  color: gradeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterDropdown(
                label: "Department",
                value: _selectedDepartment,
                items: _availableDepartments,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedDepartment = val);
                    _loadAnalysis();
                  }
                },
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _buildFilterDropdown(
                label: "Stage",
                value: _selectedStage,
                items: _availableStages,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedStage = val);
                    _loadAnalysis();
                  }
                },
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: isDark ? Colors.white60 : Colors.grey,
          ),
          dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
