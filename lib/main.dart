import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rural_learning_app/features/game/wack-a-mole-screen.dart';
import 'features/game/spelling_game.dart';
import 'features/game/abcgame.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rural_learning_app/data/player_profile.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('playerBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PlayerProfile profile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() {
    final box = Hive.box('playerBox');
    final saved = box.get('profile');
    if (saved != null) {
      profile = PlayerProfile.fromJson(Map<String, dynamic>.from(saved));
    } else {
      profile = PlayerProfile();
      box.put('profile', profile.toJson());
    }
    setState(() {}); // refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
              title: const Text('Wack a Mole'),
              onTap: () {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  WhackAMoleScreen(),
      ),
    ).then((_) {
      // ✅ refresh when returning from game
      setState(() {
        loadProfile();
      });
    });
  },
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('STEM Quiz'),
              onTap: () {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>  ABCGame(),
      ),
    ).then((_) {
      // ✅ refresh when returning from game
      setState(() {
        loadProfile();
      });
    });
  },
            ),
            ListTile(
  leading: const Icon(Icons.videogame_asset),
  title: const Text('Spelling Game'),
  onTap: () {
    Navigator.pop(context); // close drawer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SpellingGameScreen(),
      ),
    ).then((_) {
      // ✅ refresh when returning from game
      setState(() {
        loadProfile();
      });
    });
  },
),

          ],
        ),
      ),
      body: Center(
        child: profile == null
            ? const CircularProgressIndicator()
            : Column(
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
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text("Level: ${profile.level}",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: profile.xp / profile.xpForNextLevel,
                            backgroundColor: Colors.grey[300],
                            color: Colors.greenAccent,
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Text("${profile.xp} / ${profile.xpForNextLevel} XP"),
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
