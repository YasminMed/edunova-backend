import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../l10n/app_localizations.dart';
import '../viewmodels/lecturer/lecturer_materials_viewmodel.dart';
import 'managed_subject_detail.dart';
import '../viewmodels/lecturer/managed_subject_viewmodel.dart';
import '../providers/user_provider.dart';

class LecturerMaterialsPage extends StatefulWidget {
  const LecturerMaterialsPage({super.key});

  @override
  State<LecturerMaterialsPage> createState() => _LecturerMaterialsPageState();
}

class _LecturerMaterialsPageState extends State<LecturerMaterialsPage> {

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
                child: RefreshIndicator(
                  onRefresh: viewModel.loadSubjects,
                  color: AppColors.secondary,
                  child: viewModel.isBusy
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.errorMessage != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Failed to load courses",
                                      style: TextDesign.h3,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      viewModel.errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: TextDesign.body.copyWith(color: Colors.redAccent[100]),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: viewModel.loadSubjects,
                                      child: const Text("Retry"),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : viewModel.subjects.isEmpty
                              ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.library_books_rounded,
                                        size: 64,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n?.translate('no_courses_yet') ?? "No courses created yet.",
                                        style: TextStyle(color: Colors.grey[500]),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n?.translate('pull_to_refresh_hint') ?? "Pull down to refresh",
                                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: viewModel.subjects.length,
                              itemBuilder: (context, index) {
                                final subject = viewModel.subjects[index];
                                return _buildSubjectCard(context, subject, isDark);
                              },
                            ),
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
    final userProvider = context.read<UserProvider>();
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();
    File? selectedImage;
    
    // Parse allowed departments and stages from user profile
    final List<String> allowedDepts = userProvider.department?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? ["Software Engineering"];
    final List<String> allowedStages = userProvider.stage?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? ["1st"];

    String selectedDept = allowedDepts.first;
    String selectedStage = allowedStages.first;
    int currentStep = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> pickImage() async {
            final result = await FilePicker.platform.pickFiles(type: FileType.image);
            if (result != null) {
              setDialogState(() {
                selectedImage = File(result.files.single.path!);
              });
            }
          }

          Widget buildStep0() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                      image: selectedImage != null
                          ? DecorationImage(
                              image: FileImage(selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                color: Colors.grey[600],
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n?.translate('select_course_image') ??
                                    "Select Course Image",
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          )
                        : null,
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
            );
          }

          Widget buildStep1() {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.translate('select_department') ?? "Select Department",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDept,
                      isExpanded: true,
                      onChanged: (val) => setDialogState(() => selectedDept = val!),
                      items: allowedDepts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n?.translate('select_stage') ?? "Select Stage",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStage,
                      isExpanded: true,
                      onChanged: (val) => setDialogState(() => selectedStage = val!),
                      items: allowedStages.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    ),
                  ),
                ),
              ],
            );
          }

          return AlertDialog(
            title: Text(
              currentStep == 0 
                ? (l10n?.translate('create_new_course') ?? "Create New Course")
                : (l10n?.translate('target_audience') ?? "Target Audience"),
            ),
            content: SingleChildScrollView(
              child: currentStep == 0 ? buildStep0() : buildStep1(),
            ),
            actions: [
              if (currentStep == 1)
                TextButton(
                  onPressed: () => setDialogState(() => currentStep = 0),
                  child: Text(l10n?.translate('back') ?? "Back"),
                ),
              if (currentStep == 0)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n?.translate('cancel') ?? "Cancel"),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: () async {
                  if (currentStep == 0) {
                    if (nameController.text.isNotEmpty && codeController.text.isNotEmpty) {
                      setDialogState(() => currentStep = 1);
                    }
                  } else {
                    await viewModel.addNewCourse(
                      nameController.text,
                      codeController.text,
                      department: selectedDept,
                      stage: selectedStage,
                      image: selectedImage,
                      lecturerEmail: userProvider.email,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Course created successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  currentStep == 0 
                    ? (l10n?.translate('continue') ?? "Continue")
                    : (l10n?.translate('create') ?? "Create"),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildSubjectCard(
    BuildContext context,
    Map<String, dynamic> subject,
    bool isDark,
  ) {
    final color = subject['color'] as Color;
    final String? imageUrl = subject['image'];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                      ),
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.book_rounded, color: color, size: 40),
                            )
                          : Icon(Icons.book_rounded, color: color, size: 40),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextDesign.h3.copyWith(
                        fontSize: 15,
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subject['code'],
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatChip(
                          Icons.people_alt_rounded,
                          "${subject['students']}",
                          isDark,
                        ),
                        _buildStatChip(
                          Icons.library_books_rounded,
                          "${subject['materials']}",
                          isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
