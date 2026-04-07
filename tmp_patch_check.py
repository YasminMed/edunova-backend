import codecs
import re

path = r'c:\src\flutter-apps\edunova_application\lib\viewmodels\lecturer\managed_subject_viewmodel.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target1 = """  Future<void> loadResources(int courseId, String category) async {
    setBusy(true);
    try {
      if (category == "Assignments") {
        await loadAssignments(courseId);
      } else if (category == "Quizzes") {
        await loadQuizzes(courseId);
      } else if (category == "Exams") {
        // Exams handled differently now? Wait, if category == "Exams", let's handle it
      } else {
        _resources = await _materialService.getResourcesByCategory(courseId, category);
      }
    } catch (e) {
      debugPrint("Error loading resources: $e");
    } finally {
      setBusy(false);
    }
  }"""

# I need to see what's actually in loadResources in managed_subject_viewmodel.dart.
# I'll just replace the whole file with a python script after reading it.
