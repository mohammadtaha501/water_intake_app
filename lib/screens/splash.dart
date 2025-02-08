import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';

import '../databaseStorage.dart';
import '../notificationDatabase.dart';
import 'ChoseQuantity.dart';
import 'entryScreen.dart';
import 'mainscreen.dart';

class SplashScreen extends StatefulWidget {
  final bool noticeOpen;
  SplashScreen({super.key, required this.noticeOpen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool firstTime= false;

  Future<void> _checkFirstTime() async {
    var box = await Hive.openBox('appBox');
    bool isFirstTime = box.get('firstTime', defaultValue: true);
    if (isFirstTime) {
      firstTime=true;
      // Set 'firstTime' to false after the first launch
      await box.put('firstTime', false);
      await waterDataService.open();
      await noticeData.open();
      setState(() {});
    } else {
      print('in not first TIme');
      await waterDataService.open();
      await noticeData.open();
      await Future.delayed(Duration(seconds: 2));
      // Navigate to the intro screen after splash
      if(widget.noticeOpen){
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => QuantityScreen()),
        );
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0,)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child:SvgPicture.asset('assets/svg/splashback.svg'),
          ),
          Positioned(
              child: Center(child:
                Padding(
                  padding: EdgeInsets.only(top: 90.0),
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: Duration(seconds: 1),
                    child: Text(
                      '           Hi Welcome to\nWater Intake : Water Tracker',
                      style: TextStyle(color: Colors.white,fontSize: 20),
                    ),
                  ),
                )
            )
          ),
          Positioned(
            left: 65,
            top: 440,
              child: AnimatedOpacity(
                opacity: 1,
                duration: Duration(seconds: 2),
                child: Center(child:
                  Padding(
                    padding: EdgeInsets.only(top: 90.0),
                    child: Text(
                      'Stay Hydrated , Stay Healthy  -  We`ll \nRemind You',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15,),
                    ),
                  )
                            ),
              )
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Visibility(
              visible: firstTime,
              child: ElevatedButton(
                onPressed: () {
                  if(widget.noticeOpen){
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => QuantityScreen()));
                  }
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => EntryScreen()));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
