import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rural_learning_app/dashboard_screen.dart'; // Import the new dashboard screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // It's good practice to register your Hive adapters if you use them
  // Hive.registerAdapter(PlayerProfileAdapter()); 
  await Hive.openBox('playerBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // The builder applies the background to all screens in your app
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: child,
        );
      },
      // The home screen is now the clean DashboardScreen widget
      home: const DashboardScreen(),
    );
  }
}