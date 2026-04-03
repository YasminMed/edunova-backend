import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    Uint8List? bytes,
    String? fileName,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        "title": title,
        "description": description,
      });

      if (kIsWeb && bytes != null) {
        formData.files.add(MapEntry(
          "image",
          MultipartFile.fromBytes(bytes, filename: fileName ?? 'post.jpg'),
        ));
      } else if (image != null) {
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

  Future<List<dynamic>> getPosts({String? email}) async {
    try {
      final response = await _dio.get("/posts", queryParameters: {
        if (email != null) "email": email,
      });
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

  Future<List<dynamic>> getComments(int postId) async {
    try {
      final response = await _dio.get("/posts/$postId/comments");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> addComment(int postId, String email, String content) async {
    try {
      await _dio.post("/posts/$postId/comments", data: {
        "user_email": email,
        "content": content,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> likePost(int postId, String email) async {
    try {
      final response = await _dio.post("/posts/$postId/like", data: {
        "user_email": email,
      });
      return response.data['liked'] ?? false;
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
