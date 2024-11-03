import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';

class NotificationService {
  bool _isInitialized = false;
  static final NotificationService _instance = NotificationService._internal();
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    if (_isInitialized) return;
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/notification_icon');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload == 'navigate_to_screen') {
            navigatorKey.currentState?.pushNamed('/specificScreen');
          }
        }
    );

    await _requestNotificationPermissions();
    _createNotificationChannels();
    _isInitialized = true;
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> _requestNotificationPermissions() async {

    if (Platform.isAndroid) {
      int sdkInt = 0;
      var osVersionParts = Platform.operatingSystemVersion.split(" ");
      if (osVersionParts.length > 1) {
        sdkInt = int.tryParse(osVersionParts[1]) ?? 0;
      }
      // Request exact alarm permission if on Android 13+ (SDK 33+)
      await Permission.scheduleExactAlarm.request();
      final status1 = await FlutterLocalNotificationsPlugin().
      resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
      if (await Permission.scheduleExactAlarm.isDenied && sdkInt >= 33) {
        openAppSettings();
      }

      if (status1 != null && !status1) {
        print('Notification permission not granted');
      }
      var status = await Permission.notification.status;
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      if (status.isDenied) {
        await Permission.notification.request();
      }
    }

    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
    if (Platform.isAndroid) {

    }
  }

  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel weeklyChannel = AndroidNotificationChannel(
      'weekly_channel_id',
      'Weekly Notifications',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(weeklyChannel);
  }
}