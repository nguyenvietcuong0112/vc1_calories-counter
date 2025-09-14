
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Yêu cầu quyền cho iOS và các nền tảng dựa trên web
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // Lấy token FCM
    final token = await getFCMToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    // Xử lý tin nhắn nền
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }
}

// Hàm xử lý tin nhắn nền phải là hàm cấp cao nhất
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}
