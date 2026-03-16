import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'package:path/path.dart' as p;

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

  Future<Map<String, dynamic>> createCourse(
    String name,
    String code, {
    File? image, // Native fallback
    Uint8List? imageBytes, // Web support
    String? imageFileName,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        "name": name,
        "code": code,
      };
      if (imageBytes != null && imageFileName != null) {
        formDataMap["image"] = MultipartFile.fromBytes(
          imageBytes,
          filename: imageFileName,
        );
      } else if (image != null) {
        formDataMap["image"] = await MultipartFile.fromFile(
          image.path,
          filename: p.basename(image.path),
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
    File? file, // Native fallback
    Uint8List? fileBytes, // Web support
    String? fileName,
  }) async {
    try {
      dynamic filePart;
      if (fileBytes != null && fileName != null) {
        filePart = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (file != null) {
        filePart = await MultipartFile.fromFile(file.path, filename: p.basename(file.path));
      } else {
        throw "No file data provided";
      }

      final formData = FormData.fromMap({
        "category": category,
        "title": title,
        "file": filePart,
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

  // --- Assignment Methods ---

  Future<Map<String, dynamic>> createAssignment({
    required int courseId,
    required String title,
    required String content,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        "title": title,
        "content": content,
        "category": "assignment",
      };
      
      if (fileBytes != null && fileName != null) {
        dataMap["file"] = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (file != null) {
        dataMap["file"] = await MultipartFile.fromFile(file.path, filename: p.basename(file.path));
      }

      final formData = FormData.fromMap(dataMap);
      final response = await _dio.post("/courses/$courseId/assignments", data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getAssignments(int courseId) async {
    try {
      final response = await _dio.get("/courses/$courseId/assignments?category=assignment");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitAssignmentSolution({
    required int assignmentId,
    required String studentEmail,
    String? solutionText,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        "student_email": studentEmail,
      };
      if (solutionText != null) dataMap["solution_text"] = solutionText;
      
      if (fileBytes != null && fileName != null) {
        dataMap["file"] = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (file != null) {
        dataMap["file"] = await MultipartFile.fromFile(file.path, filename: p.basename(file.path));
      }

      final formData = FormData.fromMap(dataMap);
      final response = await _dio.post("/assignments/$assignmentId/submissions", data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getSubmissions(int assignmentId) async {
    try {
      final response = await _dio.get("/assignments/$assignmentId/submissions");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>?> getMySubmission(int assignmentId, String studentEmail) async {
    try {
      final response = await _dio.get(
        "/assignments/$assignmentId/my-submission",
        queryParameters: {"student_email": studentEmail},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> gradeSubmission({
    required int submissionId,
    required String grade,
    String? note,
  }) async {
    try {
      await _dio.post(
        "/submissions/$submissionId/grade",
        data: {"grade": grade, "note": note},
      );
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

  // --- Quizzes Methods (Reusing Assignment Backend Structure) ---

  Future<Map<String, dynamic>> createQuiz({
    required int courseId,
    required String title,
    required String content,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        "title": title,
        "content": content,
        "category": "quiz",
      };
      
      if (fileBytes != null && fileName != null) {
        dataMap["file"] = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (file != null) {
        dataMap["file"] = await MultipartFile.fromFile(file.path, filename: p.basename(file.path));
      }

      final formData = FormData.fromMap(dataMap);
      final response = await _dio.post("/courses/$courseId/assignments", data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getQuizzes(int courseId) async {
    try {
      final response = await _dio.get("/courses/$courseId/assignments?category=quiz");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Exams & Attendance Batch Methods ---

  Future<List<dynamic>> getAllStudents() async {
    try {
      final response = await _dio.get("/users/students");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getExamMarks(int courseId, String examType) async {
    try {
      final response = await _dio.get("/courses/$courseId/exam_marks?exam_type=$examType");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> saveExamMarks(int courseId, String examType, List<Map<String, dynamic>> marksData) async {
    try {
      await _dio.post(
        "/courses/$courseId/exam_marks",
        data: {"exam_type": examType, "marks_data": marksData},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getMyExamMarks(int courseId, String studentEmail) async {
    try {
      final response = await _dio.get("/courses/$courseId/my_exam_marks?student_email=$studentEmail");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> submitBatchAttendance(int courseId, List<Map<String, dynamic>> records) async {
    try {
      await _dio.post("/courses/$courseId/attendance/batch", data: records);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
