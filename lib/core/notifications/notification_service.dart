import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/core/di/service_locator.dart';
import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/core/router/app_routes.dart';
import 'package:flutter_application_1/core/storage/storage_keys.dart';
import 'package:flutter_application_1/core/storage/storage_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notification payload keys
class NotificationPayloadKeys {
  static const String type = 'type';
  static const String orderId = 'order_id';
  static const String technicianId = 'technician_id';
  static const String clientId = 'client_id';
  static const String title = 'title';
  static const String body = 'body';
  static const String data = 'data';
}

/// Notification types for Client
class ClientNotificationType {
  static const String technicianAccepted = 'technician_accepted';
  static const String technicianDriving = 'technician_driving';
  static const String technicianArrived = 'technician_arrived';
  static const String technicianWorking = 'technician_working';
  static const String technicianFinished = 'technician_finished';
  static const String paymentConfirmed = 'payment_confirmed';
  static const String orderCompleted = 'order_completed';
  static const String ratingReminder = 'rating_reminder';
}

/// Notification types for Technician
class TechnicianNotificationType {
  static const String newNearbyOrder = 'new_nearby_order';
  static const String customerCancelled = 'customer_cancelled';
  static const String paymentReceived = 'payment_received';
}

/// All notification types
class NotificationType {
  static const List<String> clientTypes = [
    ClientNotificationType.technicianAccepted,
    ClientNotificationType.technicianDriving,
    ClientNotificationType.technicianArrived,
    ClientNotificationType.technicianWorking,
    ClientNotificationType.technicianFinished,
    ClientNotificationType.paymentConfirmed,
    ClientNotificationType.orderCompleted,
    ClientNotificationType.ratingReminder,
  ];

  static const List<String> technicianTypes = [
    TechnicianNotificationType.newNearbyOrder,
    TechnicianNotificationType.customerCancelled,
    TechnicianNotificationType.paymentReceived,
  ];

  static const List<String> allTypes = [...clientTypes, ...technicianTypes];
}

/// Notification channel IDs
class NotificationChannels {
  static const String highImportance = 'high_importance_channel';
  static const String defaultChannel = 'default_channel';
}

