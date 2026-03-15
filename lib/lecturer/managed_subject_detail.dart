import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import 'dart:ui';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: color,
            onPressed: () => _showAddMaterialDialog(context, viewModel, subject['id']),
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
        );
      case 1: // Assignments
        return _buildResourceList(
          context,
          Icons.assignment_rounded,
          "Assignments",
          color,
          isDark,
          viewModel.resources,
        );
      case 2: // Quizzes
        return _buildResourceList(
          context,
          Icons.quiz_rounded,
          "Quizzes",
          color,
          isDark,
          viewModel.resources,
        );
      case 3: // Exams
        return _buildResourceList(
          context,
          Icons.school_rounded,
          "Exams",
          color,
          isDark,
          viewModel.resources,
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
  ) {
    if (resources.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.folder_open_rounded, size: 64, color: color.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text("No $categoryName uploaded yet.", style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final resource = resources[index];
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
                      resource['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                    Text(
                      "Uploaded on ${resource['created_at'].toString().split('T')[0]}",
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
      }, childCount: resources.length),
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
    int courseId,
  ) {
    final titleController = TextEditingController();
    String? selectedCategory;
    File? selectedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add New Material"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Material Title"),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Category"),
                items: viewModel.filters
                    .take(4) // Exclude Attendance
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedCategory = v),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setDialogState(() {
                      selectedFile = File(result.files.single.path!);
                    });
                  }
                },
                icon: const Icon(Icons.upload_file_rounded),
                label: Text(selectedFile != null ? "File Selected" : "Upload File"),
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
              onPressed: () async {
                if (titleController.text.isNotEmpty && selectedCategory != null && selectedFile != null) {
                   await viewModel.addMaterial(
                     courseId: courseId,
                     title: titleController.text,
                     category: selectedCategory!,
                     file: selectedFile!,
                   );
                   Navigator.pop(context);
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
