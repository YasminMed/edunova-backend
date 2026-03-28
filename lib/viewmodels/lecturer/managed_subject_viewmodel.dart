import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/viewmodels/base_view_model.dart';
import '../../services/material_service.dart';
import 'dart:io';

class ManagedSubjectViewModel extends BaseViewModel {
  final MaterialService _materialService = MaterialService();
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    "PDFs",
    "Assignments",
    "Quizzes",
    "Exams",
    "Attendance",
  ];
  
  DateTime _selectedAttendanceDate = DateTime.now();
  DateTime get selectedAttendanceDate => _selectedAttendanceDate;

  void setSelectedAttendanceDate(DateTime date) {
    _selectedAttendanceDate = date;
    notifyListeners();
  }

  List<dynamic> _resources = [];
  List<dynamic> get resources => _resources;

  int get selectedFilterIndex => _selectedFilterIndex;
  List<String> get filters => _filters;

  void setFilterIndex(int index, int courseId, {String? department, String? stage}) {
    _selectedFilterIndex = index;
    if (index == 0) {
      loadResources(courseId, _filters[index]);
    } else if (index == 3) {
      loadExamMarks(courseId);
      loadAllStudents(department: department, stage: stage);
    } else if (index == 1) {
      loadAssignments(courseId);
    } else if (index == 2) {
      loadQuizzes(courseId);
    } else {
      loadAttendance(courseId, department: department, stage: stage);
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
  }

  Future<void> loadAssignments(int courseId) async {
    setBusy(true);
    try {
      _resources = await _materialService.getAssignments(courseId);
    } catch (e) {
      debugPrint("Error loading assignments: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> addAssignment({
    required int courseId,
    required String title,
    required String content,
    DateTime? deadline,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    setBusy(true);
    try {
      await _materialService.createAssignment(
        courseId: courseId,
        title: title,
        content: content,
        deadline: deadline,
        file: file,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      await loadAssignments(courseId);
    } catch (e) {
      debugPrint("Error creating assignment: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> loadQuizzes(int courseId) async {
    setBusy(true);
    try {
      _resources = await _materialService.getQuizzes(courseId);
    } catch (e) {
      debugPrint("Error loading quizzes: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> addQuiz({
    required int courseId,
    required String title,
    required String content,
    DateTime? deadline,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    setBusy(true);
    try {
      await _materialService.createQuiz(
        courseId: courseId,
        title: title,
        content: content,
        deadline: deadline,
        file: file,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      await loadQuizzes(courseId);
    } catch (e) {
      debugPrint("Error creating quiz: $e");
    } finally {
      setBusy(false);
    }
  }

  List<dynamic> _submissions = [];
  List<dynamic> get submissions => _submissions;

  Future<void> loadSubmissions(int parentId, {bool isQuiz = false}) async {
    setBusy(true);
    try {
      if (isQuiz) {
        _submissions = await _materialService.getQuizSubmissions(parentId);
      } else {
        _submissions = await _materialService.getSubmissions(parentId);
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
    required String note,
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
  }

  // Exam Marks Logic
  List<dynamic> _examMarks = [];
  List<dynamic> get examMarks => _examMarks;

  Future<void> loadExamMarks(int courseId) async {
    setBusy(true);
    try {
      _examMarks = await _materialService.getExamMarksFull(courseId);
    } catch (e) {
      debugPrint("Error loading exam marks: $e");
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
      await loadExamMarks(courseId);
    } catch (e) {
      debugPrint("Error adding exam mark: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateExamMark(int markId, String mark, int courseId) async {
    setBusy(true);
    try {
      await _materialService.updateExamMark(markId, mark);
      await loadExamMarks(courseId);
    } catch (e) {
      debugPrint("Error updating exam mark: $e");
    } finally {
      setBusy(false);
    }
  }

  // Students list for dropdowns
  List<dynamic> _allStudents = [];
  List<dynamic> get allStudents => _allStudents;

  Future<void> loadAllStudents({String? department, String? stage}) async {
    try {
      _allStudents = await _materialService.getAllStudents(department: department, stage: stage);
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading students: $e");
    }
  }

  // Attendance Logic
  Map<int, String> attendanceMap = {};

  void updateAttendanceStatus(int studentId, String status) {
    attendanceMap[studentId] = status;
    notifyListeners();
  }

  Future<void> submitAttendance(BuildContext context, int courseId) async {
    setBusy(true);
    try {
      List<Map<String, dynamic>> records = attendanceMap.entries.map((e) => {
        "student_id": e.key,
        "status": e.value,
      }).toList();
      
      await _materialService.submitBatchAttendance(courseId, records, date: _selectedAttendanceDate);
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

  Future<void> loadAttendance(int courseId, {String? department, String? stage}) async {
    setBusy(true);
    try {
      // We can also fetch existing attendance for today if we wanted to
      await loadAllStudents(department: department, stage: stage);
    } finally {
      setBusy(false);
    }
  }
}