/// Notification service responsible for FCM and local notifications
class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _backgroundSubscription;
  StreamSubscription<RemoteMessage>? _terminatedSubscription;

  bool _isInitialized = false;
  String? _currentToken;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Request permissions
      await _requestPermissions();

      // Setup local notifications
      await _setupLocalNotifications();

      // Get and store FCM token
      await _getAndStoreToken();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_onTokenRefresh);

      // Setup message handlers
      _setupMessageHandlers();

      // Setup notification tap handling
      _setupNotificationTapHandling();

      _isInitialized = true;
      appLogger.i('NotificationService initialized successfully');
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to initialize NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      // iOS permissions
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Android 13+ permissions
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        await androidPlugin?.requestNotificationsPermission();
      }

      appLogger.i('Notification permissions requested');
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to request notification permissions',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Setup local notifications with channels
  Future<void> _setupLocalNotifications() async {
    const androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: darwinInitializationSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    // Create Android notification channels
    await _createNotificationChannels();

    appLogger.i('Local notifications initialized');
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // High importance channel for critical notifications
      final highImportanceChannel = AndroidNotificationChannel(
        NotificationChannels.highImportance,
        'High Importance Notifications',
        description: 'Critical notifications for order updates and alerts',
        importance: Importance.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification_sound'),
        vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      );

      // Default channel
      const defaultChannel = AndroidNotificationChannel(
        NotificationChannels.defaultChannel,
        'Default Notifications',
        description: 'General notifications',
        importance: Importance.defaultImportance,
        enableVibration: true,
        enableLights: true,
        playSound: true,
      );

      await androidPlugin.createNotificationChannel(highImportanceChannel);
      await androidPlugin.createNotificationChannel(defaultChannel);

      appLogger.i('Android notification channels created');
    }
  }

  /// Get FCM token and store in Supabase
  Future<void> _getAndStoreToken() async {
    try {
      _currentToken = await _firebaseMessaging.getToken();
      if (_currentToken != null) {
        await _storeTokenInSupabase(_currentToken!);
        await StorageService.setString(StorageKeys.fcmToken, _currentToken!);
        appLogger.i('FCM token retrieved and stored');
      }
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to get/store FCM token',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Store FCM token in Supabase profiles table
  Future<void> _storeTokenInSupabase(String token) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        appLogger.w('No authenticated user, skipping FCM token storage');
        return;
      }

      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      });

      appLogger.i('FCM token stored in Supabase for user: ${user.id}');
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to store FCM token in Supabase',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle token refresh
  Future<void> _onTokenRefresh(String newToken) async {
    _currentToken = newToken;
    await StorageService.setString(StorageKeys.fcmToken, newToken);
    await _storeTokenInSupabase(newToken);
    appLogger.i('FCM token refreshed and updated');
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    // Foreground messages
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    // Background messages (app in background)
    _backgroundSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleBackgroundMessage,
    );

    // Terminated state messages (app opened from terminated state)
    _checkInitialMessage();
  }

  /// Check for initial message when app starts from terminated state
  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        await _handleTerminatedMessage(initialMessage);
      }
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to check initial message',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Handle foreground message
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    appLogger.i('Foreground message received: ${message.messageId}');
    await _showLocalNotification(message);
  }

  /// Handle background message (app in background)
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    appLogger.i('Background message tapped: ${message.messageId}');
    await _handleNotificationTap(message);
  }

  /// Handle terminated state message
  Future<void> _handleTerminatedMessage(RemoteMessage message) async {
    appLogger.i('Terminated state message: ${message.messageId}');
    // Delay to allow router to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    await _handleNotificationTap(message);
  }

  /// Show local notification for foreground messages
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;

      final title = notification?.title ?? data['title'] ?? 'New Notification';
      final body = notification?.body ?? data['body'] ?? '';

      // Determine channel based on notification type
      final type = data[NotificationPayloadKeys.type] as String?;
      _getChannelForType(type);

      final androidDetails = AndroidNotificationDetails(
        NotificationChannels.highImportance,
        'High Importance Notifications',
        channelDescription: 'Critical notifications for order updates',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        enableLights: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        interruptionLevel: InterruptionLevel.active,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        details,
        payload: jsonEncode(message.data),
      );

      appLogger.i('Local notification shown for type: $type');
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to show local notification',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get notification channel ID based on type
  String _getChannelForType(String? type) {
    if (type == null) return NotificationChannels.highImportance;

    // Critical notifications use high importance
    final criticalTypes = [
      ClientNotificationType.technicianAccepted,
      ClientNotificationType.technicianArrived,
      ClientNotificationType.paymentConfirmed,
      TechnicianNotificationType.newNearbyOrder,
      TechnicianNotificationType.paymentReceived,
    ];

    if (criticalTypes.contains(type)) {
      return NotificationChannels.highImportance;
    }

    return NotificationChannels.defaultChannel;
  }

  /// Setup notification tap handling
  void _setupNotificationTapHandling() {
    // Handled via onDidReceiveNotificationResponse in initialization
  }

  /// Handle notification tap (foreground/background)
  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationTapFromData(data);
      } catch (e, stackTrace) {
        appLogger.e(
          'Failed to parse notification payload',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Handle background notification tap
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTap(NotificationResponse response) {
    // This runs in background isolate
    // We'll handle navigation when app comes to foreground
    if (response.payload != null) {
      StorageService.setString(
        StorageKeys.pendingNotificationPayload,
        response.payload!,
      );
    }
  }

  /// Handle notification tap from RemoteMessage
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    await _handleNotificationTapFromData(message.data);
  }

  /// Handle notification tap from parsed data
  Future<void> _handleNotificationTapFromData(Map<String, dynamic> data) async {
    try {
      final type = data[NotificationPayloadKeys.type] as String?;
      final orderId = data[NotificationPayloadKeys.orderId] as String?;

      appLogger.i('Handling notification tap: type=$type, orderId=$orderId');

      final router = sl<GoRouter>();

      // Navigate based on notification type and user role
      if (type != null && orderId != null) {
        final user = Supabase.instance.client.auth.currentUser;
        final userRole =
            user?.userMetadata?['user_type'] as String? ?? 'client';

        if (userRole == 'technician') {
          await _navigateTechnician(router, type, orderId, data);
        } else {
          await _navigateClient(router, type, orderId, data);
        }
      }
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to handle notification tap',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Navigate technician based on notification type
  Future<void> _navigateTechnician(
    GoRouter router,
    String type,
    String orderId,
    Map<String, dynamic> data,
  ) async {
    switch (type) {
      case TechnicianNotificationType.newNearbyOrder:
        router.go(AppRoutes.incomingRequests);
        break;
      case TechnicianNotificationType.customerCancelled:
      case TechnicianNotificationType.paymentReceived:
        router.go(
          AppRoutes.acceptedRequestDetail.replaceAll(':orderId', orderId),
        );
        break;
      default:
        router.go(AppRoutes.technicianHome);
    }
  }

  /// Navigate client based on notification type
  Future<void> _navigateClient(
    GoRouter router,
    String type,
    String orderId,
    Map<String, dynamic> data,
  ) async {
    switch (type) {
      case ClientNotificationType.technicianAccepted:
      case ClientNotificationType.technicianDriving:
      case ClientNotificationType.technicianArrived:
      case ClientNotificationType.technicianWorking:
      case ClientNotificationType.technicianFinished:
        router.go('/orders/$orderId/tracking');
        break;
      case ClientNotificationType.paymentConfirmed:
      case ClientNotificationType.orderCompleted:
        router.go('/orders/$orderId/completion');
        break;
      case ClientNotificationType.ratingReminder:
        router.go('/orders/$orderId/rating');
        break;
      default:
        router.go('/orders');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      appLogger.i('Subscribed to topic: $topic');
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to subscribe to topic: $topic',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      appLogger.i('Unsubscribed from topic: $topic');
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to unsubscribe from topic: $topic',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Subscribe user to role-based topics
  Future<void> subscribeToRoleTopics(String userId, String userType) async {
    try {
      // Subscribe to user-specific topic
      await subscribeToTopic('user_$userId');

      // Subscribe to role-based topic
      await subscribeToTopic('role_$userType');

      // Subscribe to all users topic for broadcasts
      await subscribeToTopic('all_users');

      appLogger.i(
        'Subscribed to role topics for user: $userId, type: $userType',
      );
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to subscribe to role topics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Unsubscribe user from role-based topics
  Future<void> unsubscribeFromRoleTopics(String userId, String userType) async {
    try {
      await unsubscribeFromTopic('user_$userId');
      await unsubscribeFromTopic('role_$userType');
      await unsubscribeFromTopic('all_users');
      appLogger.i('Unsubscribed from role topics for user: $userId');
    } catch (e, stackTrace) {
      appLogger.e(
        'Failed to unsubscribe from role topics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get current FCM token
  String? get currentToken => _currentToken;

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Handle pending notification from background tap
  Future<void> handlePendingNotification() async {
    final payload = StorageService.getString(
      StorageKeys.pendingNotificationPayload,
    );
    if (payload != null) {
      await StorageService.remove(StorageKeys.pendingNotificationPayload);
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        await _handleNotificationTapFromData(data);
      } catch (e, stackTrace) {
        appLogger.e(
          'Failed to handle pending notification',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _foregroundSubscription?.cancel();
    _backgroundSubscription?.cancel();
    _terminatedSubscription?.cancel();
    _isInitialized = false;
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  // Handle background message
  appLogger.i('Background message received: ${message.messageId}');

  // Show local notification for background messages
  final localNotifications = FlutterLocalNotificationsPlugin();
  await _showBackgroundLocalNotification(localNotifications, message);
}

/// Show local notification for background messages
Future<void> _showBackgroundLocalNotification(
  FlutterLocalNotificationsPlugin localNotifications,
  RemoteMessage message,
) async {
  try {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ?? data['title'] ?? 'New Notification';
    final body = notification?.body ?? data['body'] ?? '';

    final androidDetails = AndroidNotificationDetails(
      NotificationChannels.highImportance,
      'High Importance Notifications',
      channelDescription: 'Critical notifications for order updates',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      interruptionLevel: InterruptionLevel.active,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await localNotifications.show(
      message.hashCode,
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );
  } catch (e, stackTrace) {
    appLogger.e(
      'Failed to show background local notification',
      error: e,
      stackTrace: stackTrace,
    );
  }
}
