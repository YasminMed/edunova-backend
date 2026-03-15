import 'dart:io';
import 'package:dio/dio.dart';
import 'auth_service.dart';

class PostService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AuthService.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<void> createPost({
    required String title,
    required String description,
    File? image,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "title": title,
        "description": description,
      });

      if (image != null) {
        formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(image.path, filename: image.path.split('/').last),
        ));
      }

      await _dio.post("/posts", data: formData);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getPosts() async {
    try {
      final response = await _dio.get("/posts");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePost(int id) async {
    try {
      await _dio.delete("/posts/$id");
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
