import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:water_intake_app/databaseStorage.dart';
import '../sevicesAndCustom.dart';
import 'CustomCup.dart';

class QuantityScreen extends StatefulWidget {
  const QuantityScreen({super.key});

  @override
  _QuantityScreenState createState() => _QuantityScreenState();
}

class _QuantityScreenState extends State<QuantityScreen> {
  String selectedQuantity = "";

  final List<String> quantities = [
    "100ml",
    "200ml",
    "300ml",
    "400ml",
    "500ml",
    "Custom Cup"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Choose Quantity",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  childAspectRatio: 1.3, // Width to height ratio
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                shrinkWrap: true,
                itemCount: quantities.length,
                itemBuilder: (context, index) {
                  if(quantities[index] == "Custom Cup"){
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => CustomCupScreen(), // Replace with your destination screen
                        ) );
                      },
                      child: SizedBox(
                        width: 100,
                        height: 150,
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selectedQuantity == quantities[index]
                                    ? Colors.blueAccent
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: SvgPicture.asset('assets/svg/Pluse.svg'),
                            ),
                            Center(
                              child: Text(
                                quantities[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedQuantity = quantities[index];
                      });
                    },
                    child: SizedBox(
                      width: 100,
                      height: 150,
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selectedQuantity == quantities[index]
                                  ? Colors.blueAccent
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SvgPicture.asset('assets/svg/cup.svg'),
                          ),
                          Center(
                            child: Text(
                              quantities[index],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: SizedBox(
                height: 60,
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () {
                    String numericString = selectedQuantity.replaceAll(RegExp(r'[^0-9]'), '');
                    int amountMl = int.parse(numericString);
                    final data = DateTime.now();
                    final date = DateFormat('yyyy-MM-dd').format(data);
                    final time = DateFormat('hh:mm:ss a').format(data);
                    waterDataService.addWaterIntake(date, time, amountMl);
                    showLottieAlertDialog(context,'water added successfully');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Add  ",
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
            ),
            SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}