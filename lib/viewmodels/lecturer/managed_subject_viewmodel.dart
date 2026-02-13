import 'package:flutter/material.dart';
import '../../core/viewmodels/base_view_model.dart';

class ManagedSubjectViewModel extends BaseViewModel {
  int _selectedFilterIndex = 0;
  final List<String> _filters = [
    "PDFs",
    "Assignments",
    "Quizzes",
    "Exams",
    "Attendance",
  ];

  int get selectedFilterIndex => _selectedFilterIndex;
  List<String> get filters => _filters;

  void setFilterIndex(int index) {
    _selectedFilterIndex = index;
    notifyListeners();
  }

  // Attendance Logic
  final List<String> _students = [
    "Ali Hassan",
    "Sarah Ahmed",
    "Yousif Mohammed",
    "Dalia Saman",
    "Zaid Karim",
  ];

  List<String> get students => _students;

  void submitAttendance(BuildContext context) {
    // Logic to submit attendance
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Attendance Submitted Successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Material Logic
  void addMaterial(String title, String category) {
    // Logic to add material
    notifyListeners();
  }
}
