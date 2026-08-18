// Stub implementations for flutter_local_notifications types on web.
// These are no-ops since local notifications are not supported on web.

import 'dart:typed_data';

class FlutterLocalNotificationsPlugin {
  Future<bool?> initialize(
    dynamic settings, {
    dynamic onDidReceiveNotificationResponse,
    dynamic onDidReceiveBackgroundNotificationResponse,
  }) async => false;

  Future<void> show(
    int id,
    String? title,
    String? body,
    dynamic details, {
    String? payload,
  }) async {}

  T? resolvePlatformSpecificImplementation<T>() => null;
}

class AndroidInitializationSettings {
  const AndroidInitializationSettings(String iconName);
}

class DarwinInitializationSettings {
  const DarwinInitializationSettings({
    bool requestAlertPermission = false,
    bool requestBadgePermission = false,
    bool requestSoundPermission = false,
    bool defaultPresentAlert = false,
    bool defaultPresentBadge = false,
    bool defaultPresentSound = false,
  });
}

class InitializationSettings {
  const InitializationSettings({
    dynamic android,
    dynamic iOS,
  });
}

class AndroidFlutterLocalNotificationsPlugin {
  Future<bool?> requestNotificationsPermission() async => false;
  Future<void> createNotificationChannel(dynamic channel) async {}
}

class AndroidNotificationChannel {
  const AndroidNotificationChannel(
    this.id,
    this.name, {
    String? description,
    int importance = 0,
    bool enableVibration = false,
    bool enableLights = false,
    bool playSound = false,
    dynamic sound,
    Int64List? vibrationPattern,
  });
  final String id;
  final String name;
}

class AndroidNotificationDetails {
  const AndroidNotificationDetails(
    this.channelId,
    this.channelName, {
    String? channelDescription,
    int importance = 0,
    int priority = 0,
    bool enableVibration = false,
    bool enableLights = false,
    bool playSound = false,
    String? icon,
    dynamic largeIcon,
    Int64List? vibrationPattern,
    dynamic category,
    dynamic visibility,
  });
  final String channelId;
  final String channelName;
}

class DrawableResourceAndroidBitmap {
  const DrawableResourceAndroidBitmap(String iconName);
}

class DarwinNotificationDetails {
  const DarwinNotificationDetails({
    bool presentAlert = false,
    bool presentBadge = false,
    bool presentSound = false,
    String? sound,
    int? interruptionLevel,
  });
}

class NotificationDetails {
  const NotificationDetails({dynamic android, dynamic iOS});
}

class NotificationResponse {
  String? get payload => null;
  int get id => 0;
  String? get actionId => null;
}

class AndroidNotificationCategory {
  static const message = 'message';
}

class Importance {
  static const high = 4;
  static const defaultImportance = 3;
}

class Priority {
  static const high = 1;
  static const defaultPriority = 0;
}

class NotificationVisibility {
  static const public = 0;
}

class InterruptionLevel {
  static const active = 1;
}
