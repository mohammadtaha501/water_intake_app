import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

import 'mainscreen.dart';

class WaterGoalScreen extends StatefulWidget {
  const WaterGoalScreen({super.key});

  @override
  State<WaterGoalScreen> createState() => _WaterGoalScreenState();
}

class _WaterGoalScreenState extends State<WaterGoalScreen> {
  int selectedValue = 1000;
  int weight=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
      body: Stack(
          children: [
            Positioned.fill(child: SvgPicture.asset("assets/svg/background.svg")),

            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  var box = Hive.box('myBox');
                  box.put('target', selectedValue);
                  box.put('weight',weight);
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0,)));
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
                    'Continue',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 40,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  SvgPicture.asset("assets/svg/Icon1.svg"),
                                  Text(
                                    "Your wight",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),

                          Container(
                            // Enclose both wheels inside a box
                            width: 150,
                            height: 150,
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
                                        top: 50,
                                        bottom: 50,
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
                                        itemExtent: 40,
                                        useMagnifier: true,//highlight the selected one
                                        magnification: 1.1,
                                        perspective: 0.01,
                                        physics: FixedExtentScrollPhysics(),
                                        onSelectedItemChanged: (index) {
                                          weight = 1 + index;
                                        },
                                        childDelegate: ListWheelChildBuilderDelegate(
                                          childCount: 200,
                                          builder: (context, index) {
                                            final value = 1 + index;
                                            return Center(
                                              child: Text(
                                                '$value',
                                                style: TextStyle(
                                                    fontSize: 24,
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
                                        top: 50,
                                        bottom: 50,
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

                                        },
                                        children: [
                                          Center(
                                            child: Text(
                                              "KG",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Center(
                                            child: Text(
                                              "lbs",
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
                          ),

                        ],
                      ),
                    ),

                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 40,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  SvgPicture.asset("assets/svg/Icon1.svg"),
                                  Text(
                                    "Your Daily Goal",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                          ),

                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 150, // Fixed height for the picker
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ListWheelScrollView.useDelegate(
                                  itemExtent: 50, // Height of each item
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
                                              fontSize: 24,
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
                                top: 50,
                                left: 15,
                                right: 15,
                                child: Divider(
                                  thickness: 2,
                                  color: Colors.grey,
                                ),
                              ),
                              // Line below the selected value
                              Positioned(
                                bottom: 50,
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
            ),
          ]
      ),
    );
  }
}