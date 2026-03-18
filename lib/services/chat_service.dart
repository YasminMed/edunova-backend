import 'package:dio/dio.dart';
import '../models/chat_session.dart';

class ChatService {
  static const String baseUrl = "https://web-production-06d8c.up.railway.app";
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<ChatUser>> searchUsers(String query) async {
    try {
      final response = await _dio.get("/users/search", queryParameters: {
        "query": query,
      });
      return (response.data as List)
          .map((item) => ChatUser.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<ChatSession?> startChatSession(String currentUserEmail, int targetUserId) async {
    try {
      final response = await _dio.post(
        "/chat/sessions",
        data: FormData.fromMap({
          "current_user_email": currentUserEmail,
          "target_user_id": targetUserId,
        }),
      );
      return ChatSession(
        sessionId: response.data['id'],
        otherUser: ChatUser.fromJson(response.data['other_user']),
        latestMessage: "",
        latestMessageTime: "",
        unreadCount: 0,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<ChatSession>> getUserChatSessions(String userEmail) async {
    try {
      final response = await _dio.get("/chat/sessions/$userEmail");
      return (response.data as List)
          .map((item) => ChatSession.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ChatMessage>> getChatMessages(int sessionId, String currentUserEmail) async {
    try {
      final response = await _dio.get("/chat/sessions/$sessionId/messages", queryParameters: {
        "current_user_email": currentUserEmail,
      });
      return (response.data as List)
          .map((item) => ChatMessage.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<ChatMessage?> sendChatMessage(int sessionId, String senderEmail, String content) async {
    try {
      final response = await _dio.post(
        "/chat/sessions/$sessionId/messages",
        data: FormData.fromMap({
          "sender_email": senderEmail,
          "content": content,
        }),
      );
      return ChatMessage.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
