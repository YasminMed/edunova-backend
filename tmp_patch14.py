import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\lecturer\managed_subject_detail.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target1 = """      case 3: // Exams
        return _buildResourceList(
          context,
          Icons.school_rounded,
          "Exams",
          color,
          isDark,
          viewModel.resources,
          viewModel,
        );"""

replacement1 = """      case 3: // Exams
        return _buildExamsView(context, viewModel, color, isDark);"""


target2 = """  Widget _buildAttendanceView(
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
  }"""

replacement2 = """  Widget _buildExamsView(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    Color color,
    bool isDark,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'midterm', label: Text('Mid-Term')),
                    ButtonSegment(value: 'final', label: Text('Final')),
                  ],
                  selected: {viewModel.selectedExamType},
                  onSelectionChanged: (Set<String> newSelection) {
                    viewModel.setExamType(newSelection.first, subject['id']);
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return color;
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.white;
                      }
                      return color;
                    }),
                  ),
                ),
              ],
            ),
          );
        }

        if (index == viewModel.studentsList.length + 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => viewModel.saveExamMarks(context, subject['id']),
              child: const Text("Save Marks", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          );
        }

        final student = viewModel.studentsList[index - 1];
        final studentId = student['id'] as int;
        final TextEditingController _tc = TextEditingController.fromValue(
          TextEditingValue(
            text: viewModel.examMarksCount[studentId] ?? "",
            selection: TextSelection.collapsed(offset: (viewModel.examMarksCount[studentId] ?? "").length),
          )
        );
        
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['full_name'] ?? "Unknown",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student['email'] ?? "",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: "Mark",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  controller: _tc,
                  onChanged: (val) {
                    viewModel.updateExamMark(studentId, val);
                  },
                ),
              ),
            ],
          ),
        );
      }, childCount: viewModel.studentsList.length + 2),
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
        if (index == viewModel.studentsList.length) {
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

        final student = viewModel.studentsList[index];
        final studentId = student['id'] as int;
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
                "${student['full_name']} (${student['email']})",
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
      }, childCount: viewModel.studentsList.length + 1),
    );
  }

  Widget _attendanceOption(String label, Color color, ManagedSubjectViewModel viewModel, int studentId) {
    return Consumer<ManagedSubjectViewModel>(
      builder: (context, vm, child) {
        final currentSelection = vm.attendanceMap[studentId] == label.toLowerCase();
        
        return GestureDetector(
          onTap: () => vm.updateAttendanceStatus(studentId, label.toLowerCase()),
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
  }"""

def apply_patch(text, target, curr_repl):
    if target in text:
        return text.replace(target, curr_repl)
    elif target.replace('\\n', '\\r\\n') in text:
        return text.replace(target.replace('\\n', '\\r\\n'), curr_repl.replace('\\n', '\\r\\n'))
    else:
        print("WARNING: Target not found:\\n" + target[:100] + "...")
        return text

text = apply_patch(text, target1, replacement1)
text = apply_patch(text, target2, replacement2)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("ManagedSubjectDetail patched successfully.")
