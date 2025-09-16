import 'dart:convert';
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'mole.dart';

class WhackAMoleGame extends FlameGame {
  // --- UI Components ---
  late TextBoxComponent questionText;
  late TextComponent scoreText;
  late TextComponent levelText;
  late TextComponent timerText;
  late TextComponent livesText;
  late TextComponent xpText;

  // --- Game State ---
  int score = 0;
  int lives = 3;
  int xp = 0;
  String currentLevel = "easy";
  late Timer gameTimer;
  bool isInputLocked = false;

  // --- Question Data ---
  Map<String, List<dynamic>> questionBank = {};
  late Map<String, dynamic> currentQuestion;
  final Random random = Random();

  // --- Game Objects ---
  List<Mole> activeMoles = [];
  List<Vector2> holePositions = [];

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(resolution: Vector2(400, 800));
    add(RectangleComponent(
        size: size,
        paint: Paint()
          ..color = const Color.fromARGB(255, 61, 96, 186))); // Background

    await loadQuestions();
    _createMoleHoles();
    _initUI();

    // --- Start Game Timer ---
    gameTimer = Timer(3.0, onTick: handleMiss, repeat: true)..stop();
    nextQuestion();
  }

  Future<void> loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/questions.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    questionBank = {
      "easy": jsonMap["easy"] as List<dynamic>,
      "medium": jsonMap["medium"] as List<dynamic>,
      "hard": jsonMap["hard"] as List<dynamic>,
    };
  }

  void _createMoleHoles() {
    double startX = 80, startY = 300, gap = 120;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        Vector2 pos = Vector2(startX + col * gap, startY + row * gap);
        holePositions.add(pos);
        add(CircleComponent(
            radius: 40,
            paint: Paint()..color = Colors.black.withOpacity(0.5),
            position: pos,
            anchor: Anchor.center));
      }
    }
  }

  void nextQuestion() {
    isInputLocked = false;
    updateLevel();

    final List<dynamic> levelQuestions = questionBank[currentLevel]!;
    currentQuestion = levelQuestions[random.nextInt(levelQuestions.length)];

    // Set wrapped question
    (questionText).text = currentQuestion['question'];
    gameTimer.limit = {"easy": 6.0, "medium": 5.0, "hard": 4.0}[currentLevel]!;
    gameTimer.start();

    spawnMoles();
  }

  void spawnMoles() {
    removeAll(activeMoles);
    activeMoles.clear();

    final List<String> options = List<String>.from(currentQuestion['options']);
    final List<Vector2> shuffledPositions = List.from(holePositions)..shuffle();

    for (int i = 0; i < options.length; i++) {
      final mole = Mole(
        text: options[i],
        position: shuffledPositions[i],
        onTap: () => handleTap(i),
      );
      activeMoles.add(mole);
      add(mole);
      mole.popUp();
    }
  }

  void handleTap(int tappedIndex) {
    if (isInputLocked) return;
    isInputLocked = true;
    gameTimer.stop();

    bool isCorrect = tappedIndex == currentQuestion['correct'];

    // Update mole colors
    for (int i = 0; i < activeMoles.length; i++) {
      activeMoles[i].reveal(i == currentQuestion['correct'], i == tappedIndex);
    }

    if (isCorrect) {
      score++;
      scoreText.text = "Score: $score";

      // XP system
      if (currentLevel == "easy") xp += 10;
      if (currentLevel == "medium") xp += 20;
      if (currentLevel == "hard") xp += 40;
      xpText.text = "XP: $xp";
    } else {
      lives--;
      livesText.text = "Lives: $lives";
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (lives <= 0) {
        gameOver();
      } else {
        nextQuestion();
      }
    });
  }

  void handleMiss() {
    if (isInputLocked) return;
    isInputLocked = true;
    gameTimer.stop();

    lives--;
    livesText.text = "Lives: $lives";

    for (int i = 0; i < activeMoles.length; i++) {
      activeMoles[i].reveal(i == currentQuestion['correct'], false);
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (lives <= 0) {
        gameOver();
      } else {
        nextQuestion();
      }
    });
  }

  void updateLevel() {
    if (score >= 10) {
      currentLevel = "hard";
      levelText.text = "Level: Hard";
      levelText.textRenderer =
          TextPaint(style: const TextStyle(color: Colors.red, fontSize: 20));
    } else if (score >= 5) {
      currentLevel = "medium";
      levelText.text = "Level: Medium";
      levelText.textRenderer =
          TextPaint(style: const TextStyle(color: Colors.orange, fontSize: 20));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameTimer.update(dt);
    if (gameTimer.isRunning()) {
      timerText.text =
          "Time: ${(gameTimer.limit - gameTimer.current).toStringAsFixed(1)}";
    }
  }

  void gameOver() {
    overlays.add('GameOver');
    pauseEngine();
  }

  void restart() {
    score = 0;
    lives = 3;
    xp = 0;
    currentLevel = "easy";
    scoreText.text = "Score: $score";
    livesText.text = "Lives: $lives";
    levelText.text = "Level: Easy";
    xpText.text = "XP: $xp";

    nextQuestion();
    overlays.remove('GameOver');
    resumeEngine();
  }

  void _initUI() {
    // Question
    questionText = TextBoxComponent(
      text: '',
      boxConfig: TextBoxConfig(
        maxWidth: size.x - 40,
        growingBox: true,
      ),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(size.x / 2, 150),
      anchor: Anchor.topCenter,
    );

    // Score and others
    scoreText = TextComponent(
      text: "Score: $score",
      position: Vector2(20, 20),
      textRenderer:
          TextPaint(style: const TextStyle(color: Colors.yellow, fontSize: 20)),
    );

    levelText = TextComponent(
      text: "Level: Easy",
      position: Vector2(150, 20),
      textRenderer:
          TextPaint(style: const TextStyle(color: Colors.green, fontSize: 20)),
    );

    timerText = TextComponent(
      text: "Time: 0.0",
      position: Vector2(280, 20),
      textRenderer:
          TextPaint(style: const TextStyle(color: Colors.white, fontSize: 20)),
    );

    livesText = TextComponent(
      text: "Lives: $lives",
      position: Vector2(20, 60),
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
    );

    xpText = TextComponent(
      text: "XP: $xp",
      position: Vector2(size.x - 70, 60),
      textRenderer: TextPaint(
          style: const TextStyle(
              color: Color.fromARGB(255, 41, 4, 144),
              fontSize: 20,
              fontWeight: FontWeight.bold)),
    );

    addAll([questionText, scoreText, levelText, timerText, livesText, xpText]);
  }
}