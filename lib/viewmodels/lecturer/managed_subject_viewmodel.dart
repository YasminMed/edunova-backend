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

  List<dynamic> _resources = [];
  List<dynamic> get resources => _resources;

  int get selectedFilterIndex => _selectedFilterIndex;
  List<String> get filters => _filters;

  void setFilterIndex(int index, int courseId) {
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

  Future<void> loadSubmissions(int assignmentId) async {
    setBusy(true);
    try {
      _submissions = await _materialService.getSubmissions(assignmentId);
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
    required int assignmentId,
  }) async {
    setBusy(true);
    try {
      await _materialService.gradeSubmission(
        submissionId: submissionId,
        grade: grade,
        note: note,
      );
      await loadSubmissions(assignmentId);
    } catch (e) {
      debugPrint("Error grading submission: $e");
    } finally {
      setBusy(false);
    }
  }

  // Attendance Logic
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
}
