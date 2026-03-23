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

  Future<List<dynamic>> getCourses({String? email, String? role}) async {
    try {
      final response = await _dio.get("/courses", queryParameters: {
        if (email != null) "email": email,
        if (role != null) "role": role,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createCourse(
    String name,
    String code, {
    String department = "Software Engineering",
    String stage = "1st",
    File? image, // Native fallback
    Uint8List? imageBytes, // Web support
    String? imageFileName,
    String? lecturerEmail,
  }) async {
    try {
      final Map<String, dynamic> formDataMap = {
        "name": name,
        "code": code,
        "department": department,
        "stage": stage,
      };
      if (lecturerEmail != null) formDataMap["lecturer_email"] = lecturerEmail;
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

  // --- Quizzes Methods ---

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
      };
      
      if (fileBytes != null && fileName != null) {
        dataMap["file"] = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (file != null) {
        dataMap["file"] = await MultipartFile.fromFile(file.path, filename: p.basename(file.path));
      }

      final formData = FormData.fromMap(dataMap);
      final response = await _dio.post("/courses/$courseId/quizzes", data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getQuizzes(int courseId) async {
    try {
      final response = await _dio.get("/courses/$courseId/quizzes");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitQuizSolution({
    required int quizId,
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
      final response = await _dio.post("/quizzes/$quizId/submissions", data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getQuizSubmissions(int quizId) async {
    try {
      final response = await _dio.get("/quizzes/$quizId/submissions");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>?> getMyQuizSubmission(int quizId, String studentEmail) async {
    try {
      final response = await _dio.get(
        "/quizzes/$quizId/my-submission",
        queryParameters: {"student_email": studentEmail},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> gradeQuizSubmission({
    required int submissionId,
    required String grade,
    String? note,
  }) async {
    try {
      await _dio.post(
        "/quiz-submissions/$submissionId/grade",
        data: {"grade": grade, "note": note},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Exams & Attendance Batch Methods ---

  Future<List<dynamic>> getAllStudents({String? department, String? stage}) async {
    try {
      final response = await _dio.get("/users/students", queryParameters: {
        if (department != null) "department": department,
        if (stage != null) "stage": stage,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getExamMarksFull(int courseId) async {
    try {
      final response = await _dio.get("/courses/$courseId/exam_marks_full");
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> saveExamMark(int courseId, int studentId, String examType, String mark) async {
    try {
      await _dio.post(
        "/courses/$courseId/exam_marks",
        data: {
          "student_id": studentId,
          "exam_type": examType,
          "mark": mark,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> updateExamMark(int markId, String mark) async {
    try {
      await _dio.put(
        "/exam_marks/$markId",
        data: {"mark": mark},
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
