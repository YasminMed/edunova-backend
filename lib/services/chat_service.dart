import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/chat_session.dart';
import '../models/group_chat.dart';

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

  Future<List<GroupChat>> getUserGroupChats(String userEmail) async {
    try {
      final response = await _dio.get("/groups/user/$userEmail");
      return (response.data as List).map((item) => GroupChat.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int?> createGroupChat(String name, String adminEmail, List<String> memberEmails, {String? imagePath, Uint8List? bytes, String? fileName}) async {
    try {
      final Map<String, dynamic> formDataMap = {
        "name": name,
        "admin_email": adminEmail,
        "member_emails": memberEmails, // Backend parses strings 
      };

      if (kIsWeb && bytes != null) {
        formDataMap["photo"] = MultipartFile.fromBytes(bytes, filename: fileName ?? 'group.jpg');
      } else if (imagePath != null && imagePath.isNotEmpty) {
        formDataMap["photo"] = await MultipartFile.fromFile(imagePath);
      }

      final formData = FormData.fromMap(formDataMap);

      final response = await _dio.post(
        "/groups",
        data: formData,
      );
      return response.data['group_id'];
    } catch (e) {
      return null;
    }
  }

  Future<List<ChatMessage>> getGroupMessages(int groupId) async {
    try {
      final response = await _dio.get("/groups/$groupId/messages");
      return (response.data as List).map((item) => ChatMessage.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ChatMessage?> sendGroupMessage(int groupId, String senderEmail, String content) async {
    try {
      final response = await _dio.post(
        "/groups/$groupId/messages",
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

  Future<List<ChatUser>> getAllUsers() async {
    try {
      final response = await _dio.get("/users/all");
      return (response.data as List)
          .map((item) => ChatUser.fromJson(item))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getGroupDetails(int groupId) async {
    try {
      final response = await _dio.get("/groups/$groupId");
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateGroupChat(int groupId, String adminEmail, {String? name, String? imagePath, Uint8List? bytes, String? fileName}) async {
    try {
      final Map<String, dynamic> data = {"admin_email": adminEmail};
      if (name != null) data["name"] = name;
      
      if (kIsWeb && bytes != null) {
        data["photo"] = MultipartFile.fromBytes(bytes, filename: fileName ?? 'group.jpg');
      } else if (imagePath != null && imagePath.isNotEmpty) {
        data["photo"] = await MultipartFile.fromFile(imagePath);
      }
      
      final response = await _dio.put("/groups/$groupId", data: FormData.fromMap(data));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addGroupMembers(int groupId, String adminEmail, List<String> memberEmails) async {
    try {
      final response = await _dio.post(
        "/groups/$groupId/members",
        data: FormData.fromMap({
          "admin_email": adminEmail,
          "member_emails": jsonEncode(memberEmails),
        })
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeGroupMember(int groupId, String adminEmail, String userEmail) async {
    try {
      final response = await _dio.delete(
        "/groups/$groupId/members/$userEmail",
        queryParameters: {"admin_email": adminEmail}
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> transferGroupOwnership(int groupId, String adminEmail, String newOwnerEmail) async {
    try {
      final response = await _dio.put(
        "/groups/$groupId/owner",
        data: FormData.fromMap({
          "admin_email": adminEmail,
          "new_owner_email": newOwnerEmail,
        })
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

