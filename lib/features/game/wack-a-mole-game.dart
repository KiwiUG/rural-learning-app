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
  
  // Safe area for UI, to avoid status bar and AppBar
  final double topMargin = 50.0; 

  // Questions & Moles
  Map<String, List<dynamic>> questionBank = {};
  late Map<String, dynamic> currentQuestion;
  final Random random = Random();
  List<Mole> activeMoles = [];
  List<Vector2> holePositions = [];

  @override
  Color backgroundColor() => const Color(0xFF152C3E);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await loadQuestions();
    _createUI();
    
    // Initialize currentQuestion with a default empty value
    currentQuestion = {'question': ''}; 
    
    _updateLayout(); // Sets initial positions based on screen size

    gameTimer = Timer(3.0, onTick: handleMiss, repeat: true)..stop();
    nextQuestion(); 
  }


  @override
  void onGameResize(Vector2 newSize) {
    super.onGameResize(newSize);
    if (!isLoaded || size.x == 0 || size.y == 0) return;

    // This properly handles auto-rotate.
    // It rebuilds the UI layout and respawns the moles in their new correct positions.
    _updateLayout();
    spawnMoles();
  }

  void _updateLayout() {
    _updateUIPositions();
    _calculateHolePositions();
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

  // ✅ UPDATED: Positions moles to fill the remaining screen space with even borders.
  void _calculateHolePositions() {
    holePositions.clear();

    // Game area starts after the 35% UI area, as before.
    final double gameAreaStartY = topMargin + (size.y * 0.35);
    final double gameAreaHeight = size.y - gameAreaStartY;

    // Define explicit margins to control spacing.
    final double gridMarginTop = 10.0;    // A small gap after the question.
    final double gridMarginBottom = 20.0; // A small border at the bottom.

    // Calculate the actual height available for the grid.
    final double availableHeight = gameAreaHeight - gridMarginTop - gridMarginBottom;
    
    // The grid will be a square sized to fit the available space.
    final double gridSize = min(size.x * 0.85, availableHeight); 
    
    // Center the grid horizontally.
    final double gridStartX = (size.x - gridSize) / 2;

    // Position the grid to start right after the top margin.
    final double gridStartY = gameAreaStartY + gridMarginTop;
    
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
    final double gap = min(size.x, size.y * 0.60) * 0.90 / 3;
    final double moleSize = gap * 0.8;

    for (int i = 0; i < options.length; i++) {
      final mole = Mole(
        text: options[i],
        position: shuffledPositions[i],
        diameter: moleSize,
        onTap: () => handleTap(i),
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
      if (lives <= 0) gameOver(); else nextQuestion();
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
      if (lives <= 0) gameOver(); else nextQuestion();
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
    ProfileService.updateProgress(xpGained: xp);
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
  
// ... inside the WhackAMoleGame class

  void _createUI() {
    const uiPriority = 10;
    questionText = TextBoxComponent(text: ''); 
    
    // ✅ Bolding added to all info text
    scoreText = _makeText("Score: $score", Colors.yellow, 24, bold: true, anchor: Anchor.centerLeft)..priority = uiPriority;
    levelText = _makeText("Level: Easy", Colors.green, 24, bold: true, anchor: Anchor.center)..priority = uiPriority;
    timerText = _makeText("Time: 0.0", Colors.yellow, 24, bold: true, anchor: Anchor.centerRight)..priority = uiPriority;
    livesText = _makeText("Lives: $lives", Colors.red, 26, bold: true, anchor: Anchor.center)..priority = uiPriority;
    xpText = _makeText("XP: $xp", Colors.lightBlueAccent, 26, bold: true, anchor: Anchor.center)..priority = uiPriority;
    
    addAll([scoreText, levelText, timerText, livesText, xpText]);
  }

// ... rest of your code is the same

  void _updateScoreboard() {
    scoreText.text = "Score: $score";
    livesText.text = "Lives: $lives";
    xpText.text = "XP: $xp";
  }

  void _updateUIPositions() {
    if (questionText.isMounted) {
      remove(questionText);
    }
    
    // Define the total, more compact UI area (35% of screen height)
    final double totalUiAreaHeight = size.y * 0.35;

    // Position info rows in the top half of this area
    double topRowY = topMargin + totalUiAreaHeight * 0.25;
    scoreText.position = Vector2(size.x * 0.05, topRowY);
    levelText.position = Vector2(size.x * 0.5, topRowY);
    timerText.position = Vector2(size.x * 0.95, topRowY);

    double secondRowY = topMargin + totalUiAreaHeight * 0.5;
    livesText.position = Vector2(size.x * 0.25, secondRowY);
    xpText.position = Vector2(size.x * 0.75, secondRowY);
    
    // Position question in the bottom half of this area
    final double questionAreaStartY = topMargin + totalUiAreaHeight * 0.6;
    final double questionAreaHeight = totalUiAreaHeight * 0.4;
    
    questionText = TextBoxComponent(
      text: currentQuestion['question'],
      textRenderer: TextPaint(style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      boxConfig: TextBoxConfig(maxWidth: size.x * 0.9),
      anchor: Anchor.center,
      align: Anchor.center,
      priority: 10,
    );

    questionText.position = Vector2(
      size.x * 0.5,
      questionAreaStartY + (questionAreaHeight / 2)
    );
    add(questionText);
  }

  TextComponent _makeText(String text, Color color, double fontSize, {bool bold = false, Anchor anchor = Anchor.center}) {
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