import 'package:flutter/material.dart';
import 'dart:ui';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../services/material_service.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

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
  Map<int, dynamic> _userSubmissions = {};
  Set<int> _activeEditStates = {};
  bool _isLoading = true;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      if (controller != null) controller.dispose();
    }
    super.dispose();
  }

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
      final category = filters[_selectedFilterIndex];
      
      if (category == "Assignments") {
        final assignments = await _materialService.getAssignments(widget.lecture['id']);
        setState(() => _resources = assignments);
        
        final userEmail = Provider.of<UserProvider>(context, listen: false).email;
        if (userEmail != null) {
          for (var assignment in assignments) {
            try {
              final sub = await _materialService.getMySubmission(assignment['id'], userEmail);
              if (sub != null) {
                setState(() => _userSubmissions[assignment['id']] = sub);
              }
            } catch (e) {
              debugPrint("Error loading submission for ${assignment['id']}: $e");
            }
          }
        }
      } else {
        final response = await _materialService.getResources(
          widget.lecture['id'],
          category: category,
        );
        setState(() => _resources = response);
      }
      setState(() => _isLoading = false);
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
    final color = widget.lecture['color'] as Color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (_selectedFilterIndex) {
      case 0: // PDFs
        return _buildResourceList(
          context,
          Icons.picture_as_pdf_rounded,
          'PDFs',
          color,
          isDark,
        );
      case 1: // Assignments
        return _buildResourceList(
          context,
          Icons.assignment_rounded,
          'Assignments',
          color,
          isDark,
        );
      case 2: // Quizzes
        return _buildResourceList(
          context,
          Icons.quiz_rounded,
          'Quizzes',
          color,
          isDark,
        );
      case 3: // Exams
        return _buildResourceList(
          context,
          Icons.school_rounded,
          'Exams',
          color,
          isDark,
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

  Widget _buildResourceList(
    BuildContext context,
    IconData icon,
    String categoryName,
    Color color,
    bool isDark,
  ) {
    if (_resources.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.folder_open_rounded,
                  size: 64, color: color.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text("No $categoryName uploaded yet.",
                  style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final resource = _resources[index];
        final isAssignmentOrQuiz = _selectedFilterIndex == 1 || _selectedFilterIndex == 2;
        final isExam = _selectedFilterIndex == 3;
        final submission = isAssignmentOrQuiz ? _userSubmissions[resource['id']] : null;
        
        TextEditingController? controller;
        if (isAssignmentOrQuiz) {
            controller = _controllers.putIfAbsent(resource['id'], () => TextEditingController());
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.primaryText,
                          ),
                        ),
                        Text(
                          resource['created_at'] != null
                            ? "Shared on ${resource['created_at'].toString().split('T')[0]}"
                            : "Shared recently",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (submission != null && submission['is_graded'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Grade: ${submission['grade']}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    )
                  else if (submission != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Uploaded",
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                ],
              ),
              if (isAssignmentOrQuiz) ...[
                const SizedBox(height: 12),
                Text(
                  resource['content'] ?? "",
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey[700]),
                ),
                if (resource['file_url'] != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(Icons.attach_file_rounded, size: 14, color: color),
                        const SizedBox(width: 4),
                        const Text("Reference Material", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Your answer here...",
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = Provider.of<UserProvider>(context, listen: false).email;
                      if (email != null && controller != null && controller.text.isNotEmpty) {
                        try {
                          if (isQuiz) {
                            await _materialService.submitQuizSolution(
                              quizId: resource['id'],
                              studentEmail: email,
                              solutionText: controller.text,
                            );
                          } else {
                            await _materialService.submitAssignmentSolution(
                              assignmentId: resource['id'],
                              studentEmail: email,
                              solutionText: controller.text,
                            );
                          }
                          _loadContent(); // Refresh
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(isQuiz ? 'Quiz Submitted Successfully' : 'Assignment Submitted Successfully'),
                              backgroundColor: Colors.green,
                            ));
                          }
                        } catch(e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit. Check backend connection.')));
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: submission != null ? Colors.orange : color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(submission != null ? "Edit Submission" : "Submit Answer"),
                  ),
                ),
                if (submission != null && (submission['is_graded'] == true || submission['is_graded'] == 1)) ...[
                  const Divider(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text("Lecturer Feedback", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                          ],
                        ),
                        if (submission['lecturer_note'] != null && submission['lecturer_note'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Grade: ${submission['grade']} - Note: ${submission['lecturer_note']}",
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                          ),
                        ]
                      ],
                    ),
                  ),
                ]
              ],
            ],
          ),
        );
      }, childCount: _resources.length),
    );
  }

  

}
