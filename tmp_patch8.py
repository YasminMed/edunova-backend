import codecs

path = r'c:\src\flutter-apps\edunova_application\lib\viewmodels\lecturer\managed_subject_viewmodel.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target = """  // Attendance Logic
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

replacement = """
  // --- Students, Exams, and Attendance Logic ---
  
  List<dynamic> _students = [];
  List<dynamic> get students => _students;

  // Exam state
  String _selectedExamType = 'midterm';
  String get selectedExamType => _selectedExamType;
  Map<int, String> _examMarks = {};
  Map<int, String> get examMarks => _examMarks;

  void setExamType(String type, int courseId) {
      _selectedExamType = type;
      _loadExamMarks(courseId);
  }

  void updateExamMark(int studentId, String mark) {
      _examMarks[studentId] = mark;
      notifyListeners();
  }

  Future<void> loadStudents() async {
      setBusy(true);
      try {
          _students = await _materialService.getAllStudents();
      } catch (e) {
          debugPrint("Error loading students: $e");
      } finally {
          setBusy(false);
      }
  }

  Future<void> _loadExamMarks(int courseId) async {
      setBusy(true);
      try {
          final marks = await _materialService.getExamMarks(courseId, _selectedExamType);
          _examMarks.clear();
          for (var mark in marks) {
              _examMarks[mark['student_id']] = mark['mark'];
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
          final marksData = _examMarks.entries
            .where((e) => e.value.isNotEmpty)
            .map((e) => {"student_id": e.key, "mark": e.value})
            .toList();
          
          if (marksData.isNotEmpty) {
              await _materialService.saveExamMarks(courseId, _selectedExamType, marksData);
              if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Exam Marks Saved Successfully"), backgroundColor: Colors.green),
                  );
              }
          }
      } catch (e) {
          debugPrint("Error saving exam marks: $e");
      } finally {
          setBusy(false);
      }
  }
  
  // Attendance State
  Map<int, String> attendanceMap = {};

  void updateAttendanceStatus(int studentId, String status) {
    attendanceMap[studentId] = status;
    notifyListeners();
  }

  Future<void> submitAttendance(BuildContext context, int courseId) async {
    setBusy(true);
    try {
      final records = attendanceMap.entries.map((e) {
          final student = _students.firstWhere((s) => s['id'] == e.key, orElse: () => null);
          return {
              "student_id": e.key,
              "student_name": student != null ? student['full_name'] : "Unknown",
              "status": e.value,
          };
      }).toList();
      
      await _materialService.submitBatchAttendance(courseId, records);
      if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Attendance Submitted Successfully"),
              backgroundColor: Colors.green,
            ),
          );
      }
    } catch (e) {
      debugPrint("Error submitting attendance: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadAttendance(int courseId) async {
      await loadStudents();
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

text = apply_patch(text, target, replacement)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
