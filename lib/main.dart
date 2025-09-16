import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/player_profile.dart';
import 'features/dashboard.dart';

late PlayerProfile profile;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PlayerProfileAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _initProfile() async {
  final box = await Hive.openBox('playerBox');
  final saved = box.get('profile');

  if (saved is PlayerProfile) {
    // already stored as Hive object
    profile = saved;
  } else if (saved is Map) {
    // legacy JSON saved earlier, migrate to PlayerProfile object
    profile = PlayerProfile.fromJson(Map<String, dynamic>.from(saved));
    // overwrite the stored value with the proper Hive object
    await box.put('profile', profile);
  } else {
    // nothing saved yet -> create new profile and persist it
    profile = PlayerProfile();
    await box.put('profile', profile);
  }
}


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
      home: FutureBuilder(
        future: _initProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.green),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text("Error loading profile: ${snapshot.error}"),
              ),
            );
          }

          return const DashboardScreen();
        },
      ),
    );
  }
}
