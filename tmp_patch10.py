import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\lecturer\managed_subject_detail.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Target for `_buildFilteredContent`
target_switch = """  Widget _buildFilteredContent(
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
  }"""

replacement_switch = """  Widget _buildFilteredContent(
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
        return _buildExamsView(context, viewModel, color, isDark);
      case 4: // Attendance
        return _buildAttendanceView(context, viewModel, color, isDark);
      default:
        return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
  }"""


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

text = apply_patch(text, target_switch, replacement_switch)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
