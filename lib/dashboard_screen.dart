import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rural_learning_app/data/player_profile.dart';
import 'features/game/abcgame.dart';
import 'features/game/spelling_game.dart';
import 'features/game/wack-a-mole-screen.dart';
import 'robo/screens/splash_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ✅ FIX: Initialize profile as nullable to avoid errors before it's loaded.
  PlayerProfile? profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final box = Hive.box('playerBox');
    final saved = box.get('profile');
    if (saved != null) {
      profile = PlayerProfile.fromJson(Map<String, dynamic>.from(saved));
    } else {
      profile = PlayerProfile();
      box.put('profile', profile!.toJson());
    }
    setState(() {}); // Refresh the UI with the loaded profile
  }

  // Helper method to navigate to a game and refresh the profile on return
  void _navigateToGame(Widget gameScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameScreen),
    ).then((_) {
      // When we return from a game, reload the profile to show new XP/streaks
      setState(() {
        _loadProfile();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Show a loading indicator while the profile is null.
    if (profile == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Learning Dashboard"),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.android),
              title: const Text('Robo Game'),
              onTap: () {
                Navigator.pop(context); // close drawer
                _navigateToGame(SplashScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.catching_pokemon),
              title: const Text('Wack a Mole'),
              onTap: () {
                Navigator.pop(context);
                _navigateToGame(const WhackAMoleScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('ABC Game'),
              onTap: () {
                Navigator.pop(context);
                _navigateToGame( ABCGame());
              },
            ),
            ListTile(
              leading: const Icon(Icons.spellcheck),
              title: const Text('Spelling Game'),
              onTap: () {
                Navigator.pop(context);
                _navigateToGame(const SpellingGameScreen());
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome 👋", style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Card(
              elevation: 8,
              color: Colors.black.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text("Level: ${profile!.level}", style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Chip(
                      avatar: const Icon(Icons.local_fire_department_rounded, color: Colors.orange),
                      label: Text(
                        '${profile!.currentStreak} Day Streak',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: profile!.xp / profile!.xpForNextLevel,
                      backgroundColor: Colors.grey[700],
                      color: Colors.greenAccent,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${profile!.xp} / ${profile!.xpForNextLevel} XP",
                      style: const TextStyle(color: Colors.white70),
                    ),
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