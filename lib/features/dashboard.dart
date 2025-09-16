import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rural_learning_app/data/player_profile.dart';
import 'package:rural_learning_app/features/game/wack-a-mole-screen.dart';
import 'package:rural_learning_app/features/game/spelling_game.dart';
import 'package:rural_learning_app/features/game/abcgame.dart';
import 'package:rural_learning_app/robo/screens/splash_screen.dart';

import '../../main.dart'; // ✅ to access global `profile`

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
  // ensure box is open
  final box = await Hive.openBox('playerBox');
  final saved = box.get('profile');

  if (saved is PlayerProfile) {
    profile = saved;
  } else if (saved is Map) {
    profile = PlayerProfile.fromJson(Map<String, dynamic>.from(saved));
    await box.put('profile', profile); // migrate to object storage
  } else {
    profile = PlayerProfile();
    await box.put('profile', profile);
  }

  setState(() {}); // refresh UI
}


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

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
            _drawerItem(
              icon: Icons.book,
              title: "Robo Game",
              onTap: () => _navigate(context, SplashScreen()),
            ),
            _drawerItem(
              icon: Icons.sports_esports,
              title: "Wack a Mole",
              onTap: () => _navigate(context, WhackAMoleScreen()),
            ),
            _drawerItem(
              icon: Icons.quiz,
              title: "STEM Quiz",
              onTap: () => _navigate(context, ABCGame()),
            ),
            _drawerItem(
              icon: Icons.spellcheck,
              title: "Spelling Game",
              onTap: () => _navigate(context, const SpellingGameScreen()),
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

                    const Divider(height: 24, thickness: 1),

                    // ✅ Streak display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.orange, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          "Streak: ${profile.currentStreak} days 🔥",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (profile.longestStreak > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Best: ${profile.longestStreak} days",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => loadProfile()); // refresh when returning
  }
}
