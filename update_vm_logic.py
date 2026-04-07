import codecs
import re

path = r'c:\src\flutter-apps\edunova_application\lib\viewmodels\lecturer\managed_subject_viewmodel.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

# Add loadQuizSubmissions and gradeQuizSubmission
# First, let's update the existing gradeSubmission to be more generic or add a new one.
# I'll add loadSubmissions(int id, bool isQuiz) and gradeSubmission(id, grade, note, parentId, isQuiz)

new_review_methods = """  Future<void> loadSubmissions(int id, {bool isQuiz = false}) async {
    setBusy(true);
    try {
      if (isQuiz) {
        _submissions = await _materialService.getQuizSubmissions(id);
      } else {
        _submissions = await _materialService.getSubmissions(id);
      }
    } catch (e) {
      debugPrint("Error loading submissions: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> gradeSubmission({
    required int submissionId,
    required String grade,
    String? note,
    required int parentId,
    bool isQuiz = false,
  }) async {
    setBusy(true);
    try {
      if (isQuiz) {
        await _materialService.gradeQuizSubmission(
          submissionId: submissionId,
          grade: grade,
          note: note,
        );
      } else {
        await _materialService.gradeSubmission(
          submissionId: submissionId,
          grade: grade,
          note: note,
        );
      }
      await loadSubmissions(parentId, isQuiz: isQuiz);
    } catch (e) {
      debugPrint("Error grading submission: $e");
    } finally {
      setBusy(false);
    }
  }"""

# Find and replace the old methods
target_submissions = re.compile(r'  Future<void> loadSubmissions\(int assignmentId\) async \{.*?  \}', re.DOTALL)
text = target_submissions.sub('', text)

target_grade = re.compile(r'  Future<void> gradeSubmission\(\{.*?  \}', re.DOTALL)
text = target_grade.sub('', text)

# Inject the new ones before the Attendance logic
target_attendance_marker = "// Attendance / Students Logic"
if target_attendance_marker in text:
    text = text.replace(target_attendance_marker, new_review_methods + "\n\n  " + target_attendance_marker)

# Also remove any left-over _submissions list if I accidentally removed it or if I want to re-position it
if "List<dynamic> _submissions = [];" not in text:
    text = text.replace(new_review_methods, "  List<dynamic> _submissions = [];\n  List<dynamic> get submissions => _submissions;\n\n" + new_review_methods)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("managed_subject_viewmodel.dart updated with generic submission logic")
