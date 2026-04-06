import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\lecturer\managed_subject_detail.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Target 1: Add _buildExamsView above _buildAttendanceView
target1 = """  Widget _buildAttendanceView(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    Color color,
    bool isDark,
  ) {"""

replacement1 = """  Widget _buildExamsView(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    Color color,
    bool isDark,
  ) {
    if (viewModel.students.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text("No students enrolled yet.", style: TextStyle(color: isDark ? Colors.white54 : Colors.grey)),
          ),
        ),
      );
    }
    
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'midterm', label: Text('Mid-Term')),
                      ButtonSegment(value: 'final', label: Text('Final')),
                    ],
                    selected: {viewModel.selectedExamType},
                    onSelectionChanged: (Set<String> newSelection) {
                      viewModel.setExamType(newSelection.first, subject['id']);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => viewModel.saveExamMarks(context, subject['id']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Marks'),
                ),
              ],
            ),
          );
        }

        final student = viewModel.students[index - 1];
        final studentId = student['id'] as int;
        final currentMark = viewModel.examMarks[studentId] ?? "";

        return Container(
          margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
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
              CircleAvatar(
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  student['full_name']?.substring(0, 1).toUpperCase() ?? "?",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  student['full_name'] ?? "Unknown",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 80,
                child: TextFormField(
                  initialValue: currentMark,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Mark",
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (val) => viewModel.updateExamMark(studentId, val),
                ),
              )
            ],
          ),
        );
      }, childCount: viewModel.students.length + 1),
    );
  }

  Widget _buildAttendanceView(
    BuildContext context,
    ManagedSubjectViewModel viewModel,
    Color color,
    bool isDark,
  ) {"""


# Target 2: Change _buildAttendanceView item creation
target2 = """        final student = viewModel.students[index];
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
        );"""

replacement2 = """        final studentObj = viewModel.students[index];
        final studentName = studentObj['full_name'] ?? "Unknown";
        final studentId = studentObj['id'] as int;
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
        );"""


# Target 3: Update `_attendanceOption` signature
target3 = """  Widget _attendanceOption(String label, Color color, ManagedSubjectViewModel viewModel, String student) {
    return Consumer<ManagedSubjectViewModel>(
      builder: (context, vm, child) {
        final currentSelection = vm.attendanceMap[student] == label;
        
        return GestureDetector(
          onTap: () => vm.updateAttendanceStatus(student, label),"""

replacement3 = """  Widget _attendanceOption(String label, Color color, ManagedSubjectViewModel viewModel, int studentId) {
    return Consumer<ManagedSubjectViewModel>(
      builder: (context, vm, child) {
        final currentSelection = vm.attendanceMap[studentId] == label;
        
        return GestureDetector(
          onTap: () => vm.updateAttendanceStatus(studentId, label),"""

# Target 4: Switch case for rendering the body content based on selected filter
target4 = """                    if (viewModel.selectedFilterIndex == 1)
                      _buildResourceList(context, Icons.assignment_rounded, "Assignments", color, isDark)
                    else if (viewModel.selectedFilterIndex == 4)
                      _buildAttendanceView(context, viewModel, color, isDark)
                    else
                      _buildResourceList(
                        context,
                        viewModel.selectedFilterIndex == 0 ? Icons.picture_as_pdf_rounded : Icons.folder_open_rounded,
                        viewModel.filters[viewModel.selectedFilterIndex],
                        color,
                        isDark,
                      ),"""

replacement4 = """                    if (viewModel.selectedFilterIndex == 1 || viewModel.selectedFilterIndex == 2)
                      _buildResourceList(context, Icons.assignment_rounded, "Assignments/Quizzes", color, isDark)
                    else if (viewModel.selectedFilterIndex == 3)
                      _buildExamsView(context, viewModel, color, isDark)
                    else if (viewModel.selectedFilterIndex == 4)
                      _buildAttendanceView(context, viewModel, color, isDark)
                    else
                      _buildResourceList(
                        context,
                        Icons.picture_as_pdf_rounded,
                        "PDFs",
                        color,
                        isDark,
                      ),"""

def apply_patch(text, target, curr_repl):
    target_win = target.replace('\\n', '\\r\\n')
    repl_win = curr_repl.replace('\\n', '\\r\\n')
    if target in text:
        return text.replace(target, curr_repl)
    elif target_win in text:
        return text.replace(target_win, repl_win)
    else:
        print("WARNING: Target not found:\n" + target[:100] + "...")
        return text

text = apply_patch(text, target1, replacement1)
text = apply_patch(text, target2, replacement2)
text = apply_patch(text, target3, replacement3)
text = apply_patch(text, target4, replacement4)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
