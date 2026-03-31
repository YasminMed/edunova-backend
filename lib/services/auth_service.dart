import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class AuthService {
  static const String baseUrl = "https://web-production-06d8c.up.railway.app";
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    try {
      final response = await _dio.post("/auth/login", data: {
        "email": email,
        "password": password,
        "role": role,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? department,
    String? stage,
    String gender = "Male",
  }) async {
    try {
      final response = await _dio.post("/auth/signup", data: {
        "fullName": fullName,
        "email": email,
        "password": password,
        "gender": gender,
        "role": role,
        "department": department,
        "stage": stage,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await _dio.post("/auth/send-otp", data: {
        "email": email,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post("/auth/verify-otp", data: {
        "email": email,
        "otp": otp,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    required String role,
    String? department,
    String? stage,
  }) async {
    try {
      final response = await _dio.put("/auth/update-profile", data: {
        "fullName": fullName,
        "email": email,
        "role": role,
        "department": department,
        "stage": stage,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> updateProfilePhoto({
    required String email,
    required String role,
    String? filePath,
    Uint8List? bytes,
    String? fileName,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'email': email,
        'role': role,
      };

      if (kIsWeb && bytes != null) {
        data['file'] = MultipartFile.fromBytes(bytes, filename: fileName ?? 'profile.jpg');
      } else if (filePath != null) {
        data['file'] = await MultipartFile.fromFile(filePath);
      } else {
        throw Exception("No file provided for upload");
      }

      final formData = FormData.fromMap(data);
      final response = await _dio.post('/auth/update-profile-photo', data: formData);
      return response.data['photoUrl'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
    required String role,
  }) async {
    try {
      final response = await _dio.post("/auth/change-password", data: {
        "email": email,
        "oldPassword": oldPassword,
        "newPassword": newPassword,
        "role": role,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteAccount({
    required String email,
    required String role,
  }) async {
    try {
      final response = await _dio.delete("/auth/delete-account", data: {
        "email": email,
        "role": role,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      return error.response?.data['detail'] ?? "Server error occurred";
    }
    if (error.type == DioExceptionType.connectionTimeout) {
      return "Connection timed out. Please check your internet or try again later.";
    }
    return "Connection error: ${error.message ?? 'Unknown error'}. Please try again.";
  }
}
