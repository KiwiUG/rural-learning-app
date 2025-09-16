import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/components/homepage.dart';
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
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
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
      profile = PlayerProfile(); // default profile
      box.put('profile', profile.toJson());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Open HomePage directly with profile data
    return HomePage(
      xp: profile.xp,
      level: profile.level,
      xpForNextLevel: profile.xpForNextLevel,
    );
  }
}
