import codecs
import re

path = r'c:\src\flutter-apps\edunova_application\lib\services\material_service.dart'
with codecs.open(path, 'r', 'utf-8') as f:
    text = f.read()

target1 = """  // --- Quizzes Methods (Reusing Assignment Backend Structure) ---

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
  }"""

replacement1 = """  // --- Quizzes Methods ---

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
  }"""

target2 = """  Future<List<dynamic>> getExamMarks(int courseId, String examType) async {
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
  }"""

replacement2 = """  Future<List<dynamic>> getExamMarksFull(int courseId) async {
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
  }"""

text = text.replace(target1, replacement1)
text = text.replace(target2, replacement2)

with codecs.open(path, 'w', 'utf-8') as f:
    f.write(text)
print("material_service.dart patched")
