import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

import '../models/user_notification.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // Channel IDs for different notification types
  static const String _adminChannelId = 'gam3ya_admin_channel';
  static const String _paymentChannelId = 'gam3ya_payment_channel';
  static const String _userChannelId = 'gam3ya_user_channel';
  static const String _gam3yaChannelId = 'gam3ya_events_channel';
  static const String _turnChannelId = 'gam3ya_turn_channel';
  static const String _generalChannelId = 'gam3ya_general_channel';
  Future<void> initialize() async {
    // Initialize time zones
    tzData.initializeTimeZones();
    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification taps
        print('Notification tapped: ${response.payload}');
        _handleNotificationTap(response.payload);
      },
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    // Configure Firebase Messaging
    await _configureFirebaseMessaging();

    // Request permissions
    await requestPermissions();
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _adminChannelId,
          'Admin Notifications',
          description: 'Important notifications from administrators',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _paymentChannelId,
          'Payment Notifications',
          description: 'Notifications about payments and dues',
          importance: Importance.high,
        ),
      );

      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          _userChannelId,
          'User Notifications',
          description: 'Notifications about user account activities',
          importance: Importance.high,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _gam3yaChannelId,
          'Gam3ya Events',
          description: 'Updates about Gam3ya groups',
          importance: Importance.high,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _turnChannelId,
          'Turn Notifications',
          description: 'Notifications about your turns in Gam3ya',
          importance: Importance.high,
          enableVibration: true,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _generalChannelId,
          'General Notifications',
          description: 'General app updates and information',
          importance: Importance.low,
        ),
      );
    }
  }

  Future<void> _configureFirebaseMessaging() async {
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');

        // Determine notification type from data
        String notificationType = message.data['type'] ?? 'general';

        // Show notification based on type
        _showTypedNotification(
          notificationType: notificationType,
          id: message.hashCode,
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          payload: message.data['payload'] ?? '',
        );
      }
    });

    // Handle when app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      String? payload = message.data['payload'];
      _handleNotificationTap(payload);
    });
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null) return;
    // Parse the payload and handle navigation or other actions
    if (payload.startsWith('payment_')) {
      // Navigate to payment details
      print('Navigate to payment details: $payload');
    } else if (payload.startsWith('turn_')) {
      // Navigate to turn details
      print('Navigate to turn details: $payload');
    } else if (payload.startsWith('gam3ya_')) {
      // Navigate to gam3ya details
      print('Navigate to gam3ya details: $payload');
    } else if (payload.startsWith('admin_')) {
      // Navigate to admin message
      print('Navigate to admin message: $payload');
    } else if (payload.startsWith('user_')) {
      // Navigate to user profile
      print('Navigate to user profile: $payload');
    }

    // Add navigation logic here or use a navigation service
  }

  Future<void> requestPermissions() async {
    // Request permissions for Firebase Messaging
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _showTypedNotification({
    required String notificationType,
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    String channelId;
    // Determine channel based on notification type
    switch (notificationType) {
      case 'admin':
        channelId = _adminChannelId;
        break;
      case 'payment':
        channelId = _paymentChannelId;
        break;
      case 'user':
        channelId = _userChannelId;
        break;
      case 'gam3ya':
        channelId = _gam3yaChannelId;
        break;
      case 'turn':
        channelId = _turnChannelId;
        break;
      case 'general':
      default:
        channelId = _generalChannelId;
        break;
    }

    // Create notification details
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          '$notificationType Notifications',
          channelDescription: 'Notifications for $notificationType events',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Admin notifications - highest priority
  Future<void> sendAdminNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _showTypedNotification(
      notificationType: 'admin',
      id: id,
      title: title,
      body: body,
      payload: payload ?? 'admin$id',
    );
    // You might also want to send this to a server or Firebase Cloud Messaging
    // to notify all users
    print('Sending admin notification: $title - $body');
  }

  // Payment notifications
  Future<void> sendPaymentNotification(
    String title,
    String body, {
    String? payload,
    Map<String, dynamic>? paymentDetails,
  }) async {
    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _showTypedNotification(
      notificationType: 'payment',
      id: id,
      title: title,
      body: body,
      payload: payload ?? 'payment$id',
    );
    // Log payment notification for analytics or tracking
    print('Sending payment notification: $title - $body');
    if (paymentDetails != null) {
      print('Payment details: $paymentDetails');
    }
  }

  // User-related notifications
  Future<void> sendUserNotification(
    String title,
    String body, {
    String? userId,
    String? payload,
  }) async {
    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _showTypedNotification(
      notificationType: 'user',
      id: id,
      title: title,
      body: body,
      payload: payload ?? 'user_id{userId != null ? "_$userId" : ""}',
    );

    print('Sending user notification: $title - $body');
  }

  // Gam3ya group notifications
  Future<void> sendGam3yaNotification(
    String title,
    String body, {
    String? gam3yaId,
    String? payload,
  }) async {
    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _showTypedNotification(
      notificationType: 'gam3ya',
      id: id,
      title: title,
      body: body,
      payload: payload ?? 'gam3ya_id{gam3yaId != null ? "_$gam3yaId" : ""}',
    );

    print('Sending Gam3ya notification: $title - $body');
  }

  // Turn notifications
  Future<void> sendTurnNotification(
    String title,
    String body, {
    String? gam3yaId,
    String? turnId,
    String? payload,
  }) async {
    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _showTypedNotification(
      notificationType: 'turn',
      id: id,
      title: title,
      body: body,
      payload: payload ?? 'turn_id{turnId != null ? "_$turnId" : ""}',
    );

    print('Sending turn notification: $title - $body');
  }

  // General notifications - lowest priority
  Future<void> sendGeneralNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await _showTypedNotification(
      notificationType: 'general',
      id: id,
      title: title,
      body: body,
      payload: payload ?? 'general$id',
    );
    print('Sending general notification: $title - $body');
  }

  // Schedule payment reminders for Gam3ya
  Future<void> schedulePaymentReminder({
    required int id,
    required String gam3yaName,
    required double amount,
    required DateTime dueDate,
    String? gam3yaId,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      dueDate.subtract(const Duration(days: 1)),
      tz.local,
    );
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _paymentChannelId,
          'Payment Reminders',
          channelDescription: 'Reminders for upcoming Gam3ya payments',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      'Payment Reminder',
      'Your payment of $amount for $gam3yaName is due tomorrow',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'payment_reminder_$id${gam3yaId != null ? "_$gam3yaId" : ""}',
    );
  }

  // Schedule turn reminder
  Future<void> scheduleTurnReminder({
    required int id,
    required String gam3yaName,
    required DateTime turnDate,
    required double amount,
    String? turnId,
  }) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      turnDate.subtract(const Duration(days: 2)),
      tz.local,
    );
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _turnChannelId,
          'Turn Reminders',
          channelDescription: 'Reminders for upcoming Gam3ya turns',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      'Turn Coming Up!',
      'Your turn to receive $amount in $gam3yaName is coming up in 2 days',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      //uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'turn_reminder_$id${turnId != null ? "_$turnId" : ""}',
    );
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<String?> getFirebaseToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> initializeNotifications() async {
    await initialize();
    await requestPermissions();
  }
   Future<void>reads()async{
    await _localNotifications.getNotificationAppLaunchDetails();}
    Future<void> clearNotificationHistory() async {
    await _localNotifications.cancelAll();
    print('Cleared all notification history');
  }
  // markAsRead
  
  Future<void> setNotificationChannelImportance(
    String channelId,
    Importance importance,
  ) async {
    final AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      'Gam3ya Notifications',
      description: 'Notifications for Gam3ya app events',
      importance: importance,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> deleteNotificationChannel(String channelId) async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.deleteNotificationChannel(channelId);
  }

  // Subscribe to topic for targeted notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
//get
Future<void> getNotificationPermission() async {
    final NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission for notifications');
    } else {
      print('User denied permission for notifications');
    }
  }
Stream<List<UserNotification>> getUserNotifications(String userId) {
  return FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return UserNotification.fromJson(data as String);
          }).toList());
}

  
// showLocalNotification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    await _localNotifications.show(id, title, body, NotificationDetails());
    print('Notification shown with id: $id');
  }

}

// Firebase Messaging Background Handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // You might want to show a notification here as well
  // However, you won't have access to the NotificationService instance
  // in this background handler, so you'll need a minimal implementation
}
