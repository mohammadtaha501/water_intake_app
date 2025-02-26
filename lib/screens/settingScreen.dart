import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'changeTarget.dart';
import 'gendersScreen.dart';
import 'goalScreen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!, // Background color as shown
      appBar: AppBar(
        backgroundColor: Color.lerp(Colors.lightBlueAccent, Colors.white, 0.3)!,
        elevation: 0,
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(title: "General"),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Change_Target(),));
              },
              child: SettingCard(
                icon: Icons.local_drink,
                title: "Intake Goal",
              ),
            ),
            SectionTitle(title: "Personal Info"),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => gender_seeting(),));
              },
              child: SettingCard(
                icon: Icons.person,
                title: "Gender",
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => WaterGoalScreen(),));
              },
              child: SettingCard(
                icon: Icons.monitor_weight,
                title: "Weight",
              ),
            ),
            SectionTitle(title: "App"),
            GestureDetector(
              onTap: () async{
                const url = 'https://play.google.com/store/apps/details?id=com.waterintake.waterreminder.trackwater.daily ';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                throw 'Could not launch $url';
                }
              },
              child: SettingCard(
                icon: Icons.feedback,
                title: "Give Feedback",
              ),
            ),
            GestureDetector(
              onTap: () async {
                const url = 'https://sites.google.com/view/waterintaketrackprivacypolicy/home';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  // print('Could not launch: $url');
                  throw 'Could not launch $url';
                }
              },
              child: SettingCard(
                icon: Icons.policy,
                title: "Privacy Policy",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class SettingCard extends StatelessWidget {
  final IconData icon;
  final String title;

  SettingCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }
}
