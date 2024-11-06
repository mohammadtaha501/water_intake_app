import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../notificationDatabase.dart';
import '../notificationService.dart';
import 'reminderSettingScreen.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  List<Map<String, dynamic>> data=[];
  List<List<String>> dayDisplay=[];

  Future<void> initializeData()async{
    data = await noticeData.getUniqueSetIds();
    for (var row in data){
      String days = row['repeat_days'];
      dayDisplay.add(days.split(", "));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
      appBar: AppBar(
        backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
        title: Text("Reminder"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align button at the bottom
          children: [
            Expanded(
              child: data.isEmpty // Check if data is empty
                  ? Center( // Center the message
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 150,
                        width: 150,
                        child: SvgPicture.asset('assets/svg/noData.svg')),
                    Text(
                      'No entries available', // Display this message
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final row = data[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${row['start_time']}:00 - ${row['end_time']}:00',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () async {
                                  await NotificationService().init();
                                  int setID = row['set_id'];
                                  List<int> noticeIDs =
                                  await noticeData.getNoticeIdsBySetId(setID);
                                  for (var noticeId in noticeIDs) {
                                    NotificationService().cancelNotification(noticeId);
                                  }
                                  noticeData.deleteNoticesBySetId(setID);
                                  await initializeData();
                                  setState(() {});
                                },
                                icon: Icon(Icons.delete_forever, color: Colors.blue),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                '${row['volume']}ml water',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              for (String day in dayDisplay[index])
                                Chip(
                                  label: Text(day),
                                  backgroundColor: Colors.blue[50],
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      style: BorderStyle.none,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Button at the bottom of the screen
            Padding(
              padding: const EdgeInsets.only(bottom: 100.0), // Add some space at the bottom
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  backgroundColor: Colors.blueAccent,
                ),
                onPressed: () async {
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ReminderSetting()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SvgPicture.asset('assets/svg/icon.svg'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
