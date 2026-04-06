import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\lecturer\assignment_review_page.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target1 = """class AssignmentReviewPage extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final ManagedSubjectViewModel viewModel;
  final Color color;

  const AssignmentReviewPage({
    super.key,
    required this.assignment,
    required this.viewModel,
    required this.color,
  });"""

replacement1 = """class AssignmentReviewPage extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final ManagedSubjectViewModel viewModel;
  final Color color;
  final bool isQuiz;

  const AssignmentReviewPage({
    super.key,
    required this.assignment,
    required this.viewModel,
    required this.color,
    this.isQuiz = false,
  });"""

target2 = """  @override
  void initState() {
    super.initState();
    widget.viewModel.loadSubmissions(widget.assignment['id']);
  }"""

replacement2 = """  @override
  void initState() {
    super.initState();
    widget.viewModel.loadSubmissions(widget.assignment['id'], isQuiz: widget.isQuiz);
  }"""

target3 = """                await widget.viewModel.gradeSubmission(
                  submissionId: sub['id'],
                  grade: gradeController.text,
                  note: noteController.text,
                  assignmentId: widget.assignment['id'],
                );"""

replacement3 = """                await widget.viewModel.gradeSubmission(
                  submissionId: sub['id'],
                  grade: gradeController.text,
                  note: noteController.text,
                  parentId: widget.assignment['id'],
                  isQuiz: widget.isQuiz,
                );"""

text = text.replace(target1, replacement1)
text = text.replace(target2, replacement2)
text = text.replace(target3, replacement3)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("AssignmentReviewPage patched for Quizzes")
