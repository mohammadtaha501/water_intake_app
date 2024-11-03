import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;


class Reminder extends StatefulWidget {
  const Reminder({super.key});
  @override
  _ReminderState createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _scheduleNotification(TimeOfDay time) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime.local(now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1)); // Schedule for the next day
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      'This is your reminder!',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'Weekly Notifications',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('alarm_sound'), // Custom sound
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'navigate_to_screen',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleNotificationDelay(Duration delay) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = now.add(delay);  // Schedule the notification after the specified delay

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      'This is your reminder!',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'Daily Notifications',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('alarm_sound'), // Custom sound
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'navigate_to_screen',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: null,  // No need to match date/time components since we're using a delay
    );
  }

  Future<void> _scheduleWeeklyNotification({required int weekday, required TimeOfDay time}) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // Schedule for the next occurrence of the specified weekday at the specified time.
    tz.TZDateTime scheduledDate = tz.TZDateTime.local(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    ).add(Duration(days: (weekday - now.weekday + 7) % 7)); // Adjust to next occurrence of the specified weekday

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 7)); // Move to the next week if it's in the past
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Weekly Reminder',
      'This is your weekly reminder!',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'weekly_channel_id',
          'Weekly Notifications',
          importance: Importance.max,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('alarm_sound'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'navigate_to_screen',
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Set for weekly notifications
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Notification'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Schedule Notification for 7 PM'),
          onPressed: () {
            // For demonstration, we are hardcoding the time to 7 PM
            //_scheduleNotification(TimeOfDay(hour: 19, minute: 0));
          },
        ),
      ),
    );
  }
}

class SpecificScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Specific Screen'),
      ),
      body: Center(
        child: Text('You navigated to the specific screen!'),
      ),
    );
  }
}
