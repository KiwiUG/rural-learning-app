import 'dart:convert';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'mole.dart';

class WhackAMoleGame extends FlameGame {
  late TextComponent questionText, scoreText, levelText, timerText, livesText, xpText;

  int score = 0, lives = 3, xp = 0;
  String currentLevel = "easy";
  late Timer gameTimer;
  bool isInputLocked = false;

  Map<String, List<dynamic>> questionBank = {};
  late Map<String, dynamic> currentQuestion;
  final Random random = Random();

  List<Mole> activeMoles = [];
  List<CircleComponent> moleHoles = [];
  List<Vector2> holePositions = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await loadQuestions();
    _createUI();
    _updateLayout();

    gameTimer = Timer(3.0, onTick: handleMiss, repeat: true)..stop();
    nextQuestion();
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    if (!isLoaded) return; // FIX 1: Use isLoaded to prevent errors during initialization.
    
    if (size.x == 0 || size.y == 0) return;
    _updateLayout();
  }

  void _updateLayout() {
    _createMoleHoles();
    _updateUIPositions();
  }

  Future<void> loadQuestions() async {
    final String jsonString = await rootBundle.loadString('assets/questions.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    questionBank = {
      "easy": jsonMap["easy"] as List<dynamic>,
      "medium": jsonMap["medium"] as List<dynamic>,
      "hard": jsonMap["hard"] as List<dynamic>,
    };
  }

  void _createMoleHoles() {
    removeAll(moleHoles);
    moleHoles.clear();
    holePositions.clear();

    double gridSize = min(size.x, size.y) * 0.7;
    double gap = gridSize / 3;
    double startX = (size.x - gridSize) / 2;
    double startY = (size.y - gridSize) / 2;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        Vector2 pos = Vector2(startX + col * gap + gap / 2, startY + row * gap + gap / 2);
        holePositions.add(pos);

        final hole = CircleComponent(
          radius: gap * 0.33,
          paint: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = Colors.white.withOpacity(0.3),
          position: pos,
          anchor: Anchor.center,
        );
        moleHoles.add(hole);
        add(hole);
      }
    }
  }

  void nextQuestion() {
    isInputLocked = false;
    updateLevel();

    final List<dynamic> levelQuestions = questionBank[currentLevel]!;
    currentQuestion = levelQuestions[random.nextInt(levelQuestions.length)];

    questionText.text = currentQuestion['question'];
    gameTimer.limit = {"easy": 6.0, "medium": 5.0, "hard": 4.0}[currentLevel]!;
    gameTimer.start();

    spawnMoles();
  }

// wack_a_mole_game.dart (spawnMoles method only)

  void spawnMoles() {
    removeAll(activeMoles);
    activeMoles.clear();

    final options = List<String>.from(currentQuestion['options']);
    final shuffledPositions = List.from(holePositions)..shuffle();
    double moleSize = min(size.x, size.y) * 0.18;

    for (int i = 0; i < options.length; i++) {
      final int moleIndex = i;
      final mole = Mole(
        text: options[i],
        position: shuffledPositions[i],
        diameter: moleSize,
        onTap: () => handleTap(moleIndex),
      );
      activeMoles.add(mole);
      add(mole);
      // **FIX:** Remove this line. The mole will pop up automatically from its own onLoad.
      // mole.popUp(); 
    }
  }

  void handleTap(int tappedIndex) {
    if (isInputLocked) return;
    isInputLocked = true;
    gameTimer.stop();

    bool isCorrect = tappedIndex == currentQuestion['correct'];

    for (int i = 0; i < activeMoles.length; i++) {
      activeMoles[i].reveal(i == currentQuestion['correct'], i == tappedIndex);
    }

    if (isCorrect) {
      score++;
      scoreText.text = "Score: $score";
      xp += {"easy": 10, "medium": 20, "hard": 40}[currentLevel]!;
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
      levelText.textRenderer = TextPaint(style: const TextStyle(color: Colors.red, fontSize: 20));
    } else if (score >= 5) {
      currentLevel = "medium";
      levelText.text = "Level: Medium";
      levelText.textRenderer = TextPaint(style: const TextStyle(color: Colors.orange, fontSize: 20));
    } else {
      currentLevel = "easy";
      levelText.text = "Level: Easy";
      levelText.textRenderer = TextPaint(style: const TextStyle(color: Colors.green, fontSize: 20));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    gameTimer.update(dt);
    if (gameTimer.isRunning()) {
      timerText.text = "Time: ${(gameTimer.limit - gameTimer.current).toStringAsFixed(1)}";
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

    overlays.remove('GameOver');
    resumeEngine();
    nextQuestion();
  }

  void _createUI() {
    questionText = _makeText('', Colors.white, 22, bold: true);
    scoreText = _makeText("Score: $score", Colors.yellow, 20);
    levelText = _makeText("Level: Easy", Colors.green, 20);
    timerText = _makeText("Time: 0.0", Colors.white, 20);
    livesText = _makeText("Lives: $lives", Colors.red, 20, bold: true);
    xpText = _makeText("XP: $xp", Colors.lightBlueAccent, 20, bold: true);

    addAll([questionText, scoreText, levelText, timerText, livesText, xpText]);
  }

  void _updateUIPositions() {
    // FIX 3: Removed redundant null check.
    questionText.position = Vector2(size.x * 0.5, size.y * 0.15);
    scoreText.position = Vector2(size.x * 0.1, size.y * 0.05);
    levelText.position = Vector2(size.x * 0.5, size.y * 0.05);
    timerText.position = Vector2(size.x * 0.9, size.y * 0.05);
    livesText.position = Vector2(size.x * 0.3, size.y * 0.12);
    xpText.position = Vector2(size.x * 0.7, size.y * 0.12);
  }

  TextComponent _makeText(String text, Color color, double fontSize, {bool bold = false}) {
    return TextComponent(
      text: text,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}