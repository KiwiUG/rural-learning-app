import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;

class SpellingGameScreen extends StatefulWidget {
  const SpellingGameScreen({super.key});

  @override
  State<SpellingGameScreen> createState() => _SpellingGameScreenState();
}

class _SpellingGameScreenState extends State<SpellingGameScreen> {
  List<dynamic> words = [];
  int currentIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  String feedback = "";

  @override
  void initState() {
    super.initState();
    loadWords();
  }

  Future<void> loadWords() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/words.json');
      final data = jsonDecode(jsonString);
      setState(() {
        words = data;
      });
    } catch (e) {
      debugPrint("Error loading words.json: $e");
    }
  }

  void playAudio() {
    if (words.isEmpty) return;
    final audioFile = words[currentIndex]['audio'];
    _player.play(AssetSource("audio/$audioFile"));
  }

  int displaylevel() {
    if (words.isEmpty) return;
    final level = words[currentIndex]['level'];
    return level
  }


  void checkAnswer() {
    if (words.isEmpty) return;
    String userAnswer = _controller.text.trim().toLowerCase();
    String correctAnswer = words[currentIndex]['word'].toLowerCase();

    setState(() {
      if (userAnswer == correctAnswer) {
        feedback = "✅ Correct!";
        // Move to next word (or loop back to start)
        currentIndex = (currentIndex + 1) % words.length;
      } else {
        feedback = "❌ Try Again!";
      }
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Spelling Game"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: displaylevel(),
              ),)
            ElevatedButton.icon(
              onPressed: playAudio,
              icon: const Icon(Icons.volume_up),
              label: const Text("Play Sound"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Type the spelling here",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(200, 50),
              ),
              child: const Text(
                "Submit",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              feedback,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: feedback.contains("✅") ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
