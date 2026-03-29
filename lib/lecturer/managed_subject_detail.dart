import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import 'dart:ui';
import '../viewmodels/lecturer/managed_subject_viewmodel.dart';
import 'assignment_review_page.dart';
import 'add_material_dialog.dart';

class ManagedSubjectDetailPage extends StatelessWidget {
  final Map<String, dynamic> subject;

  const ManagedSubjectDetailPage({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = subject['color'] as Color;

    return Consumer<ManagedSubjectViewModel>(
      builder: (context, viewModel, child) {
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
                  SliverAppBar(
                    expandedHeight: 180,
                    pinned: true,
                    backgroundColor: color,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        subject['name'],
                        style: TextDesign.h3.copyWith(color: Colors.white),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (subject['image'] != null)
                            Image.network(
                              subject['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: color.withOpacity(0.8)),
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [color, color.withOpacity(0.8)],
                                ),
                              ),
                            ),
                          // Overlay for better text readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.35),
                                ],
                              ),
                            ),
                          ),
                          if (subject['image'] == null)
                            Center(
                              child: Icon(
                                subject['icon'] ?? Icons.book_rounded,
                                size: 60,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildFilterBar(viewModel, color, isDark),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: _buildFilteredContent(
                      context,
                      viewModel,
                      color,
                      isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterBar(
    ManagedSubjectViewModel viewModel,
    Color color,
    bool isDark,
  ) {
    const activeColor = Color(0xFF009688); // Teal color from design
    final inactiveColor = activeColor.withOpacity(0.12);

    return Container(
      height: 65,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: viewModel.filters.length,
        itemBuilder: (context, index) {
          final isSelected = viewModel.selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
            onTap: () => viewModel.setFilterIndex(
              index, 
              subject['id'], 
              department: subject['department'], 
              stage: subject['stage']
            ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    viewModel.filters[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : activeColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilteredContent(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    Color color,
    bool isDark,
  ) {
    switch (viewModel.selectedFilterIndex) {
      case 0: // PDFs
        return _buildResourceList(
          context,
          Icons.picture_as_pdf_rounded,
          "PDFs",
          color,
          isDark,
          viewModel.resources,
          viewModel,
        );
      case 1: // Assignments
        return _buildResourceList(
          context,
          Icons.assignment_rounded,
          "Assignments",
          color,
          isDark,
          viewModel.resources,
          viewModel,
        );
      case 2: // Quizzes
        return _buildResourceList(
          context,
          Icons.quiz_rounded,
          "Quizzes",
          color,
          isDark,
          viewModel.resources,
          viewModel,
        );
      case 3: // Exams
        return _buildExamMarksView(context, viewModel, color, isDark);
      case 4: // Attendance
        return _buildAttendanceView(context, viewModel, color, isDark);
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }

  Widget _buildResourceList(
    BuildContext context,
    IconData icon,
    String categoryName,
    Color color,
    bool isDark,
    List<dynamic> resources,
    ManagedSubjectViewModel viewModel,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == resources.length) {
              return _buildAddButton(context, categoryName, color, viewModel);
            }

            final resource = resources[index];
            final isPDF = viewModel.selectedFilterIndex == 0;
            final isAssignment = viewModel.selectedFilterIndex == 1;
            final isQuiz = viewModel.selectedFilterIndex == 2;

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
                            if (resource['file_url'] != null)
                              Text(
                                "File: ${resource['file_url'].split('/').last}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            Text(
                              resource['created_at'] != null 
                                ? "Uploaded on ${resource['created_at'].toString().split('T')[0]}"
                                : "Shared recently",
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  if ((isAssignment || isQuiz) && resource['content'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      resource['content'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (!isPDF && resource['total_submissions'] != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${resource['total_submissions']} Submissions",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: resource['total_submissions'] == 0
                                ? Colors.grey.withOpacity(0.2)
                                : (resource['ungraded_submissions'] ?? 0) > 0
                                    ? Colors.orange.withOpacity(0.2)
                                    : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            resource['total_submissions'] == 0
                                ? "No Submissions"
                                : (resource['ungraded_submissions'] ?? 0) > 0
                                    ? "${resource['ungraded_submissions']} Pending Grades"
                                    : "All Graded",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: resource['total_submissions'] == 0
                                  ? (isDark ? Colors.grey[400] : Colors.grey[600])
                                  : (resource['ungraded_submissions'] ?? 0) > 0
                                      ? Colors.orange[800]
                                      : Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (isPDF) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Material Engagement",
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.visibility_rounded, size: 14, color: color),
                              const SizedBox(width: 6),
                              Text(
                                "${resource['views'] ?? 0} Views",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!isPDF) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color.withOpacity(0.1),
                          foregroundColor: color,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Navigate to review submissions page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssignmentReviewPage(
                                assignment: resource,
                                viewModel: viewModel,
                                color: color,
                                isQuiz: isQuiz,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people_outline_rounded, size: 18),
                        label: const Text("View Submissions"),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          childCount: resources.length + 1,
        ),
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    String categoryName,
    Color color,
    ManagedSubjectViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: InkWell(
          onTap: () {
          if (categoryName == "Assignments") {
            _showAddAssignmentDialog(context, viewModel, subject['id']);
          } else if (categoryName == "Quizzes") {
            _showAddQuizDialog(context, viewModel, subject['id']);
          } else if (categoryName == "PDFs") {
            _showAddMaterialDialog(context, viewModel, subject['id'], forcedCategory: 'PDFs');
          } else {
            _showAddMaterialDialog(context, viewModel, subject['id']);
          }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.5), width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: color),
                const SizedBox(width: 8),
                Text(
                  "Add ${categoryName.endsWith('s') ? categoryName.substring(0, categoryName.length -1) : categoryName}",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddQuizDialog(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    int courseId,
  ) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Quiz"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Quiz Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: "Quiz Content/Questions"),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                return ListTile(
                  title: Text(
                    "Deadline: ${viewModel.assignmentDeadline.toString().split(' ')[0]}",
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: viewModel.assignmentDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => viewModel.setAssignmentDeadline(picked));
                    }
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                await viewModel.addQuiz(
                  courseId: courseId,
                  title: titleController.text,
                  content: contentController.text,
                  deadline: viewModel.assignmentDeadline,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  void _showAddAssignmentDialog(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    int courseId,
  ) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Assignment"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Assignment Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: "Assignment Content"),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                return ListTile(
                  title: Text(
                     "Deadline: ${viewModel.assignmentDeadline.toString().split(' ')[0]}",
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: viewModel.assignmentDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => viewModel.setAssignmentDeadline(picked));
                    }
                  },
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                await viewModel.addAssignment(
                  courseId: courseId,
                  title: titleController.text,
                  content: contentController.text,
                  deadline: viewModel.assignmentDeadline,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }



  Widget _buildAttendanceView(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    Color color,
    bool isDark,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Select Date:", style: TextDesign.h3),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: viewModel.selectedAttendanceDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      viewModel.setSelectedAttendanceDate(picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today_rounded),
                  label: Text(
                    "${viewModel.selectedAttendanceDate.toString().split(' ')[0]}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }

        final studentIndex = index - 1;
        if (studentIndex == viewModel.allStudents.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => viewModel.submitAttendance(context, subject['id']),
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Edit",
                      style: TextStyle(color: AppColors.primary, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final student = viewModel.allStudents[studentIndex];
        final String studentName = student['full_name'] ?? "Unknown";
        final int studentId = student['id'];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _attendanceOption("Attended", Colors.green, viewModel, studentId)),
                  const SizedBox(width: 8),
                  Expanded(child: _attendanceOption("Late", Colors.orange, viewModel, studentId)),
                  const SizedBox(width: 8),
                  Expanded(child: _attendanceOption("Absent", Colors.red, viewModel, studentId)),
                ],
              ),
            ],
          ),
        );
      }, childCount: viewModel.allStudents.length + 2),
    );
  }

  Widget _attendanceOption(String label, Color color, ManagedSubjectViewModel viewModel, int studentId) {
    return Consumer<ManagedSubjectViewModel>(
      builder: (context, vm, child) {
        final currentSelection = vm.attendanceMap[studentId] == label;
        
        return GestureDetector(
          onTap: () => vm.updateAttendanceStatus(studentId, label),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: currentSelection ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: currentSelection ? color : color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: currentSelection ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }
    );
  }

  void _showAddMaterialDialog(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    int courseId, {
    String? forcedCategory,
  }) {
    showDialog(
      context: context,
      builder: (context) => AddMaterialDialog(
        subjectName: subject['name'],
        subjectColor: subject['color'],
        forcedCategory: forcedCategory,
        categories: viewModel.filters.take(4).toList(),
        onUpload: ({required title, required category, file, fileBytes, fileName}) async {
          await viewModel.addMaterial(
            courseId: courseId,
            title: title,
            category: category,
            file: file,
            fileBytes: fileBytes,
            fileName: fileName,
          );
        },
      ),
    );
  }

  Widget _buildExamMarksView(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    Color color,
    bool isDark,
  ) {
    return SliverFillRemaining(
      hasScrollBody: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: () => _showAddExamMarkDialog(context, viewModel, subject['id']),
              icon: const Icon(Icons.add),
              label: const Text("Add Exam Mark"),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: viewModel.examMarks.length,
              itemBuilder: (context, index) {
                final mark = viewModel.examMarks[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Text(
                          mark['student_name']?[0] ?? "U",
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mark['student_name'] ?? "Unknown Student",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${mark['exam_type']} - Mark: ${mark['mark']}%",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _showEditExamMarkDialog(context, viewModel, mark),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddExamMarkDialog(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    int courseId,
  ) {
    int? selectedStudentId;
    String selectedExamType = "Midterm Exam";
    final markController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Exam Mark"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedStudentId,
                decoration: const InputDecoration(labelText: "Select Student"),
                items: viewModel.allStudents.map((s) {
                  return DropdownMenuItem<int>(
                    value: s['id'],
                    child: Text(s['full_name'] ?? "Unknown"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedStudentId = val),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedExamType,
                decoration: const InputDecoration(labelText: "Exam Type"),
                items: ["Midterm Exam", "Final Exam"].map((t) {
                  return DropdownMenuItem<String>(
                    value: t,
                    child: Text(t),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedExamType = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: markController,
                decoration: const InputDecoration(labelText: "Exam Mark %"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStudentId != null && markController.text.isNotEmpty) {
                  await viewModel.addExamMark(
                    courseId: courseId,
                    studentId: selectedStudentId!,
                    examType: selectedExamType,
                    mark: markController.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditExamMarkDialog(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    Map<String, dynamic> markData,
  ) {
    final markController = TextEditingController(text: markData['mark'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${markData['exam_type']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Student: ${markData['student_name']}"),
            const SizedBox(height: 12),
            TextField(
              controller: markController,
              decoration: const InputDecoration(labelText: "Exam Mark %"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (markController.text.isNotEmpty) {
                await viewModel.updateExamMark(
                  markData['id'],
                  markController.text,
                  subject['id'],
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
