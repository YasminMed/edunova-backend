import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();
  
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AuthService.baseUrl,
      connectTimeout: const Duration(seconds: 15),
    ),
  );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 1. Request Permissions (iOS/Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('User granted notification permission');
    }

    // 2. Setup Local Notifications for Foreground Handling
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _localNotif.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap logic here (e.g., navigate to specific screen)
        if (kDebugMode) print('Notification tapped: ${details.payload}');
      },
    );

    // 3. Create Android High Importance Channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'edunova_high_importance',
        'EduNova Notifications',
        description: 'Important notifications from EduNova.',
        importance: Importance.max,
      );
      await _localNotif.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    // 4. Listen for Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 5. Listen for Background interactions (when app is opened via notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) print('App opened via notification: ${message.data}');
      // Deep link logic based on message.data['type'] and message.data['ref_id']
    });

    _initialized = true;
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
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
  }

  /// Register current device token with our backend
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

  /// Unregister device token (e.g. on logout)
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

  /// Fetch notification history for the user
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
