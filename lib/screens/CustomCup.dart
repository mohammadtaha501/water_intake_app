import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../databaseStorage.dart';
import '../sevicesAndCustom.dart';

class CustomCupScreen extends StatefulWidget {
  const CustomCupScreen({super.key});

  @override
  _CustomCupScreenState createState() => _CustomCupScreenState();
}

class _CustomCupScreenState extends State<CustomCupScreen> {
  final TextEditingController _controller = TextEditingController();
  bool isDefaultCup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Center(child: Text("Custom Cup")),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Quantity",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white, // White background
                borderRadius: BorderRadius.circular(20.0), // Rounded corners
              ),
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent, // Use the container's color, so set this to transparent
                  labelText: "Enter cup quantity",
                  border: InputBorder.none, // No border for the text field itself
                  enabledBorder: InputBorder.none, // No border when enabled
                  focusedBorder: InputBorder.none, // No border when focused
                ),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: isDefaultCup,
                  onChanged: (value) {
                    setState(() {
                      isDefaultCup = value ?? false;
                    });
                  },
                ),
                Text("Set as default cup"),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white60),
                        backgroundColor: Colors.white60
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: () {
                      try {
                        final quantity = _controller.text;
                        String numericString = quantity.replaceAll(RegExp(r'[^0-9]'), '');
                        int amountMl = int.parse(numericString);
                        final data = DateTime.now();
                        final date = DateFormat('yyyy-MM-dd').format(data);
                        final time = DateFormat('hh:mm:ss a').format(data);
                        waterDataService.addWaterIntake(date, time, amountMl);
                        showLottieAlertDialog(context, 'water added successfully');
                      }catch (e) {
                        showLottieAlertDialog(context, 'Some thing went wrong');
                      }
                    },
                    child: Text("Save"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 250,),
          ],
        ),
      ),
    );
  }
}
