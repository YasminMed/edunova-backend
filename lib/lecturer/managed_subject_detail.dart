import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../viewmodels/lecturer/managed_subject_viewmodel.dart';

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
                          if (subject['image'] != null && !kIsWeb)
                            Image.file(
                              File(subject['image']),
                              fit: BoxFit.cover,
                            )
                          else if (subject['image'] != null && kIsWeb)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [color, color.withOpacity(0.8)],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_rounded,
                                  size: 60,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: color,
            onPressed: () => _showAddMaterialDialog(context, viewModel),
            child: const Icon(Icons.add, color: Colors.white),
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
              onTap: () => viewModel.setFilterIndex(index),
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
          "Lecture Note",
          color,
          isDark,
        );
      case 1: // Assignments
        return _buildManagementList(
          context,
          Icons.assignment_rounded,
          "Assignment",
          color,
          isDark,
          showGrading: true,
        );
      case 2: // Quizzes
        return _buildManagementList(
          context,
          Icons.quiz_rounded,
          "Quiz",
          color,
          isDark,
          showGrading: true,
        );
      case 3: // Exams
        return _buildManagementList(
          context,
          Icons.school_rounded,
          "Exam",
          color,
          isDark,
          showGrading: true,
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
    String label,
    Color color,
    bool isDark,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
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
                      "$label ${index + 1}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                    Text(
                      "Uploaded on 15 Dec 2023",
                      style: TextStyle(
                        fontSize: 12,
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
        );
      }, childCount: 4),
    );
  }

  Widget _buildManagementList(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    bool isDark, {
    bool showGrading = false,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
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
                          "$label Topic ${index + 1}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.primaryText,
                          ),
                        ),
                        Text(
                          "Uploaded on 25 Dec 2023",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (index == 0)
                    Column(
                      children: [
                        Text(
                          "85/100",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Good work",
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    )
                  else
                    _buildActionBtn(
                      Icons.grade_rounded,
                      "Mark",
                      Colors.orange,
                      () => _showGradingDialog(context, index),
                    ),
                  _buildActionBtn(
                    Icons.history_rounded,
                    "Remark",
                    Colors.teal,
                    () => _showGradingDialog(context, index, isRemark: true),
                  ),
                ],
              ),
            ],
          ),
        );
      }, childCount: 3),
    );
  }

  Widget _buildActionBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showGradingDialog(
    BuildContext context,
    int index, {
    bool isRemark = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRemark ? "Remark Submission" : "Mark Submission"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            TextField(decoration: InputDecoration(labelText: "Student ID")),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: "Grade (e.g., 85/100)"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(labelText: "Notes"),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Submission ${isRemark ? 'Remarked' : 'Marked'} Successfully!",
                  ),
                ),
              );
            },
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
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
                    onPressed: () => viewModel.submitAttendance(context),
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
                  Expanded(child: _attendanceOption("Attended", Colors.green)),
                  const SizedBox(width: 8),
                  Expanded(child: _attendanceOption("Late", Colors.orange)),
                  const SizedBox(width: 8),
                  Expanded(child: _attendanceOption("Absent", Colors.red)),
                ],
              ),
            ],
          ),
        );
      }, childCount: viewModel.students.length + 1),
    );
  }

  Widget _attendanceOption(String label, Color color) {
    bool isSelected = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () => setState(() => isSelected = !isSelected),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddMaterialDialog(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Material"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: "Material Title"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Category"),
              items: viewModel.filters
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text("Upload File"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: subject['color']),
            onPressed: () => Navigator.pop(context),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
