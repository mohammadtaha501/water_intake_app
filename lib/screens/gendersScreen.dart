import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'goalScreen.dart';

class GendersScreen extends StatefulWidget {
  const GendersScreen({super.key});

  @override
  State<GendersScreen> createState() => _GendersScreenState();
}

class _GendersScreenState extends State<GendersScreen> {
  bool? isSelected;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: SvgPicture.asset("assets/svg/background.svg")),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Your Gender",
                  style: TextStyle(fontSize: 16),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      isSelected=true;
                      setState(() {});
                    },
                    child: Container(
                      height: 200,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color:isSelected != null && isSelected == true ? Colors.blue:Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            'assets/Images/Man.jpg',
                            height: 120,
                            width: 120,
                            fit: BoxFit.fitHeight,
                          ),
                          Text("Male"),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      isSelected = false;
                      setState(() {});
                    },
                    child: Container(
                      height: 200,
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color:isSelected != null && isSelected == false ? Colors.blue:Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            'assets/Images/female.jpg',
                            width: 140,
                            height: 140,
                            fit: BoxFit.fitHeight,
                          ),
                          Text("Female"),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),

          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => WaterGoalScreen()));
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
        ],
      ),
    );
  }
}
