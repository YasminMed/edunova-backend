import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\lecturer\managed_subject_detail.dart'

# Try reading as UTF-8 first, fallback to UTF-16LE if needed
try:
    with codecs.open(path, 'r', 'utf-8') as f:
        text = f.read()
    encoding = 'utf-8'
except UnicodeDecodeError:
    with codecs.open(path, 'r', 'utf-16le') as f:
        text = f.read()
    encoding = 'utf-16le'

# Fix 1: Define isQuiz and isAssignment in _buildResourceList
target1 = """            final resource = resources[index];
            final isAssignment = viewModel.selectedFilterIndex == 1;

            return Container("""

replacement1 = """            final resource = resources[index];
            final isAssignment = viewModel.selectedFilterIndex == 1;
            final isQuiz = viewModel.selectedFilterIndex == 2;

            return Container("""

# Fix 2: Pass isQuiz to AssignmentReviewPage correctly
target2 = """                        onPressed: () {
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
                        },"""

replacement2 = """                        onPressed: () {
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
                        },"""

# Fix 3: Attendance View - Use allStudents and student['id'] / student['full_name']
target3 = """        final student = viewModel.students[index];
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
      }, childCount: viewModel.students.length + 1),"""

replacement3 = """        final student = viewModel.allStudents[index];
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
      }, childCount: viewModel.allStudents.length + 1),"""

# Fix 4: _attendanceOption signature
target4 = """  Widget _attendanceOption(String label, Color color, ManagedSubjectViewModel viewModel, String student) {
    return Consumer<ManagedSubjectViewModel>(
      builder: (context, vm, child) {
        final currentSelection = vm.attendanceMap[student] == label;
        
        return GestureDetector(
          onTap: () => vm.updateAttendanceStatus(student, label),"""

replacement4 = """  Widget _attendanceOption(String label, Color color, ManagedSubjectViewModel viewModel, int studentId) {
    return Consumer<ManagedSubjectViewModel>(
      builder: (context, vm, child) {
        final currentSelection = vm.attendanceMap[studentId] == label;
        
        return GestureDetector(
          onTap: () => vm.updateAttendanceStatus(studentId, label),"""

text = text.replace(target1, replacement1)
text = text.replace(target2, replacement2)
text = text.replace(target3, replacement3)
text = text.replace(target4, replacement4)

with codecs.open(path, 'w', encoding) as f:
    f.write(text)
print(f"ManagedSubjectDetail fixed using {encoding}")
