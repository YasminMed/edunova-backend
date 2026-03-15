import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/viewmodels/base_view_model.dart';
import '../../services/material_service.dart';
import '../../services/auth_service.dart';

class LecturerMaterialsViewModel extends BaseViewModel {
  final MaterialService _materialService = MaterialService();
  List<Map<String, dynamic>> _subjects = [];
  String? _errorMessage;

  List<Map<String, dynamic>> get subjects => _subjects;
  String? get errorMessage => _errorMessage;

  LecturerMaterialsViewModel() {
    loadSubjects();
  }

  Future<void> loadSubjects() async {
    setBusy(true);
    try {
      final response = await _materialService.getCourses();
      _subjects = response.map((s) => {
        'id': s['id'] as int,
        'name': s['name'] as String,
        'code': s['code'] as String,
        'students': 0, // Mock for now
        'materials': 0, // Mock for now
        'image': s['image_url'] != null ? "${AuthService.baseUrl}${s['image_url']}" : null,
        'color': Colors.blue, // Default color
      }).toList().cast<Map<String, dynamic>>();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error loading courses: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> addNewCourse(String name, String code, {File? image}) async {
    setBusy(true);
    try {
      await _materialService.createCourse(name, code, image: image);
      await loadSubjects();
    } catch (e) {
      debugPrint("Error creating course: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> uploadMaterial({
    required int courseId,
    required String category,
    required String title,
    required File file,
  }) async {
    setBusy(true);
    try {
      await _materialService.uploadResource(
        courseId: courseId,
        category: category,
        title: title,
        file: file,
      );
    } catch (e) {
      debugPrint("Error uploading material: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteCourse(int id) async {
    try {
      await _materialService.deleteCourse(id);
      await loadSubjects();
    } catch (e) {
      debugPrint("Error deleting course: $e");
    }
  }
}
