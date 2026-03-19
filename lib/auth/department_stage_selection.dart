import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/text_design.dart';
import '../widgets/animated_background.dart';
import '../widgets/custom_button.dart';
import 'signup_student.dart';
import 'signup_lecturer.dart';

class DepartmentStageSelectionPage extends StatefulWidget {
  final String role; // 'student' or 'lecturer'
  final bool isLogin; // Whether we're going to login or signup

  const DepartmentStageSelectionPage({
    super.key,
    required this.role,
    this.isLogin = true,
  });

  @override
  State<DepartmentStageSelectionPage> createState() =>
      _DepartmentStageSelectionPageState();
}

class _DepartmentStageSelectionPageState
    extends State<DepartmentStageSelectionPage> {
  final List<String> departments = [
    "Software Engineering",
    "IT",
    "Architectural Engineering",
    "Civil Engineering",
    "Interior Design Engineering",
    "Graphic Design",
    "Nursing",
    "Pharmacy",
    "Dentist",
    "Biomedical",
  ];

  final List<String> stages = [
    "First Stage",
    "Second Stage",
    "Third Stage",
    "Fourth Stage",
    "Fifth Stage",
  ];

  // For Student: Single Selection
  String? selectedDepartment;
  String? selectedStage;

  // For Lecturer: Multi Selection
  final Set<String> selectedDepartments = {};
  final Set<String> selectedStages = {};

  @override
  void initState() {
    super.initState();
    if (widget.role == 'student') {
      selectedDepartment = departments.first;
      selectedStage = stages.first;
    }
  }

  void _handleContinue() {
    if (widget.role == 'student') {
      if (selectedDepartment == null || selectedStage == null) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SignupStudentPage(
            department: selectedDepartment!,
            stage: selectedStage!,
          ),
        ),
      );
    } else {
      // Lecturer
      if (selectedDepartments.isEmpty || selectedStages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one department and stage")),
        );
        return;
      }
      
      final deptString = selectedDepartments.join(", ");
      final stageString = selectedStages.join(", ");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SignupLecturerPage(
            departments: deptString,
            stages: stageString,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.role == 'student' ? AppColors.primary : AppColors.secondary;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.role == 'student' ? "Student Profile" : "Lecturer Profile",
                    style: TextDesign.h1.copyWith(
                      fontSize: 32,
                      color: isDark ? Colors.white : AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.role == 'student' 
                      ? "Choose your department and current stage"
                      : "Select the departments and stages you teach",
                    style: TextDesign.body.copyWith(
                      color: isDark ? Colors.white70 : AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Department Section
                  _buildSectionTitle("Department", isDark),
                  const SizedBox(height: 16),
                  if (widget.role == 'student')
                    _buildStudentDropdown(departments, selectedDepartment, (val) {
                      setState(() => selectedDepartment = val);
                    }, isDark)
                  else
                    _buildLecturerChips(departments, selectedDepartments, isDark, primaryColor),

                  const SizedBox(height: 32),

                  // Stage Section
                  _buildSectionTitle("Stage", isDark),
                  const SizedBox(height: 16),
                  if (widget.role == 'student')
                    _buildStudentDropdown(stages, selectedStage, (val) {
                      setState(() => selectedStage = val);
                    }, isDark)
                  else
                    _buildLecturerChips(stages, selectedStages, isDark, primaryColor),

                  const SizedBox(height: 48),
                  CustomButton(
                    text: "Continue",
                    onTap: _handleContinue,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextDesign.h2.copyWith(
        color: isDark ? Colors.white : AppColors.primaryText,
      ),
    );
  }

  Widget _buildStudentDropdown(List<String> items, String? selected, ValueChanged<String?> onChanged, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLecturerChips(List<String> items, Set<String> selection, bool isDark, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selection.contains(item);
        return FilterChip(
          label: Text(
            item,
            style: TextStyle(
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selection.add(item);
              } else {
                selection.remove(item);
              }
            });
          },
          selectedColor: color,
          checkmarkColor: Colors.white,
          backgroundColor: isDark ? Colors.white10 : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? color : (isDark ? Colors.white24 : Colors.grey.shade300),
            ),
          ),
        );
      }).toList(),
    );
  }
}
