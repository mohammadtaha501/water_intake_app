import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../databaseStorage.dart';
import '../sevicesAndCustom.dart';
import 'ChoseQuantity.dart';
import 'changeTarget.dart';
import 'settingScreen.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double progressValue=0;
  TimeOfDay _currentTime = TimeOfDay.now();
  int? cumulative;
  List<Map<String, dynamic>> waterIntake = [];
  Timer? _timer;
  int target = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _startTimer();

    // Fetch data asynchronously
    await getTarget();
    await getWaterData();
    await getTodayTotal();

    // Now update the UI with the results
    setState(() {});
  }

  Future<void> getTarget() async {
    var box = await Hive.openBox('myBox');
    target = box.get('target',defaultValue: 0);
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> getWaterData()async{
    final data = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(data);
    waterIntake = await waterDataService.getWaterIntakeByDate(date);
    setState(() {});
  }

  Future<void> getTodayTotal()async{
    DateTime today = DateTime.now();
    String todayDate = DateFormat('yyyy-MM-dd').format(today);
    cumulative = await waterDataService.getLastCumulativeTotal(todayDate);
    if(cumulative != null){
      double result = (cumulative! / target);
      progressValue = double.parse(result.toStringAsFixed(2));
    }
    setState(() {});
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) {
      setState(() {
        _currentTime = TimeOfDay.now();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text('Water Intake Tracker'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen(),));
              },
              icon: const Icon(Icons.settings)
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            SizedBox(
              height: 170,
              child: Row(
                children: [
                  circularPercentIndicator(
                    radius: 150.0,
                    lineWidth: 15.0,
                    percent: progressValue,
                    center: Text('${double.parse((progressValue*100).toStringAsFixed(2))} %', style: TextStyle(fontSize: 24)),
                    progressColor: Colors.blueAccent,
                    backgroundColor: Colors.white,
                  ),
                  Spacer(),
                  Column(
                    children: [
                      Container(
                        height: 76,
                        width: 190,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment:CrossAxisAlignment.start,
                            children: [
                              RepaintBoundary(
                                child: Text(
                                  _currentTime.format(context),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 8.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      child: Row(
                                        children: [
                                          Icon(Icons.local_drink, color: Colors.blueAccent),
                                          Text(cumulative!=null?"$cumulative":"Start Drinking",
                                              style: TextStyle(fontSize: 12)),
                                        ],
                                      )
                                  ),
                                  Text('${double.parse((progressValue*100).toStringAsFixed(2))}%',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12),
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Spacer(),

                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => Change_Target(),));
                          await getTarget();
                          setState(() {});
                        },
                        child: Container(
                          height: 76,
                          width: 190,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0,top: 8.0,right: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset('assets/svg/dartboard.svg',),
                                    SizedBox(width: 8,),
                                    Text(
                                      " Target",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("$target ml", style: TextStyle(fontSize: 14)),
                                    SvgPicture.asset(
                                      'assets/svg/Edit.svg',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            Text(
              "Today",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Container(
               width:MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 18.0,left:20.0,bottom: 8.0,right: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: 270),
                            child: IntrinsicHeight(
                              child: SizedBox(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: List.generate(
                                        waterIntake.length, (index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column( //add the time and volume here
                                          children: [
                                            Text("${waterIntake[index]['time']}"
                                                ,style:TextStyle(
                                              fontSize: 16,
                                              )
                                            ),
                                            Text("${waterIntake[index]['amount_ml']}ml",style: TextStyle(color: Colors.grey),),
                                          ],
                                        )
                                      );
                                    }
                                   ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: SvgPicture.asset(
                            "assets/svg/Frame.svg",
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: ()async {
                        await Navigator.push(context, MaterialPageRoute(builder: (context) => QuantityScreen(),));
                        await _initializeData();
                      },
                      child: Text(
                        "Choose Volume",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: () async {
                        int amountMl = 100;
                        final data = DateTime.now();
                        final date = DateFormat('yyyy-MM-dd').format(data);
                        final time = DateFormat('hh:mm:ss a').format(data);
                        waterDataService.addWaterIntake(date, time, amountMl);
                        showLottieAlertDialog(context,'water added successfully');
                        await getWaterData();
                        await getTodayTotal();
                        setState(() {});
                      },
                      child: Row(
                        children: [
                          Text(
                            "100ml ",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white
                            ),
                          ),
                          SvgPicture.asset('assets/svg/icon.svg',),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
