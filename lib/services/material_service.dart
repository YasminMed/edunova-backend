import 'dart:io';
import 'package:dio/dio.dart';
import 'auth_service.dart';

class MaterialService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AuthService.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<List<dynamic>> getCourses() async {
    try {
      final response = await _dio.get("/courses");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createCourse(String name, String code, {File? image}) async {
    try {
      final Map<String, dynamic> formDataMap = {
        "name": name,
        "code": code,
      };
      if (image != null) {
        formDataMap["image"] = await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        );
      }
      final formData = FormData.fromMap(formDataMap);
      final response = await _dio.post("/courses", data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCourse(int id) async {
    try {
      await _dio.delete("/courses/$id");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getResources(int courseId, {String? category}) async {
    try {
      final response = await _dio.get(
        "/courses/$courseId/resources",
        queryParameters: category != null ? {"category": category.toLowerCase()} : null,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> uploadResource({
    required int courseId,
    required String category,
    required String title,
    required File file,
  }) async {
    try {
      final formData = FormData.fromMap({
        "category": category,
        "title": title,
        "file": await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });
      await _dio.post("/courses/$courseId/resources", data: formData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getAttendance(int courseId) async {
    try {
      final response = await _dio.get("/courses/$courseId/attendance");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> submitAttendance(int courseId, List<Map<String, String>> records) async {
    try {
      await _dio.post("/courses/$courseId/attendance", data: records);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['detail'] ?? "Server error occurred";
    }
    return "Connection error: ${error.message ?? 'Unknown error'}.";
  }
}
