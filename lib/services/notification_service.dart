import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'borrowit_channel',
      'Borrowing updates',
      channelDescription: 'Request status updates and return reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  int _statusId(String requestId) => (requestId.hashCode & 0x3fffffff) * 2;
  int _reminderId(String requestId) => _statusId(requestId) + 1;

  Future<void> init() async {
    if (!_supported) return;

    tz_data.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _ready = true;
  }

  Future<void> showNow({
    required String requestId,
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    await _plugin.show(
      id: _statusId(requestId),
      title: title,
      body: body,
      notificationDetails: _details,
    );
  }

  Future<void> scheduleReturnReminder({
    required String requestId,
    required List<String> equipment,
    required DateTime returnDate,
  }) async {
    if (!_ready) return;

    final when = DateTime(returnDate.year, returnDate.month, returnDate.day, 8);
    if (when.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: _reminderId(requestId),
      title: 'Return reminder',
      body: 'Please return ${equipment.join(', ')} today.',
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelReminder(String requestId) async {
    if (!_ready) return;
    await _plugin.cancel(id: _reminderId(requestId));
  }

  Future<void> sendTest() async {
    if (!_ready) return;

    await _plugin.show(
      id: 1,
      title: 'BorrowIT test',
      body: 'Notifications are working.',
      notificationDetails: _details,
    );

    await _plugin.zonedSchedule(
      id: 2,
      title: 'BorrowIT scheduled test',
      body: 'Scheduled notifications are working too.',
      scheduledDate: tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(minutes: 1)),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
