// main.dart
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(RoboProgrammerApp());
}

class RoboProgrammerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robo-Programmer',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Courier'),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
