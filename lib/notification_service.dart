import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    debugPrint('NotificationService initialized without native plugin.');
  }

  Future<void> requestPermission() async {
    debugPrint('Notification permission request skipped.');
  }

  Future<void> showNotification(String title, String body) async {
    debugPrint('Notification: $title - $body');
  }
}
