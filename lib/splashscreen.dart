import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:medycall/auth/signin.dart';
import 'package:medycall/auth/signupNumber.dart';
//import 'package:medycall/auth/otpnumber.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 3),
        () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext) => Signupnumber())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/logo.png', // Main MedyCall logo
                  width: 200,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 38),
                  child: Image.asset(
                    'assets/beat.png', // Animated heartbeat logo inside logo.png
                    width: 100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Image.asset(
              'assets/medicall.png',
              width: 180,
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Go-to HealthGenie!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    blurRadius: 20,
                    color: Colors.black54,
                    offset: Offset(6, 6), // Creates a soft shadow effect
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60), // Ensuring 60px bottom margin
          ],
        ),
      ),
    );
  }
}
