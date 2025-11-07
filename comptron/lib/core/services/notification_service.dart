import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/notification.dart' as models;
import 'local_storage_service.dart';

class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  late LocalStorageService _storage;

  NotificationService._();

  static Future<NotificationService> getInstance() async {
    if (_instance == null) {
      _instance = NotificationService._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    _storage = await LocalStorageService.getInstance();

    // Request notification permissions
    await _requestPermissions();

    // Initialize local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _requestPermissions() async {
    // Request notification permission
    final status = await Permission.notification.request();
    if (status.isDenied) {
      print('Notification permission denied');
    }

    // For Android 13+, request POST_NOTIFICATIONS permission
    if (await Permission.notification.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: Handle notification tap - navigate to relevant screen
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'comptron_channel',
      'Comptron Notifications',
      channelDescription: 'Notifications for Comptron app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    // Save notification to local storage
    final notification = models.Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: models.NotificationType.general,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await _storage.saveNotification(notification);
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    int? id,
  }) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      'comptron_scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Scheduled notifications for Comptron app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosNotificationDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _localNotifications.zonedSchedule(
      id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> scheduleEventReminder({
    required String eventId,
    required String eventTitle,
    required DateTime eventDate,
  }) async {
    // Schedule 24 hours before event
    final reminderTime = eventDate.subtract(const Duration(hours: 24));

    if (reminderTime.isAfter(DateTime.now())) {
      await scheduleNotification(
        title: 'Event Reminder',
        body: 'Don\'t forget about $eventTitle tomorrow!',
        scheduledDate: reminderTime,
        payload: eventId,
        id: eventId.hashCode,
      );

      // Event reminder scheduled successfully
    }
  }

  Future<void> cancelEventReminder(String eventId) async {
    // Cancel scheduled notification
    await _localNotifications.cancel(eventId.hashCode);
  }

  Future<void> showAnnouncementNotification({
    required String title,
    required String body,
    required String announcementId,
  }) async {
    await showLocalNotification(
      title: 'New Announcement',
      body: '$title: $body',
      payload: 'announcement_$announcementId',
    );
  }

  Future<void> showEventUpdateNotification({
    required String eventTitle,
    required String updateMessage,
    required String eventId,
  }) async {
    await showLocalNotification(
      title: 'Event Update',
      body: '$eventTitle: $updateMessage',
      payload: 'event_$eventId',
    );
  }

  Future<List<models.Notification>> getNotifications() async {
    return _storage.getNotifications();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final notifications = await getNotifications();
    final notificationIndex = notifications.indexWhere(
      (n) => n.id == notificationId,
    );

    if (notificationIndex != -1) {
      final notification = notifications[notificationIndex];
      final updatedNotification = models.Notification(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        type: notification.type,
        isRead: true,
        createdAt: notification.createdAt,
        eventId: notification.eventId,
        data: notification.data,
      );
      await _storage.updateNotification(updatedNotification);
    }
  }

  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
    await _storage.clearNotifications();
  }

  Future<int> getUnreadCount() async {
    final notifications = await getNotifications();
    return notifications.where((n) => !n.isRead).length;
  }
}
