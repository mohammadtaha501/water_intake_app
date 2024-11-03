import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:water_intake_app/sevicesAndCustom.dart';
import 'package:water_intake_app/test.dart';

import 'notificationService.dart';
import 'screens/reminderSettingScreen.dart';
import 'screens/splash.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsBinding widgetsBinding =  WidgetsFlutterBinding.ensureInitialized();
  //FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  tz.initializeTimeZones();
  final now = DateTime.now();
  final offset = now.timeZoneOffset;
  final offsetHours = offset.inHours;
  final formattedOffset = 'Etc/GMT${offsetHours.isNegative ? '+' : '-'}${offsetHours.abs()}';
  final location = tz.getLocation(formattedOffset);
  print('Custom Location: ${location.name}');
  tz.setLocalLocation(location);
  await NotificationService().init();
  // Initialize notification settings
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: DarwinInitializationSettings(),
  );
  await NotificationService.flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // Check if the app was launched by a notification
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
  await NotificationService.flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  await Hive.initFlutter();
  await Hive.openBox('myBox');
  //await AndroidAlarmManager.initialize();
  //FlutterNativeSplash.remove();
  runApp( MaterialApp(
    navigatorKey: navigatorKey,
    home: notificationAppLaunchDetails?.didNotificationLaunchApp ?? false
        ? SplashScreen(noticeOpen: true,) // Directly navigate to the specific screen
        : SplashScreen(noticeOpen: false,),

    // initialRoute: notificationAppLaunchDetails != null &&
    //     notificationAppLaunchDetails!.didNotificationLaunchApp
    //     ? '/specificScreen' // Directly navigate to the specific screen
    //     : '/',
    // routes: {
    //   '/': (context) => SplashScreen(),
    //   '/specificScreen': (context) => QuantityScreen(),
    // },
    title: 'water Hydrate',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)
         ),
        color: Colors.white,
        ),
       ),
    )
  );
}
//
// class AlarmScreen extends StatefulWidget {
//   const AlarmScreen({super.key});
//
//   @override
//   _AlarmScreenState createState() => _AlarmScreenState();
// }
//
// class _AlarmScreenState extends State<AlarmScreen> {
//   static FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
//   static AudioPlayer audioPlayer = AudioPlayer();
//   static String? selectedRingtonePath;  // To store the selected ringtone path
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   // Function to pick a ringtone
//   Future<void> pickRingtone() async {
//     PermissionStatus status = await Permission.storage.request();
//     if (status.isGranted) {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.audio,
//       allowedExtensions:["mp3"],
//     );
//     if (result != null && result.files.single.path != null) {
//       setState(() {
//         selectedRingtonePath = result.files.single.path;  // Store the selected ringtone path
//         }
//       );
//      }
//     }else{
//       showGenericDialog(
//         tittle: "Storage access",
//         context: context,
//         message: "please enable Storage Access from setting",
//         optionBuilder:() => {
//           'OK':true,
//         },
//       );
//     }
//   }
//
//   static void playAlarmSound(String? path) async {
//     audioPlayer.setReleaseMode(ReleaseMode.loop);
//     if (path != null) {
//       await audioPlayer.play(DeviceFileSource(path));  // Play user-selected ringtone
//     } else {
//       await audioPlayer.play(AssetSource('assets/sound.mp3'));  // Default alarm sound
//     }
//     await Future.delayed(const Duration(minutes: 4));
//     stopAlarm();
//   }
//
//   static void stopAlarm() {
//     audioPlayer.stop();
//     localNotifications.cancel(0);  // Cancel notification
//   }
//
//   void scheduleAlarm() async {
//     await AndroidAlarmManager.oneShot(
//       const Duration(seconds: 30), // Alarm rings after 30 seconds
//       0,
//       alarmCallback,  // Callback function to start the alarm
//       wakeup: true,
//       rescheduleOnReboot: true,  // To reschedule on reboot if needed
//     );
//   }
//
//   static Future<void> alarmCallback() async {
//     const androidInitializationSettings = AndroidInitializationSettings('app_icon');
//     const initializationSettings = InitializationSettings(
//       android: androidInitializationSettings,
//     );
//     localNotifications.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (response) {
//         stopAlarm();
//       },
//     );
//     await localNotifications.show(
//       0,
//       'Water Intake',
//       'Time to drink water!',
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'alarm_channel',
//           'Alarm Notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//           sound: const RawResourceAndroidNotificationSound('alarm'),
//           enableVibration: true,
//           vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
//           additionalFlags: Int32List.fromList(<int>[4]),
//           actions: <AndroidNotificationAction>[
//             const AndroidNotificationAction('STOP_ALARM', 'Stop Alarm'),
//             const AndroidNotificationAction('ADD_WATER', 'Add Water'),
//           ],
//         ),
//       ),
//     );
//     playAlarmSound(selectedRingtonePath);  // Play the selected ringtone
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Reminder App"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 pickRingtone();  // User selects a ringtone
//               },
//               child: const Text('Pick a Ringtone'),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 scheduleAlarm();  // Schedule alarm to ring after 30 seconds
//               },
//               child: const Text('Set Alarm for 30 Seconds'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
