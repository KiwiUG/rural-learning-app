import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/game/spelling_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rural Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning Dashboard"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Lessons'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Lessons Screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Quiz'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to Quiz Screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.videogame_asset),
              title: const Text('Play Game'),
              onTap: () {
                Navigator.pop(context); // closes drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SpellingGameScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome 👋",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("XP Points: 0",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    SizedBox(height: 10),
                    LinearProgressIndicator(value: 0.2),
                    SizedBox(height: 10),
                    Text("Keep learning to earn more XP!"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
