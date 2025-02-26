import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../sevicesAndCustom.dart';
import 'mainscreen.dart';


class Change_Target extends StatefulWidget {
  const Change_Target({super.key});

  @override
  State<Change_Target> createState() => _Change_TargetState();
}

class _Change_TargetState extends State<Change_Target> {
  final TextEditingController _controller = TextEditingController();
  bool isDefaultCup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Change Target"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                    labelText: "Enter Target Here",
                    border: InputBorder.none, // No border for the text field itself
                    enabledBorder: InputBorder.none, // No border when enabled
                    focusedBorder: InputBorder.none, // No border when focused
                  ),
                ),
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
                          var box = Hive.box('myBox');
                          box.put('target', amountMl);
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen(selectedIndex: 0,),));
                        }catch (e) {
                          // print('$e');
                          showLottieAlertDialog(context, 'Some thing went wrong');
                        }
                      },
                      child: Text("Save",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 250,),
            ],
          ),
        ),
      ),
    );
  }
}
