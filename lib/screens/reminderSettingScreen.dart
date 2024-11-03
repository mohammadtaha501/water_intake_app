import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:timezone/timezone.dart' as tz;

import '../notificationDatabase.dart';
import '../notificationService.dart';
import '../sevicesAndCustom.dart';
import 'mainscreen.dart';

int startTime = 1;
int endTime = 0;
bool isStartTimeAm = true;
bool isEndTimeAm = true;

class ReminderSetting extends StatefulWidget {
  const ReminderSetting({super.key});

  @override
  State<ReminderSetting> createState() => _ReminderSettingState();
}

class _ReminderSettingState extends State<ReminderSetting> {
  final FixedExtentScrollController _controller = FixedExtentScrollController();
  final FixedExtentScrollController _controller1 = FixedExtentScrollController();
  void resetScrollPosition() {
    _controller.jumpToItem(0); // Reset to the first item
    _controller1.jumpTo(0);
  }
  final GlobalKey _firstMenuKey = GlobalKey();
  final GlobalKey _secondMenuKey = GlobalKey();
  int selectedValue = 1000;
  String remindAfter = 'Every half hour';
  List<String> remindOptions = [
    'Every half hour',
    'Every 1 hour',
    'Every 2 hour',
    'Every 3 hour',
    'Every 4 hour'
  ];
  List<String> repeatAfter = [];
  List<String> repeatOptions = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'), // You can customize the title
          content: SizedBox(
            height: 300,
            width: double.maxFinite, // Adjust the width if needed
            child: Center(           // Center the message text
              child: Text(
                message,
                textAlign: TextAlign.center, // Center the text
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog when pressed
              },
              child: Center(child: Text('OK')), // OK button text
            ),
          ],
        );
      },
    );
  }

  int weekdayNameToNumber(String weekdayName) {
    switch (weekdayName.toLowerCase()) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      case 'sunday':
        return 7;
      default:
        throw ArgumentError('Invalid weekday name: $weekdayName');
    }
  }

  int parseInterval(String intervalString) {
    if (intervalString.contains('Every half hour')) {
      return 30;
    } else {
      // Extract the number from the string
      final number = int.parse(intervalString.split(' ')[1]);
      return number;
    }
  }

  Future<void> _scheduleNotification(TimeOfDay time, int noticeID,int ml) async {
    // // Get the current time
    // final now = TimeOfDay.now();
    //
    // // Calculate the difference in hours and minutes
    // int hourDifference = time.hour - now.hour;
    // int minuteDifference = time.minute - now.minute;
    //
    // // Adjust if the minutes or hours result in negative values
    // if (minuteDifference < 0) {
    //   minuteDifference += 60;
    //   hourDifference -= 1;
    // }
    //
    // if (hourDifference < 0) {
    //   hourDifference += 24;
    // }
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime.local(now.year, now.month, now.day, time.hour, time.minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(Duration(days: 1)); // Schedule for the next day
      }
      final String str = 'This is your water reminder for the $ml ml';
      await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
        noticeID,
        'Water Reminder',
        str,
        scheduledDate,
        //tz.TZDateTime.now(tz.local).add(Duration(minutes: 1,hours: 0)),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'Daily Notifications',
            importance: Importance.max,
            priority: Priority.high,
            sound: null,
            //sound: RawResourceAndroidNotificationSound('alarm_sound'), // Custom sound
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        androidAllowWhileIdle: true,
        payload: 'navigate_to_screen',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      throw e;
      // Handle error gracefully, maybe log or show user a message
    }
  }

  Future<void> _scheduleWeeklyNotification({required int weekday, required TimeOfDay time, required int noticeID,required int ml}) async {
    try {
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
      final String str = 'This is your water reminder for the $ml ml';
      await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
        noticeID,
        'Water Reminder',
        str,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'weekly_channel_id',
            'Weekly Notifications',
            importance: Importance.max,
            priority: Priority.high,
            sound: null,
            //sound: RawResourceAndroidNotificationSound('alarm_sound'),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        androidAllowWhileIdle: true,
        payload: 'navigate_to_screen',
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Set for weekly notifications
      );
    } catch (e) {
      throw(e);
      // Handle error (logging, notifying the user, etc.)
    }
  }

  void _openFirstMenu() {
    final popupMenuButton = _firstMenuKey.currentState as PopupMenuButtonState?;
    popupMenuButton?.showButtonMenu();
  }

  void _openSecondMenu() {
    final popupMenuButton = _secondMenuKey.currentState as PopupMenuButtonState?;
    popupMenuButton?.showButtonMenu();
  }

  Future<bool> _onWillPop() async {
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 1,)), // Replace with your target screen
    );
    return false; // Prevents the default back action
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
         appBar: AppBar(
           leading: IconButton(onPressed: () {
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 1,),));
           }, icon: Icon(Icons.arrow_back_outlined)),
           backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
           title: Center(child: Text("Reminder"),),
           actions: [
             IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
           ],
         ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 18.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.lock_clock,color: Colors.blue),
                                    Text("Start Time"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
      
                      StartTim(
                        controller: _controller,
                      ),
                    ],
                  ),
      
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                children: [
                                  Icon(Icons.lock_clock,color: Colors.blue),
                                  Text("End Time"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        EndTIme(
                          controller: _controller1,
                        ),
                      ],
                    ),
                  ),
      
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18.0),
                          child: Container(
                            width: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.local_drink_outlined,color: Colors.blue,),
                                  Text(" Volume"),
                                ],
                              ),
                            )
                          ),
                        ),
      
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 110, // Fixed height for the picker
                              width: 110,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: 40, // Height of each item
                                useMagnifier: true,//highlight the selected one
                                magnification: 1.1,//magnifies the selected item
                                perspective: 0.01,// bend of the non-selected item range 0.01 to less more less mean more bend
                                physics: FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  selectedValue = 1000 + index ;
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 10000,
                                  builder: (context, index) {
                                    final value = 1000 + index;
                                    return Center(
                                      child: Text(
                                        '$value  ml',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Line above the selected value
                            Positioned(
                              top: 33,
                              left: 15,
                              right: 15,
                              child: Divider(
                                thickness: 2,
                                color: Colors.grey,
                              ),
                            ),
                            // Line below the selected value
                            Positioned(
                              bottom: 33,
                              left: 15,
                              right: 15,
                              child: Divider(
                                thickness: 2,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      
            SizedBox(height: 50,),
      
            Padding(
              padding: const EdgeInsets.only(left: 10.0,right: 10.0),
              child: Center(
                child: GestureDetector(
                  onTap:_openFirstMenu,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0,bottom: 10,top: 10),
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/svg/reminder.svg"),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min, // Minimizes vertical space usage
                              children: [
                                // "Remind After" label with larger font size
                                Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: Text(
                                    "Remind After",
                                    style: TextStyle(
                                      fontSize: 14, // Larger font size
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 18,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: PopupMenuButton<String>(
                                    key: _firstMenuKey,
                                    onSelected: (String value) {
                                      setState(() {
                                        remindAfter = value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return remindOptions.map((String value) {
                                        return PopupMenuItem<String>(
                                          value: value,
                                          child: SizedBox(
                                            width: 300,
                                            child: Text(
                                              value,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 14.0),
                                      child: Text(
                                        remindAfter,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Icon(Icons.arrow_drop_down),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      
            SizedBox(height: 50,),
      
            Padding(
              padding: const EdgeInsets.only(left: 10.0,right: 10.0),
              child: Center(
                child: GestureDetector(
                  onTap: _openSecondMenu,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0,bottom: 10,top: 10),
                      child: Row(
                        children: [
                          SvgPicture.asset('assets/svg/reminder.svg'),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min, // Minimizes vertical space usage
                              children: [
                                // "Remind After" label with larger font size
                                Padding(
                                  padding: const EdgeInsets.only(left: 14.0),
                                  child: Text(
                                    "Repeat Every",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 18,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: PopupMenuButton<String>(
                                    key: _secondMenuKey,
                                    onSelected: (String value) {
                                      setState(() {
                                         _openSecondMenu;
                                        // Toggle the selection of the value in repeatAfter
                                        if (repeatAfter.contains(value)) {
                                          repeatAfter.remove(value); // Deselect (uncheck the checkbox)
                                        } else {
                                          repeatAfter.add(value); // Select (check the checkbox)
                                        }
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return repeatOptions.map((String value) {
                                        return PopupMenuItem<String>(
                                          value: value,
                                          child: SizedBox(
                                            width: 300,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    value,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                // Checkbox to reflect the selection state
                                                Checkbox(
                                                  value: repeatAfter.contains(value), // Check if the value is selected
                                                  onChanged: null, // We are handling the state with onSelected
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 14.0),
                                      child: Text(
                                        repeatAfter.isNotEmpty ? repeatAfter.join(", ") : "you can select multiple repeat options",
                                        style: TextStyle(
                                          fontSize: 12, // Smaller font size for selected value
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Icon(Icons.arrow_drop_down),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      
            SizedBox(height: 180),
      
            SizedBox(
              width: 340,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                  onPressed: () async{
                    if(startTime != 0 && endTime !=0){
                      if(!isEndTimeAm){
                        endTime += 12;
                      }
                      if(!isStartTimeAm){
                        startTime += 12;
                      }
                      if(endTime > startTime){
                        await NotificationService().init();
                        int setId = (await noticeData.getLastSetId() + 1);
                        int difference = endTime - startTime;
                        int interval = parseInterval(remindAfter);
                        if(interval == 30){
                          difference = difference * 2;
                        }else{
                          difference = difference ~/ interval;
                        }
                        try{
                          for(int i = 0; i < repeatAfter.length; i++) {
                            int day = weekdayNameToNumber(repeatAfter[i]);
                            for (int j = 1; j <= difference; j++) {
                              DateTime initialDateTime = DateTime(
                                  0, 1, 1, startTime, 0);
                              DateTime updatedDateTime = initialDateTime.add(
                                  Duration(minutes: (interval == 30?interval:interval * 60) * j));
                              TimeOfDay updatedTimeOfDay = TimeOfDay(
                                  hour: updatedDateTime.hour,
                                  minute: updatedDateTime.minute);
                              int noticeID = (await noticeData.getLastNoticeId() + 1);
                              await _scheduleWeeklyNotification(weekday: day,
                                  time: updatedTimeOfDay,
                                  noticeID: noticeID,
                                  ml:selectedValue
                              );
                              await noticeData.insertNotice(
                                volume: selectedValue,
                                setId: setId,
                                noticeId: noticeID,
                                startTime: startTime,
                                endTime: endTime,
                                intervalDuration: interval == 30?interval: interval *60,
                                repeat: repeatAfter.join(", "),
                              );
                            }
                            showReminderAlertDialog(context,'reminder set successfully\n start time:$startTime endtime:$endTime\n repeat:${repeatAfter!=null?repeatAfter:'today'}');
                          }
                        }catch(e){
                          showAlertDialog(context,"Something went wrong:$e");
                        }
                        if(repeatAfter.isEmpty){
                          final int currentHour = DateTime.now().hour;
                          if(startTime > currentHour){
                            try{
                              for (int j = 1; j <= difference; j++) {
                                DateTime initialDateTime = DateTime(
                                    0, 1, 1, startTime, 0);
                                DateTime updatedDateTime = initialDateTime.add(Duration(minutes: (interval == 30?interval:interval * 60) * j));
                                TimeOfDay updatedTimeOfDay = TimeOfDay(hour: updatedDateTime.hour, minute: updatedDateTime.minute);
                                int noticeID = (await noticeData.getLastNoticeId() + 1);
                                await _scheduleNotification(updatedTimeOfDay, noticeID,selectedValue);
                                await noticeData.insertNotice(
                                  volume: selectedValue,
                                  setId: setId,
                                  noticeId: noticeID,
                                  startTime: startTime,
                                  endTime: endTime,
                                  intervalDuration: interval == 30?interval: interval *60,
                                  repeat: 'None',
                                );
                              }
                              showReminderAlertDialog(context,'reminder set successfully');
                            }catch(e){
                              showAlertDialog(context,"Something went wrong:$e");
                            }
                            endTime = 0;
                            startTime = 0;
                          }else{
                            showAlertDialog(context,"Start Time has already passed and you have also not selected any day for repeat");
                          }
                        }
                        endTime = 0;
                        startTime = 1;
                      }else{
                        showAlertDialog(context,"EndTime is before or equal to the start Time");
                        //show alertDialog EndTime is before the start Time
                      }
                    }else{
                      showAlertDialog(context,"please Select start and end time");
                      //Show AlertDialog please Select start and end time
                    }
                    endTime = 0;
                    startTime = 1;
                    resetScrollPosition();
                  },
                  child: Text("save",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold),)
              ),
            ),
      
          ],
        ),
      ),
    );
  }
}

class StartTim extends StatefulWidget {
  final FixedExtentScrollController controller;
  const StartTim({super.key, required this.controller});

  @override
  State<StartTim> createState() => _StartTimState();
}

class _StartTimState extends State<StartTim> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Enclose both wheels inside a box
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white, // Wheel background color
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hours Wheel with lines for selected input
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lines around the selected hour
                Positioned(
                  top: 40,
                  bottom: 40,
                  child: Container(
                    width: 50, // Width of the lines container
                    height: 10, // Adjust the height to fit the item
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.grey),
                        bottom: BorderSide(width: 1.0, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Hours Wheel Scroll
                ListWheelScrollView.useDelegate(
                  controller: widget.controller,
                  itemExtent: 40,
                  useMagnifier: true,//highlight the selected one
                  magnification: 1.1,
                  perspective: 0.01,
                  physics: FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    startTime = 1 + index;
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 12,
                    builder: (context, index) {
                      final value = 1 + index;
                      return Center(
                        child: Text(
                          '$value:00',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // AM/PM Wheel with lines for selected input
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lines around the selected AM/PM
                Positioned(
                  top: 40,
                  bottom: 40,
                  child: Container(
                    width: 40, // Width of the lines container
                    height: 50, // Adjust the height to fit the item
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.grey),
                        bottom: BorderSide(width: 1.0, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // AM/PM Wheel Scroll
                ListWheelScrollView(
                  itemExtent: 40,
                  useMagnifier: true,//highlight the selected one
                  magnification: 1.1,
                  perspective: 0.01,
                  physics: FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    if(index==0){
                      isStartTimeAm = true;
                    }else{
                      isStartTimeAm = false;
                    }
                  },
                  children: [
                    Center(
                      child: Text(
                        "AM",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "PM",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EndTIme extends StatefulWidget {
  final FixedExtentScrollController controller;
  const EndTIme({super.key, required this.controller});

  @override
  State<EndTIme> createState() => _EndTImeState();
}

class _EndTImeState extends State<EndTIme> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Enclose both wheels inside a box
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white, // Wheel background color
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hours Wheel with lines for selected input
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lines around the selected hour
                Positioned(
                  top: 40,
                  bottom: 40,
                  child: Container(
                    width: 50, // Width of the lines container
                    height: 10, // Adjust the height to fit the item
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.grey),
                        bottom: BorderSide(width: 1.0, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Hours Wheel Scroll
                ListWheelScrollView.useDelegate(
                  controller: widget.controller,
                  itemExtent: 40,
                  useMagnifier: true,//highlight the selected one
                  magnification: 1.1,
                  perspective: 0.01, // Control 3D effect
                  physics: FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    endTime = 1 + index ;
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: 12,
                    builder: (context, index) {
                      final value = 1 + index;
                      return Center(
                        child: Text(
                          '$value:00',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // AM/PM Wheel with lines for selected input
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lines around the selected AM/PM
                Positioned(
                  top: 40,
                  bottom: 40,
                  child: Container(
                    width: 40, // Width of the lines container
                    height: 50, // Adjust the height to fit the item
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(width: 1.0, color: Colors.grey),
                        bottom: BorderSide(width: 1.0, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // AM/PM Wheel Scroll
                ListWheelScrollView(
                  itemExtent: 40,
                  useMagnifier: true,//highlight the selected one
                  magnification: 1.1,
                  perspective: 0.01,
                  physics: FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    if(index==0){
                      isEndTimeAm = true;
                    }else{
                      isEndTimeAm = false;
                    }
                  },
                  children: [
                    Center(
                      child: Text(
                        "AM",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "PM",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
