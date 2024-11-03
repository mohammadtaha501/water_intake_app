import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'notificationService.dart';

class TimeScreen extends StatefulWidget {
  @override
  _TimeScreenState createState() => _TimeScreenState();
}

class _TimeScreenState extends State<TimeScreen> {
  TimeOfDay? selectedTime;
  Future<void> _scheduleNotification(TimeOfDay time, int noticeID) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime.local(now.year, now.month, now.day, time.hour, time.minute);

      if (scheduledDate.isBefore(now)) {
        print("moving to next day");
        scheduledDate = scheduledDate.add(Duration(days: 1)); // Schedule for the next day
      }
      print('Scheduled notification time: ${scheduledDate.toString()}');
      print('sheduling is going to start');
      await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
        noticeID,
        'Reminder',
        'This is your reminder!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'Daily Notifications',
            importance: Importance.max,
            priority: Priority.high,
            //sound: RawResourceAndroidNotificationSound('alarm_sound'), // Custom sound
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        androidAllowWhileIdle: true,
        payload: 'navigate_to_screen',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print("sheduling complete");
    } catch (e) {
      print('Error scheduling notification: $e');
      throw e;
      // Handle error gracefully, maybe log or show user a message
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the selected time if available
            selectedTime != null
                ? Text(
              'Selected Time: ${selectedTime!.format(context)}',
              style: TextStyle(fontSize: 24),
            )
                : Text(
              'No time selected',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // Button to trigger adding two minutes
            ElevatedButton(
              onPressed: () async{
                final now = TimeOfDay.now();

                // Add 2 minutes to the current time
                int newMinutes = now.minute + 10;
                int newHour = now.hour;

                // If minutes exceed 59, adjust hour and minutes
                if (newMinutes >= 60) {
                  newMinutes = newMinutes - 60;
                  newHour = (newHour + 1) % 24; // Wrap around hour if it exceeds 23
                }
                final selectedTime = TimeOfDay(hour: newHour, minute: newMinutes);
                await _scheduleNotification(selectedTime,1000);
                setState(() {});
              },
              child: Text('Add 2 Minutes'),
            ),
          ],
        ),
      ),
    );
  }
}
//--------------------------------------------------