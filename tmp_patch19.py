import codecs
import re

path = r'c:\src\flutter-apps\edunova_application\lib\viewmodels\lecturer\managed_subject_viewmodel.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target1 = """  void setFilterIndex(int index, int courseId) {
    _selectedFilterIndex = index;
    if (index == 0 || index == 3) {
      loadResources(courseId, _filters[index]);
    } else if (index == 1) {
      loadAssignments(courseId);
    } else if (index == 2) {
      loadQuizzes(courseId);
    } else {
      loadAttendance(courseId);
    }
    notifyListeners();
  }

  Future<void> loadResources(int courseId, String category) async {
    setBusy(true);
    try {
      _resources = await _materialService.getResources(courseId, category: category);
    } catch (e) {
      debugPrint("Error loading resources: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> addMaterial({
    required int courseId,
    required String title,
    required String category,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    setBusy(true);
    try {
      await _materialService.uploadResource(
        courseId: courseId,
        category: category,
        title: title,
        file: file,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      if (category == "PDFs" || category == "Quizzes" || category == "Exams") {
        await loadResources(courseId, category);
      } else if (category == "Assignments") {
        await loadAssignments(courseId);
      }
    } catch (e) {
      debugPrint("Error uploading material: $e");
    } finally {
      setBusy(false);
    }
  }"""

replacement1 = """  void setFilterIndex(int index, int courseId) {
    _selectedFilterIndex = index;
    if (index == 0) {
      loadResources(courseId, _filters[index]);
    } else if (index == 1) {
      loadAssignments(courseId);
    } else if (index == 2) {
      loadQuizzes(courseId);
    } else if (index == 3) {
      loadExams(courseId);
    } else {
      loadAttendance(courseId);
    }
    notifyListeners();
  }

  Future<void> loadResources(int courseId, String category) async {
    setBusy(true);
    try {
      _resources = await _materialService.getResources(courseId, category: category);
    } catch (e) {
      debugPrint("Error loading resources: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadExams(int courseId) async {
    setBusy(true);
    try {
      _resources = await _materialService.getExamMarksFull(courseId);
      // Fetch students list for dropdowns if needed
      await loadAttendance(courseId); 
    } catch (e) {
      debugPrint("Error loading exams: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> addExamMark({
    required int courseId,
    required int studentId,
    required String examType,
    required String mark,
  }) async {
    setBusy(true);
    try {
      await _materialService.saveExamMark(courseId, studentId, examType, mark);
      await loadExams(courseId);
    } catch (e) {
      debugPrint("Error adding exam mark: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateExamMark({
    required int courseId,
    required int markId,
    required String mark,
  }) async {
    setBusy(true);
    try {
      await _materialService.updateExamMark(markId, mark);
      await loadExams(courseId);
    } catch (e) {
      debugPrint("Error updating exam mark: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> addMaterial({
    required int courseId,
    required String title,
    required String category,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    setBusy(true);
    try {
      await _materialService.uploadResource(
        courseId: courseId,
        category: category,
        title: title,
        file: file,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      if (category == "PDFs") {
        await loadResources(courseId, category);
      }
    } catch (e) {
      debugPrint("Error uploading material: $e");
    } finally {
      setBusy(false);
    }
  }"""

# Handle Attendance Students List dynamically since we need students for exams dropdown:
target2 = """  // Attendance Logic
  final List<String> _dummyStudents = [
    "Ali Hassan",
    "Sarah Ahmed",
    "Yousif Mohammed",
    "Dalia Saman",
    "Zaid Karim",
  ];

  List<String> get students => _dummyStudents;
  Map<String, String> attendanceMap = {};"""

replacement2 = """  // Attendance / Students Logic
  List<dynamic> _studentsList = [];
  List<dynamic> get studentsList => _studentsList;
  
  List<String> get students => _studentsList.map((e) => e['full_name'] as String).toList();
  Map<String, String> attendanceMap = {};"""

target3 = """  Future<void> loadAttendance(int courseId) async {
    // For now, students list is static, but we can fetch it if needed.
    notifyListeners();
  }"""

replacement3 = """  Future<void> loadAttendance(int courseId) async {
    try {
      _studentsList = await _materialService.getAllStudents();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading students: $e");
    }
  }"""

text = text.replace(target1, replacement1)
text = text.replace(target2, replacement2)
text = text.replace(target3, replacement3)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("managed_subject_viewmodel.dart patched")
