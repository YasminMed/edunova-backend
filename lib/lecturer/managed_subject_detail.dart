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
            onTap: () => viewModel.setFilterIndex(index, subject['id']),
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
        return _buildResourceList(
          context,
          Icons.school_rounded,
          "Exams",
          color,
          isDark,
          viewModel.resources,
          viewModel,
        );
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
            final isAssignment = viewModel.selectedFilterIndex == 1;

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
                    if (isAssignment && resource['content'] != null) ...[
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
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.people_outline_rounded, size: 18),
                        label: const Text("View Submissions"),
                      ),
                    ),
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
        if (index == viewModel.students.length) {
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

        final student = viewModel.students[index];
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
                student,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _attendanceOption("Attended", Colors.green, viewModel, student)),
                  const SizedBox(width: 8),
                  Expanded(child: _attendanceOption("Late", Colors.orange, viewModel, student)),
                  const SizedBox(width: 8),
                  Expanded(child: _attendanceOption("Absent", Colors.red, viewModel, student)),
                ],
              ),
            ],
          ),
        );
      }, childCount: viewModel.students.length + 1),
    );
  }

  Widget _attendanceOption(String label, Color color, ManagedSubjectViewModel viewModel, String student) {
    return Consumer<ManagedSubjectViewModel>(
      builder: (context, vm, child) {
        final currentSelection = vm.attendanceMap[student] == label;
        
        return GestureDetector(
          onTap: () => vm.updateAttendanceStatus(student, label),
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
}
