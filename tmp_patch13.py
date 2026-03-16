import codecs

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
      loadExamMarks(courseId);
    } else {
      loadAttendance(courseId);
    }
    notifyListeners();
  }"""

target2 = """  // Attendance Logic
  final List<String> _dummyStudents = [
    "Ali Hassan",
    "Sarah Ahmed",
    "Yousif Mohammed",
    "Dalia Saman",
    "Zaid Karim",
  ];

  List<String> get students => _dummyStudents;
  Map<String, String> attendanceMap = {};

  void updateAttendanceStatus(String student, String status) {
    attendanceMap[student] = status;
    notifyListeners();
  }

  Future<void> submitAttendance(BuildContext context, int courseId) async {
    setBusy(true);
    try {
      List<Map<String, String>> records = attendanceMap.entries.map((e) => {
        "student_name": e.key,
        "status": e.value,
      }).toList();
      
      await _materialService.submitAttendance(courseId, records);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance Submitted Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Error submitting attendance: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadAttendance(int courseId) async {
    // For now, students list is static, but we can fetch it if needed.
    notifyListeners();
  }
}"""

replacement2 = """  // --- Students, Exams, and Attendance Logic ---
  List<dynamic> _studentsList = [];
  List<dynamic> get studentsList => _studentsList;

  String _selectedExamType = 'midterm';
  String get selectedExamType => _selectedExamType;
  
  Map<int, String> _examMarksCount = {}; 
  Map<int, String> get examMarksCount => _examMarksCount;
  
  Map<int, String> attendanceMap = {}; 

  Future<void> loadStudents() async {
    try {
      _studentsList = await _materialService.getAllStudents();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading students: $e");
    }
  }

  void setExamType(String type, int courseId) {
    _selectedExamType = type;
    loadExamMarks(courseId);
  }

  void updateExamMark(int studentId, String mark) {
    _examMarksCount[studentId] = mark;
    notifyListeners();
  }

  Future<void> loadExamMarks(int courseId) async {
    setBusy(true);
    try {
      if (_studentsList.isEmpty) await loadStudents();
      final marks = await _materialService.getExamMarks(courseId, _selectedExamType);
      _examMarksCount.clear();
      for (var markRecord in marks) {
        _examMarksCount[markRecord['student_id']] = markRecord['mark'].toString();
      }
    } catch (e) {
      debugPrint("Error loading exam marks: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> saveExamMarks(BuildContext context, int courseId) async {
    setBusy(true);
    try {
      List<Map<String, dynamic>> marksData = _examMarksCount.entries.map((e) => {
        "student_id": e.key,
        "mark": double.tryParse(e.value) ?? 0.0,
      }).toList();
      await _materialService.saveExamMarks(courseId, _selectedExamType, marksData);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exam Marks Saved Successfully"), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("Error saving exam marks: $e");
    } finally {
      setBusy(false);
    }
  }

  void updateAttendanceStatus(int studentId, String status) {
    attendanceMap[studentId] = status;
    notifyListeners();
  }

  Future<void> loadAttendance(int courseId) async {
    setBusy(true);
    try {
      if (_studentsList.isEmpty) await loadStudents();
    } catch (e) {
      debugPrint("Error loading attendance setup: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> submitAttendance(BuildContext context, int courseId) async {
    setBusy(true);
    try {
      List<Map<String, dynamic>> records = attendanceMap.entries.map((e) => {
        "student_id": e.key,
        "status": e.value.toLowerCase(),
      }).toList();
      
      await _materialService.submitBatchAttendance(courseId, records);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Attendance Submitted Successfully"), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("Error submitting attendance: $e");
    } finally {
      setBusy(false);
    }
  }
}"""

def apply_patch(text, target, curr_repl):
    if target in text:
        return text.replace(target, curr_repl)
    elif target.replace('\\n', '\\r\\n') in text:
        return text.replace(target.replace('\\n', '\\r\\n'), curr_repl.replace('\\n', '\\r\\n'))
    else:
        print("WARNING: Target not found:\n" + target[:100] + "...")
        return text

text = apply_patch(text, target1, replacement1)
text = apply_patch(text, target2, replacement2)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("ManagedSubjectViewModel patched successfully.")
