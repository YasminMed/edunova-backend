import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';

class LectureDetailPage extends StatefulWidget {
  final Map<String, dynamic> lecture;

  const LectureDetailPage({super.key, required this.lecture});

  @override
  State<LectureDetailPage> createState() => _LectureDetailPageState();
}

class _LectureDetailPageState extends State<LectureDetailPage> {
  int _selectedFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = widget.lecture['color'] as Color;

    final List<String> filters = [
      l10n?.translate('pdfs') ?? 'PDFs',
      l10n?.translate('videos') ?? 'Videos',
      l10n?.translate('assignments') ?? 'Assignments',
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
                            onTap: () =>
                                setState(() => _selectedFilterIndex = index),
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
                sliver: _buildFilteredContent(),
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
          'Lecture Material',
        );
      case 1: // Videos
        return _buildResourceList(
          Icons.play_circle_fill_rounded,
          'Session Recording',
        );
      case 2: // Assignments
        return _buildAssignmentList();
      case 3: // Exams
        return _buildExamList();
      case 4: // Attendance
        return _buildAttendanceView();
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  Widget _buildAttendanceView() {
    final color = widget.lecture['color'] as Color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        value: 0.94,
                        strokeWidth: 12,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    Text(
                      "94%",
                      style: TextDesign.h1.copyWith(
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Excellent! Keep showing up."),
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

    final records = [
      {'date': 'Oct 20, 2025', 'status': 'Attended', 'color': Colors.green},
      {'date': 'Oct 18, 2025', 'status': 'Late', 'color': Colors.orange},
      {'date': 'Oct 15, 2025', 'status': 'Attended', 'color': Colors.green},
      {'date': 'Oct 13, 2025', 'status': 'Absent', 'color': Colors.red},
    ];

    return Column(
      children: records.map((record) {
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
                record['date'] as String,
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
                  color: (record['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  record['status'] as String,
                  style: TextStyle(
                    color: record['color'] as Color,
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

  Widget _buildResourceList(IconData icon, String suffix) {
    final color = widget.lecture['color'] as Color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
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
                      "${widget.lecture['subject']} $suffix ${index + 1}",
                      style: TextDesign.h3.copyWith(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      "Uploaded on Oct ${10 + index}, 2025",
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
      }, childCount: 5),
    );
  }

  Widget _buildAssignmentList() {
    final l10n = AppLocalizations.of(context);
    final color = widget.lecture['color'] as Color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final assignments = [
      {
        'title': 'Analysis Report',
        'submitted': true,
        'deadline': 'Oct 25, 2025',
      },
      {
        'title': 'Weekly Practice',
        'submitted': false,
        'deadline': 'Oct 30, 2025',
      },
      {'title': 'Case Study', 'submitted': true, 'deadline': 'Nov 02, 2025'},
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final assignment = assignments[index];
        final isSubmitted = assignment['submitted'] as bool;

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
                  color: (isSubmitted ? Colors.green : Colors.orange)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSubmitted
                      ? Icons.check_circle_rounded
                      : Icons.pending_actions_rounded,
                  color: isSubmitted ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment['title'] as String,
                      style: TextDesign.h3.copyWith(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (isSubmitted ? Colors.green : Colors.orange)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isSubmitted
                                ? (l10n?.translate('submitted') ?? 'Submitted')
                                : (l10n?.translate('not_submitted') ??
                                      'Not Submitted'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSubmitted ? Colors.green : Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${l10n?.translate('deadline') ?? 'Deadline'}: ${assignment['deadline']}",
                          style: TextDesign.body.copyWith(
                            fontSize: 11,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppColors.mutedText,
              ),
            ],
          ),
        );
      }, childCount: assignments.length),
    );
  }

  Widget _buildExamList() {
    final l10n = AppLocalizations.of(context);
    final color = widget.lecture['color'] as Color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final exams = [
      {
        'title': l10n?.translate('midterm') ?? 'Midterm',
        'icon': Icons.assignment_rounded,
        'date': 'Nov 15, 2025',
        'hall': 'Main Hall A',
      },
      {
        'title': l10n?.translate('final_exam') ?? 'Final',
        'icon': Icons.school_rounded,
        'date': 'Jan 20, 2026',
        'hall': 'Grand Audit B',
      },
      {
        'title': l10n?.translate('quiz') ?? 'Quiz',
        'icon': Icons.quiz_rounded,
        'date': 'Dec 05, 2025',
        'hall': 'Exam Hall 3',
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final exam = exams[index];
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
                child: Icon(exam['icon'] as IconData, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam['title'] as String,
                      style: TextDesign.h3.copyWith(
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: AppColors.mutedText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          exam['date'] as String,
                          style: TextDesign.body.copyWith(
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on_rounded, size: 12, color: color),
                        const SizedBox(width: 4),
                        Text(
                          "${l10n?.translate('hall') ?? 'Hall'}: ${exam['hall']}",
                          style: TextDesign.body.copyWith(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline_rounded, color: color, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${exam['title']} at ${exam['hall']} on ${exam['date']}",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }, childCount: exams.length),
    );
  }
}
