import 'dart:convert';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rural_learning_app/data/profile_service.dart';
import 'mole.dart';

class WhackAMoleGame extends FlameGame {
  // UI Components
  late TextBoxComponent questionText;
  late TextComponent scoreText, levelText, timerText, livesText, xpText;

  // Game State
  int score = 0, lives = 3, xp = 0;
  String currentLevel = "easy";
  late Timer gameTimer;
  bool isInputLocked = false;

  // Questions & Moles
  Map<String, List<dynamic>> questionBank = {};
  late Map<String, dynamic> currentQuestion;
  final Random random = Random();
  List<Mole> activeMoles = [];
  List<Vector2> holePositions = [];

  @override
  Color backgroundColor() => const Color(0xFF152C3E); // Dark blue background

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadQuestions();
    _createUI();
    _updateLayout(); // Initial layout setup

    gameTimer = Timer(3.0, onTick: handleMiss, repeat: true)..stop();
    nextQuestion();
  }

  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    if (!isLoaded) return;
    if (size.x == 0 || size.y == 0) return;

    _updateLayout();
    // Respawn moles in new positions to adapt to the new screen size
    spawnMoles();
  }

  // Recalculates all UI element positions and sizes.
  void _updateLayout() {
    _updateUIPositions();
    _calculateHolePositions();
  }

  Future<void> loadQuestions() async {
    final String jsonString = await rootBundle.loadString(
      'assets/questions.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    questionBank = {
      "easy": jsonMap["easy"] as List<dynamic>,
      "medium": jsonMap["medium"] as List<dynamic>,
      "hard": jsonMap["hard"] as List<dynamic>,
    };
  }

  // Calculates where moles can appear, restricting them to the bottom 70% of the screen.
  void _calculateHolePositions() {
    holePositions.clear();

    // Define the game area (bottom 70% of the screen)
    final double gameAreaStartY = size.y * 0.30;
    final double gameAreaHeight = size.y * 0.70;

    // Grid takes up 85% of the available game area space
    final double gridSize = min(size.x, gameAreaHeight) * 0.85;
    final double gridStartX = (size.x - gridSize) / 2;
    // Center the grid vertically within the game area
    final double gridStartY = gameAreaStartY + (gameAreaHeight - gridSize) / 2;

    final double gap = gridSize / 3;

    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        holePositions.add(
          Vector2(
            gridStartX + col * gap + gap / 2,
            gridStartY + row * gap + gap / 2,
          ),
        );
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

  void spawnMoles() {
    removeAll(activeMoles);
    activeMoles.clear();

    final options = List<String>.from(currentQuestion['options']);
    final shuffledPositions = List.from(holePositions)..shuffle();
    // Base mole size on the gap between holes for consistency
    final double gap = min(size.x, size.y * 0.70) * 0.85 / 3;
    final double moleSize = gap * 0.8;

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
      xp += {"easy": 10, "medium": 20, "hard": 40}[currentLevel]!;
    } else {
      lives--;
    }
    _updateScoreboard();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (lives <= 0)
        gameOver();
      else
        nextQuestion();
    });
  }

  void handleMiss() {
    if (isInputLocked) return;
    isInputLocked = true;
    gameTimer.stop();
    lives--;
    _updateScoreboard();

    for (int i = 0; i < activeMoles.length; i++) {
      activeMoles[i].reveal(i == currentQuestion['correct'], false);
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (lives <= 0)
        gameOver();
      else
        nextQuestion();
    });
  }

  void updateLevel() {
    if (score >= 10) {
      currentLevel = "hard";
      levelText.text = "Level: Hard";
      levelText.textRenderer = TextPaint(
        style: const TextStyle(color: Colors.red, fontSize: 20),
      );
    } else if (score >= 5) {
      currentLevel = "medium";
      levelText.text = "Level: Medium";
      levelText.textRenderer = TextPaint(
        style: const TextStyle(color: Colors.orange, fontSize: 20),
      );
    } else {
      currentLevel = "easy";
      levelText.text = "Level: Easy";
      levelText.textRenderer = TextPaint(
        style: const TextStyle(color: Colors.green, fontSize: 20),
      );
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
  ProfileService.updateProgress(xpGained: xp);

    // Clean up the screen before showing the overlay
    removeAll(activeMoles);
    activeMoles.clear();
    questionText.text = '';

    overlays.add('GameOver');
    pauseEngine();
  }

  void restart() {
    score = 0;
    lives = 3;
    xp = 0;
    currentLevel = "easy";
    _updateScoreboard();
    updateLevel();

    overlays.remove('GameOver');
    resumeEngine();
    nextQuestion();
  }

  void _updateScoreboard() {
    scoreText.text = "Score: $score";
    livesText.text = "Lives: $lives";
    xpText.text = "XP: $xp";
  }

  void _createUI() {
    const uiPriority = 10;

    // Question text
    questionText = TextBoxComponent(
      text: '',
      boxConfig: TextBoxConfig(
        maxWidth: size.x * 0.9, // fill horizontal space, wrap only if needed
        timePerChar: 0, // instant display
      ),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      align: Anchor.center,
      priority: uiPriority,
    );

    // Top row info
    scoreText = _makeText(
      "Score: $score",
      Colors.yellow,
      20,
      bold: true,
      anchor: Anchor.centerLeft,
    )..priority = uiPriority;
    levelText = _makeText(
      "Level: Easy",
      Colors.green,
      20,
      anchor: Anchor.center,
    )..priority = uiPriority;
    timerText = _makeText(
      "Time: 0.0",
      Colors.white,
      20,
      anchor: Anchor.centerRight,
    )..priority = uiPriority;

    // Second row info
    livesText = _makeText(
      "Lives: $lives",
      Colors.red,
      20,
      bold: true,
      anchor: Anchor.center,
    )..priority = uiPriority;
    xpText = _makeText(
      "XP: $xp",
      Colors.lightBlueAccent,
      20,
      bold: true,
      anchor: Anchor.center,
    )..priority = uiPriority;

    addAll([questionText, scoreText, levelText, timerText, livesText, xpText]);
  }

void _updateUIPositions() {
  final double topUIHeight = size.y * 0.3;

  // Top row
  final double topRowY = topUIHeight * 0.2;
  scoreText.position = Vector2(size.x * 0.05, topRowY);
  levelText.position = Vector2(size.x * 0.5, topRowY);
  timerText.position = Vector2(size.x * 0.95, topRowY);

  // Second row
  final double secondRowY = topRowY + topUIHeight * 0.15;
  livesText.position = Vector2(size.x * 0.35, secondRowY);
  xpText.position = Vector2(size.x * 0.65, secondRowY);

  // Question box
  final double questionBoxHeight = topUIHeight * 0.3;
  questionText
    ..size = Vector2(size.x * 0.9, questionBoxHeight)
    ..position = Vector2(size.x * 0.5, secondRowY + questionBoxHeight / 2);

  // Force re-render by updating text (triggers re-centering)
  final current = questionText.text;
  questionText.text = '';
  questionText.text = current;
}



  // Helper for creating TextComponents
  TextComponent _makeText(
    String text,
    Color color,
    double fontSize, {
    bool bold = false,
    Anchor anchor = Anchor.center,
  }) {
    return TextComponent(
      text: text,
      anchor: anchor,
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
