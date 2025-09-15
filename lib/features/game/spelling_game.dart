import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;

class SpellingGameScreen extends StatefulWidget {
  const SpellingGameScreen({super.key});

  @override
  State<SpellingGameScreen> createState() => _SpellingGameScreenState();
}

class _SpellingGameScreenState extends State<SpellingGameScreen> {
  Map<String, dynamic> allLevels = {}; // entire JSON data
  List<dynamic> words = []; // selected level words
  String selectedLevel = "";
  int currentIndex = 0;
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _player = AudioPlayer();
  String feedback = "";
  String hint = "";
  Color? overlayColor; // null means no overlay



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
        allLevels = data;
      });
    } catch (e) {
      debugPrint("Error loading words.json: $e");
    }
  }

  void chooseLevel(String level) {
    setState(() {
      selectedLevel = level;
      words = allLevels[level] ?? [];
      pickRandomWord();
      feedback = "";
    });
  }

  void pickRandomWord() {
    if (words.isEmpty) return;
    final random = Random();
    setState(() {
      currentIndex = random.nextInt(words.length);
    });
  }

  void playAudio() {
    if (words.isEmpty) return;
    final audioFile = words[currentIndex]['audio'];
    _player.play(AssetSource("audio/$selectedLevel/$audioFile"));
  }

 void checkAnswer() {
  if (words.isEmpty) return;
  String userAnswer = _controller.text.trim().toLowerCase();
  String correctAnswer = words[currentIndex]['word'].toLowerCase();

  if (userAnswer == correctAnswer) {
    setState(() {
      feedback = "✅ Correct!";
      hint = "";
      overlayColor = Colors.green.withOpacity(0.6); // ✅ Green overlay
    });

    // Hide overlay after short delay and go to next word
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          overlayColor = null;
          pickRandomWord();
        });
      }
    });

  } else {
    setState(() {
      feedback = "❌ Try Again!";
      overlayColor = Colors.red.withOpacity(0.6); // ❌ Red overlay
    });

    // Hide overlay after short delay
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => overlayColor = null);
      }
    });
  }

  _controller.clear();

  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      setState(() => feedback = "");
    }
  });
}

void showHint() {
  if (words.isEmpty) return;
  final word = words[currentIndex]['word'];
  final random = Random();

  // Mask most characters, randomly leave some visible
  final chars = word.split('');
  final revealedIndexes = <int>{};

  // Reveal 1–2 random letters (at least 1 for very short words)
  int lettersToReveal = (word.length / 3).ceil().clamp(1, word.length - 1);
  while (revealedIndexes.length < lettersToReveal) {
    revealedIndexes.add(random.nextInt(word.length));
  }

  setState(() {
    hint = chars
        .asMap()
        .entries
        .map((entry) => revealedIndexes.contains(entry.key) ? entry.value : "_")
        .join();
  });
}

void giveUp() {
  if (words.isEmpty) return;
  setState(() {
    feedback = "Answer: ${words[currentIndex]['word']}";
    _controller.clear();
    hint = "";
  });

  // Automatically move to next word after 3 sec
  Future.delayed(const Duration(seconds: 3), () {
    if (mounted) {
      setState(() {
        feedback = "";
        pickRandomWord();
      });
    }
  });
}


  @override
  Widget build(BuildContext context) {
    if (allLevels.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

 return Stack(
  children: [
    Scaffold(
      appBar: AppBar(
        title: const Text("Spelling Game"),
        centerTitle: true,
      ),
      body: selectedLevel.isEmpty
          // ✅ Level Selector Screen
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Choose a Level",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => chooseLevel("easy"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text("Easy"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => chooseLevel("medium"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text("Medium"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => chooseLevel("hard"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Hard"),
                  ),
                ],
              ),
            )
          // ✅ Game Screen
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Level: ${selectedLevel.toUpperCase()}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

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

                  if (hint.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Hint: $hint",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: showHint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          minimumSize: const Size(120, 45),
                        ),
                        child: const Text("Hint"),
                      ),
                      ElevatedButton(
                        onPressed: giveUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(120, 45),
                        ),
                        child: const Text("Give Up"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  AnimatedOpacity(
                    opacity: feedback.isNotEmpty ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      feedback,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: feedback.contains("✅")
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: pickRandomWord,
                    child: const Text("Skip / Next Word"),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() {
                      selectedLevel = "";
                      words = [];
                      hint = "";
                      feedback = "";
                    }),
                    child: const Text("Change Level"),
                  ),
                ],
              ),
            ),
    ),

    // ✅ Overlay Effect Layer
    if (overlayColor != null)
  AnimatedOpacity(
    opacity: 1,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeInOut,
    child: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            overlayColor!.withOpacity(0.8),
            overlayColor!.withOpacity(0.3),
            Colors.transparent,
          ],
          center: Alignment.center,
          radius: 1.2,
        ),
      ),
    ),
  ),
  ],
);
  }}