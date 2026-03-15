import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../services/material_service.dart';

class LectureDetailPage extends StatefulWidget {
  final Map<String, dynamic> lecture;

  const LectureDetailPage({super.key, required this.lecture});

  @override
  State<LectureDetailPage> createState() => _LectureDetailPageState();
}

class _LectureDetailPageState extends State<LectureDetailPage> {
  int _selectedFilterIndex = 0;
  final MaterialService _materialService = MaterialService();
  List<dynamic> _resources = [];
  List<dynamic> _attendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  void _loadContent() {
    if (_selectedFilterIndex < 4) {
      _loadResources();
    } else {
      _loadAttendance();
    }
  }

  Future<void> _loadResources() async {
    setState(() => _isLoading = true);
    try {
      final filters = ["PDFs", "Assignments", "Quizzes", "Exams", "Attendance"];
      final response = await _materialService.getResources(
        widget.lecture['id'],
        category: filters[_selectedFilterIndex],
      );
      setState(() {
        _resources = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    try {
      final response = await _materialService.getAttendance(widget.lecture['id']);
      setState(() {
        _attendance = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = widget.lecture['color'] as Color;

    final List<String> filters = [
      l10n?.translate('pdfs') ?? 'PDFs',
      l10n?.translate('assignments') ?? 'Assignments',
      l10n?.translate('quizzes') ?? 'Quizzes',
      l10n?.translate('exams') ?? 'Exams',
      l10n?.translate('attendance') ?? 'Attendance',
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Silver AppBar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                stretch: true,
                backgroundColor: color,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.lecture['subject'],
                    style: TextDesign.h3.copyWith(color: Colors.white),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(widget.lecture['image'], fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Filter Tabs
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: List.generate(filters.length, (index) {
                        final isSelected = _selectedFilterIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedFilterIndex = index);
                              _loadContent();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? color
                                    : color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Text(
                                filters[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // Content Area
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: _isLoading 
                  ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                  : _buildFilteredContent(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredContent() {
    switch (_selectedFilterIndex) {
      case 0: // PDFs
        return _buildResourceList(
          Icons.picture_as_pdf_rounded,
          'PDF',
          _resources,
        );
      case 1: // Assignments
        return _buildResourceList(
          Icons.assignment_rounded,
          'Assignment',
          _resources,
        );
      case 2: // Quizzes
        return _buildResourceList(
          Icons.quiz_rounded,
          'Quiz',
          _resources,
        );
      case 3: // Exams
        return _buildResourceList(
          Icons.school_rounded,
          'Exam',
          _resources,
        );
      case 4: // Attendance
        return _buildAttendanceView();
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  Widget _buildAttendanceView() {
    final color = widget.lecture['color'] as Color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate interactive rate
    double rate = 0;
    if (_attendance.isNotEmpty) {
      int attended = _attendance.where((a) => a['status'] == 'Attended').length;
      rate = attended / _attendance.length;
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  "Attendance Rate",
                  style: TextDesign.h3.copyWith(color: color),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: CircularProgressIndicator(
                        value: rate,
                        strokeWidth: 12,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Text(
                      "${(rate * 100).toInt()}%",
                      style: TextDesign.h1.copyWith(
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildAttendanceList(),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: _attendance.map((record) {
        Color statusColor = Colors.green;
        if (record['status'] == 'Late') statusColor = Colors.orange;
        if (record['status'] == 'Absent') statusColor = Colors.red;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record['date'].toString().split('T')[0],
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.bodyText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  record['status'] as String,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResourceList(IconData icon, String type, List<dynamic> resources) {
    final color = widget.lecture['color'] as Color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (resources.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text("No $type uploaded yet."),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final resource = resources[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource['title'],
                      style: TextDesign.h3.copyWith(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "Uploaded on ${resource['created_at'].toString().split('T')[0]}",
                      style: TextDesign.body.copyWith(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.download_rounded, color: color),
                onPressed: () {},
              ),
            ],
          ),
        );
      }, childCount: resources.length),
    );
  }
}
