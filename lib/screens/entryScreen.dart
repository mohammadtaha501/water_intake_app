import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'gendersScreen.dart';
import 'mainscreen.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child:SvgPicture.asset(
            "assets/svg/introscreen.svg",
           ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => EntryScreen1()));
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

class EntryScreen1 extends StatefulWidget {
  const EntryScreen1({super.key});

  @override
  State<EntryScreen1> createState() => _EntryScreen1State();
}

class _EntryScreen1State extends State<EntryScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child:SvgPicture.asset(
            "assets/svg/introscreen1.svg",
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => GendersScreen()),
                );
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
