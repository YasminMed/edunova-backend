import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

// ─── Background message handler (must be top-level function) ───────────────
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // For data-only chat/group_chat messages, check mute + global toggle.
  final prefs = await SharedPreferences.getInstance();
  final globalEnabled = prefs.getBool('notif_enabled') ?? true;
  if (!globalEnabled) return;

  final type = message.data['type'] ?? '';

  if (type == 'chat') {
    final sessionId = message.data['session_id'] ?? '';
    final isMuted = prefs.getBool('muted_chat_$sessionId') ?? false;
    if (isMuted) return;
  } else if (type == 'group_chat') {
    final groupId = message.data['group_id'] ?? '';
    final isMuted = prefs.getBool('muted_chat_group_$groupId') ?? false;
    if (isMuted) return;
  }

  // Show local notification
  final plugin = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await plugin.initialize(initSettings);

  final senderName = message.data['sender_name'] ?? 'New Message';
  final preview = message.data['content_preview'] ?? '';

  await plugin.show(
    message.hashCode,
    senderName,
    preview,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'edunova_high_importance',
        'EduNova Notifications',
        icon: '@mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

// ─── NotificationService ───────────────────────────────────────────────────
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthService.baseUrl,
      connectTimeout: const Duration(seconds: 15),
    ),
  );

  bool _initialized = false;

  // ── Initialization ────────────────────────────────────────────────────────
  Future<void> initialize() async {
    if (_initialized) return;

    // Register top-level background handler
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

    // 1. Request Permissions
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2. Setup local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (kDebugMode) print('Notification tapped: ${details.payload}');
      },
    );

    // 3. Create Android high-importance channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'edunova_high_importance',
        'EduNova Notifications',
        description: 'Important notifications from EduNova.',
        importance: Importance.max,
      );
      await _localNotif
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 4. Foreground message handler (covers data-only + normal)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final globalEnabled = await isGloballyEnabled();
      if (!globalEnabled) return;

      final type = message.data['type'] ?? '';

      // Chat message mute check
      if (type == 'chat') {
        final sessionId = message.data['session_id'] ?? '';
        if (await isChatMuted('chat_$sessionId')) return;
        _showChatLocalNotification(
          senderName: message.data['sender_name'] ?? 'New Message',
          preview: message.data['content_preview'] ?? '',
          hashCode: message.hashCode,
        );
        return;
      }

      if (type == 'group_chat') {
        final groupId = message.data['group_id'] ?? '';
        if (await isChatMuted('group_$groupId')) return;
        final groupName = message.data['group_name'] ?? 'Group';
        _showChatLocalNotification(
          senderName: '${message.data['sender_name'] ?? ''} @ $groupName',
          preview: message.data['content_preview'] ?? '',
          hashCode: message.hashCode,
        );
        return;
      }

      // Normal academic notification (has notification payload)
      _showLocalNotification(message);
    });

    // 5. Background notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) print('App opened via notification: ${message.data}');
    });

    _initialized = true;
  }

  // ── Local Notification Display ─────────────────────────────────────────────
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'edunova_high_importance',
          'EduNova Notifications',
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  void _showChatLocalNotification({
    required String senderName,
    required String preview,
    required int hashCode,
  }) {
    _localNotif.show(
      hashCode,
      senderName,
      preview,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'edunova_high_importance',
          'EduNova Notifications',
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Global Enable / Disable ────────────────────────────────────────────────

  /// Returns true if notifications are enabled (default: true).
  Future<bool> isGloballyEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notif_enabled') ?? true;
  }

  /// Disables all notifications: unregisters FCM token from backend + saves pref.
  Future<void> disableNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notif_enabled', false);
      // Unregister token from backend → server stops sending to this device
      await unregisterDeviceToken();
    } catch (e) {
      if (kDebugMode) print('Failed to disable notifications: $e');
    }
  }

  /// Re-enables notifications: saves pref + re-registers FCM token.
  Future<void> enableNotifications(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notif_enabled', true);
      await registerDeviceToken(userId);
    } catch (e) {
      if (kDebugMode) print('Failed to enable notifications: $e');
    }
  }

  // ── Per-Chat Mute ──────────────────────────────────────────────────────────

  /// Mutes a specific chat. [key] = "chat_{sessionId}" or "group_{groupId}".
  Future<void> muteChat(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('muted_chat_$key', true);
  }

  /// Unmutes a specific chat.
  Future<void> unmuteChat(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('muted_chat_$key');
  }

  /// Returns true if the given chat is muted.
  Future<bool> isChatMuted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('muted_chat_$key') ?? false;
  }

  // ── Device Token Management ────────────────────────────────────────────────

  /// Register current device token with our backend.
  Future<void> registerDeviceToken(int userId) async {
    try {
      String? token = await _fcm.getToken();
      if (token == null) return;

      final response = await _dio.post(
        "/devices/register",
        data: {
          "user_id": userId,
          "fcm_token": token,
          "platform": Platform.isIOS ? "ios" : "android",
        },
      );

      if (kDebugMode) print('Device token registered: ${response.data}');
    } catch (e) {
      if (kDebugMode) print('Failed to register device token: $e');
    }
  }

  /// Unregister device token (call on logout or when notifications disabled).
  Future<void> unregisterDeviceToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token == null) return;

      await _dio.delete("/devices/token/$token");
      if (kDebugMode) print('Device token unregistered');
    } catch (e) {
      if (kDebugMode) print('Failed to unregister device token: $e');
    }
  }

  // ── Notification History ───────────────────────────────────────────────────

  /// Fetch notification history for the user.
  Future<List<dynamic>> getNotificationHistory(String userEmail) async {
    try {
      final response = await _dio.get(
        "/notifications",
        queryParameters: {"user_email": userEmail},
      );
      return response.data;
    } catch (e) {
      if (kDebugMode) print('Failed to fetch notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _dio.post("/notifications/$notificationId/read");
    } catch (e) {
      if (kDebugMode) print('Failed to mark notification as read: $e');
    }
  }
}
