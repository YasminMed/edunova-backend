import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ChatbotService {
  static const String _endpoint = '/chat';

  /// Sends a message history to the AI and gets a response.
  /// [modelType] can be 'gemini', 'deepseek', or 'groq'
  static Future<String> sendMessage({
    required List<Map<String, String>> messages,
    required String modelType,
    required String userRole,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AuthService.baseUrl}$_endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': messages,
          'model_type': modelType,
          'user_role': userRole,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? "I'm sorry, I couldn't understand that.";
      } else {
        final data = jsonDecode(response.body);
        String errorMsg = data['detail'] ?? "API error";
        return "System Exception: $errorMsg (Please check if the API key for '$modelType' is configured in the backend).";
      }
    } catch (e) {
      return "Network error. Please try again later. Details: $e";
    }
  }
}
