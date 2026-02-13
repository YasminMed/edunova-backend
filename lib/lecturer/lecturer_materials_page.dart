import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/lecturer/lecturer_materials_viewmodel.dart';
import 'managed_subject_detail.dart';
import '../viewmodels/lecturer/managed_subject_viewmodel.dart';

class LecturerMaterialsPage extends StatelessWidget {
  const LecturerMaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LecturerMaterialsViewModel>(
      builder: (context, viewModel, child) {
        final l10n = AppLocalizations.of(context);
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : AppColors.primaryText;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              l10n?.translate('materials_management') ?? "Materials Management",
              style: TextDesign.h2.copyWith(color: textColor),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Text(
                  l10n?.translate('select_subject_hint') ??
                      "Select a subject to manage its materials, assignments, and exams.",
                  style: TextDesign.body.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: viewModel.subjects.length,
                  itemBuilder: (context, index) {
                    final subject = viewModel.subjects[index];
                    return _buildSubjectCard(context, subject, isDark);
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.secondary,
            onPressed: () => _showCreateCourseDialog(context, viewModel),
            icon: const Icon(Icons.library_add_rounded, color: Colors.white),
            label: Text(
              l10n?.translate('create_new_course') ?? "Create New Course",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void _showCreateCourseDialog(
    BuildContext context,
    LecturerMaterialsViewModel viewModel,
  ) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n?.translate('create_new_course') ?? "Create New Course",
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_rounded,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n?.translate('select_course_image') ??
                          "Select Course Image",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n?.translate('course_name') ?? "Course Name",
                  hintText: "e.g. Advanced Physics",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  labelText: l10n?.translate('course_code') ?? "Course Code",
                  hintText: "e.g. PHYS301",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: l10n?.translate('description') ?? "Description",
                  hintText: "Course overview and objectives...",
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.translate('cancel') ?? "Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  codeController.text.isNotEmpty) {
                viewModel.addNewCourse(
                  nameController.text,
                  codeController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Course created successfully!")),
                );
              }
            },
            child: Text(
              l10n?.translate('create') ?? "Create",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMaterialQuickAction(
    BuildContext context,
    Map<String, dynamic> subject,
  ) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          (l10n?.translate('add_material_to') ?? "Add Material to {subject}")
              .replaceAll('{subject}', subject['name']),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText:
                    l10n?.translate('material_title') ?? "Material Title",
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n?.translate('category') ?? "Category",
              ),
              items: [
                "PDFs",
                "Assignments",
                "Quizzes",
                "Exams",
              ].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(l10n?.translate('upload_file') ?? "Upload File"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.translate('cancel') ?? "Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: subject['color']),
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n?.translate('add') ?? "Add",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(
    BuildContext context,
    Map<String, dynamic> subject,
    bool isDark,
  ) {
    final l10n = AppLocalizations.of(context);
    final color = subject['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => ManagedSubjectViewModel(),
                    child: ManagedSubjectDetailPage(subject: subject),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      image: (subject['image'] != null && !kIsWeb)
                          ? DecorationImage(
                              image: FileImage(File(subject['image'])),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: (subject['image'] == null || kIsWeb)
                        ? Icon(
                            (subject['image'] != null && kIsWeb)
                                ? Icons.image_rounded
                                : Icons.book_rounded,
                            color: color,
                            size: 35,
                          )
                        : null,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject['name'],
                          style: TextDesign.h3.copyWith(
                            fontSize: 18,
                            color: isDark
                                ? Colors.white
                                : AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subject['code'],
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatChip(
                              Icons.people_alt_rounded,
                              "${subject['students']} ${l10n?.translate('students') ?? 'Students'}",
                              isDark,
                            ),
                            const SizedBox(width: 12),
                            _buildStatChip(
                              Icons.library_books_rounded,
                              "${subject['materials']} ${l10n?.translate('items') ?? 'Items'}",
                              isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          // Quick Add Material Button
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAddMaterialQuickAction(context, subject),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_rounded, color: color, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
