import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../notificationDatabase.dart';
import '../sevicesAndCustom.dart';
import 'HistoryScreen.dart';
import 'ReminderScreen.dart';
import 'mainScreenEntry.dart';

class MainScreen extends StatefulWidget {
  final int selectedIndex;
  const MainScreen({super.key, required this.selectedIndex});
  @override
  State<MainScreen> createState() => _MainScreenState();
}
class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static final List<Widget> _screens = <Widget>[
    Home(),               // Screen for index 0
    ReminderScreen(),     // Screen for index 1
    HistoryScreen(),      // Screen for index 2
  ];

  Future<bool> _onWillPop() async {
    if(_selectedIndex == 0){
      final bool responce = await message(context);
      return responce;
    }else {
      setState(() {
        _selectedIndex = 0; // Set the selected index to 0
      });
      // Return false to prevent default back action
      return false;
    } // Prevents the default back action
  }

  Future<bool> message(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Exit'),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              child: const Icon(Icons.close),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/Images/exit.png',
              height: 60,
            ),
            const SizedBox(height: 20),
            Text('Are you sure you want to exit?'.tr),
          ],
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                  SystemNavigator.pop();
                },
                child: Text('Yes'),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
            ],
          ),
        ],
      ),
    ).then((value) => value ?? false);
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex=widget.selectedIndex;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: true,
        body: _screens[_selectedIndex],
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Rounded edges
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.access_time, color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
                  onPressed: () async {
                    bool temp = await noticeData.doesDataExist();
                    if(!temp){
                      showLottieReminder(context);
                    }
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.book, color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
