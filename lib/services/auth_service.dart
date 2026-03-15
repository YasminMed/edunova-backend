import 'package:dio/dio.dart';

class AuthService {
  static const String baseUrl = "https://web-production-06d8c.up.railway.app";
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post("/auth/login", data: {
        "email": email,
        "password": password,
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
    String gender = "Male",
  }) async {
    try {
      final response = await _dio.post("/auth/signup", data: {
        "fullName": fullName,
        "email": email,
        "password": password,
        "gender": gender,
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
