import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rural_learning_app/data/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Question model
class Question {
  final String clue;
  final String answer;

  Question({required this.clue, required this.answer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(clue: json['clue'], answer: json['answer']);
  }
}

/// Load questions from JSON
Future<Map<String, List<Question>>> loadQuestions() async {
  final jsonString = await rootBundle.loadString('assets/data/questions.json');
  final Map<String, dynamic> jsonMap = json.decode(jsonString);

  Map<String, List<Question>> questionsByTheme = {};
  jsonMap.forEach((theme, questionsList) {
    questionsByTheme[theme] = (questionsList as List)
        .map((q) => Question.fromJson(q))
        .toList();
  });
  return questionsByTheme;
}

/// Main App
class GuessTheABCsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "STEM Quiz",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2C3E50),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            backgroundColor: Color(0xFF2C3E50),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          hintStyle: TextStyle(color: Colors.black45),
          labelStyle: TextStyle(color: Colors.black87),
        ),
      ),
      home: ABCGame(),
    );
  }
}

/// ---------------- Home Screen ----------------
class ABCGame extends StatefulWidget {
  @override
  _ABCGameState createState() => _ABCGameState();
}

class _ABCGameState extends State<ABCGame> {
  Map<String, List<Question>> allQuestions = {};
  String selectedTheme = 'Physics';
  bool loading = true;
  int highScore = 0;
  List<String> lastScores = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final questions = await loadQuestions();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      allQuestions = questions;
      loading = false;
      highScore = prefs.getInt('highscore') ?? 0;
      lastScores = prefs.getStringList('lastScores') ?? [];
    });
  }

  void _startGame() {
    if (!allQuestions.containsKey(selectedTheme)) return;
    // Copy and shuffle only the selected theme's questions
    final shuffledQuestions = List<Question>.from(allQuestions[selectedTheme]!);
    shuffledQuestions.shuffle();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(questions: shuffledQuestions),
      ),
    ).then((_) => _reloadHighScore());
  }

  Future<void> _reloadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highscore') ?? 0;
      lastScores = prefs.getStringList('lastScores') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF2C3E50)),
        ),
      );

    final themes = allQuestions.keys.toList();
    final List<String> rankEmojis = ['🥇', '🥈', '🥉', '🏅', '🎖️'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text("STEM Quiz")),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                "STEM Quiz",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                "Select a theme and answer 30 questions. Type the answer before time runs out!",
                style: TextStyle(fontSize: 16, color: Colors.black45),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedTheme,
                dropdownColor: Colors.white,
                items: themes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t, style: TextStyle(color: Colors.black87)),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => selectedTheme = v ?? themes.first),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelText: 'Theme',
                  labelStyle: TextStyle(color: Colors.black87),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.play_arrow, color: Colors.white),
                label: Text(
                  "Start Game",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2C3E50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size.fromHeight(50),
                  foregroundColor: Colors.white,
                ),
                onPressed: _startGame,
              ),
              SizedBox(height: 30),
              Card(
                elevation: 2,
                color: Colors.white,
                child: ListTile(
                  leading: Icon(Icons.star, color: Color(0xFF2C3E50)),
                  title: Text(
                    "High Score",
                    style: TextStyle(color: Colors.black87),
                  ),
                  trailing: Text(
                    "$highScore",
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Last 5 Scores:',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              SizedBox(height: 8),
              Column(
                children: lastScores.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String score = entry.value;
                  String emoji = idx < rankEmojis.length
                      ? rankEmojis[idx]
                      : '🏅';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emoji, style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Text(
                        score,
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- Game Screen ----------------
class GameScreen extends StatefulWidget {
  final List<Question> questions;
  GameScreen({required this.questions});
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  int index = 0, lives = 3, score = 0, streak = 0, xp = 0;
  List<String> badges = [];
  final TextEditingController _controller = TextEditingController();
  bool submitted = false;
  String feedbackText = '';
  int remainingSeconds = 20;
  Timer? timer;

  // Animation
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _burstAnim;
  Color feedbackColor = Colors.transparent;
  Color burstColor = Colors.transparent;
  bool showBurst = false;
  bool showHintLetter = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
    _scaleAnim = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _burstAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  Question get currentQuestion => widget.questions[index];

  void _startTimer() {
    timer?.cancel();
    remainingSeconds = 20;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (remainingSeconds <= 1) {
        t.cancel();
        _applyAnswer(isCorrect: false, auto: true);
      } else
        setState(() => remainingSeconds--);
    });
  }

  void _applyAnswer({bool isCorrect = false, bool auto = false}) {
    timer?.cancel();
    setState(() {
      submitted = true;
      showBurst = true;
      if (isCorrect) {
        int pts = 10 + remainingSeconds;
        score += pts;
        xp += 5 + remainingSeconds ~/ 2;
        streak += 1;
        feedbackText = '+$pts Points!';
        feedbackColor = Colors.green.shade400;
        burstColor = Colors.greenAccent.shade400;
        _animController.forward().then((_) => _animController.reverse());

        if (streak % 5 == 0) badges.add('Streak x$streak');
      } else {
        feedbackText = auto
            ? 'Time Up! Answer: ${currentQuestion.answer}'
            : 'Wrong! Answer: ${currentQuestion.answer}';
        streak = 0;
        lives--;
        feedbackColor = Colors.red.shade300;
        burstColor = Colors.redAccent.shade400;
        _animController.forward().then((_) => _animController.reverse());
      }
    });

    Future.delayed(Duration(milliseconds: 700), () {
      setState(() {
        showBurst = false;
        burstColor = Colors.transparent;
      });
      Future.delayed(Duration(milliseconds: 300), _nextQuestion);
    });
  }

  void _submit() {
    if (submitted) return;
    final ans = _controller.text.trim().toLowerCase();
    final correct = currentQuestion.answer.trim().toLowerCase();
    _applyAnswer(isCorrect: ans == correct);
  }

  void _nextQuestion() {
    _controller.clear();
    setState(() {
      submitted = false;
      feedbackText = '';
      feedbackColor = Colors.transparent;
      burstColor = Colors.transparent;
      showBurst = false;
      showHintLetter = false;
      if (lives <= 0 || index >= widget.questions.length - 1) {
        _endGame();
      } else {
        index++;
        _startTimer();
      }
    });
  }

  Future<void> _endGame() async {
    timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    final high = prefs.getInt('highscore') ?? 0;
    if (score > high) await prefs.setInt('highscore', score);

    ProfileService.updateProgress(xpGained: xp);
    // Save last 5 scores
    List<String> lastScores = prefs.getStringList('lastScores') ?? [];
    lastScores.insert(0, score.toString());
    if (lastScores.length > 5) lastScores = lastScores.sublist(0, 5);
    await prefs.setStringList('lastScores', lastScores);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            ResultScreen(score: score, xp: xp, lastScores: lastScores),
      ),
    );
  }

  void _quitGame() {
    timer?.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  Widget _buildBurstAnimation() {
    return Center(
      child: AnimatedBuilder(
        animation: _burstAnim,
        builder: (context, child) {
          double size = 180 * _burstAnim.value;
          return Opacity(
            opacity: 1 - (0.7 * (1 - _burstAnim.value)),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: burstColor,
                boxShadow: [
                  BoxShadow(
                    color: burstColor.withOpacity(0.6),
                    blurRadius: 40 * _burstAnim.value,
                    spreadRadius: 10 * _burstAnim.value,
                  ),
                ],
              ),
              child: Icon(
                burstColor == Color(0xFF27AE60)
                    ? Icons.check_circle
                    : Icons.cancel,
                color: Colors.white,
                size: 80 * _burstAnim.value,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstLetter = currentQuestion.answer.isNotEmpty
        ? currentQuestion.answer[0].toUpperCase()
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${index + 1}/${widget.questions.length}'),
        actions: [
          TextButton.icon(
            onPressed: _quitGame,
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            label: Text(
              "Quit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[300]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lives: $lives ❤️',
                        style: TextStyle(color: Colors.black87),
                      ),
                      Text(
                        'Score: $score',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Streak: $streak',
                        style: TextStyle(color: Colors.black87),
                      ),
                      TextButton.icon(
                        onPressed: _quitGame,
                        icon: Icon(Icons.exit_to_app, color: Color(0xFF2C3E50)),
                        label: Text(
                          "Quit",
                          style: TextStyle(
                            color: Color(0xFF2C3E50),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Card(
                      elevation: 4,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            if (showHintLetter)
                              Text(
                                firstLetter,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            Text(
                              currentQuestion.clue,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: remainingSeconds / 20,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      remainingSeconds > 10
                          ? Color(0xFF27AE60)
                          : remainingSeconds > 5
                          ? Color(0xFFF1C40F)
                          : Color(0xFFE74C3C),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Type your answer here',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintStyle: TextStyle(color: Colors.black45),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.lightbulb, color: Color(0xFFF1C40F)),
                        tooltip: "Show first letter",
                        onPressed: () {
                          setState(() {
                            showHintLetter = true;
                          });
                        },
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      'Submit Answer',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2C3E50),
                      minimumSize: Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    feedbackText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: feedbackColor == Colors.transparent
                          ? Colors.black87
                          : feedbackColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bomb burst animation popup
          if (showBurst) _buildBurstAnimation(),
        ],
      ),
    );
  }
}

/// ---------------- Result Screen ----------------
class ResultScreen extends StatelessWidget {
  final int score;
  final int xp;
  final List<String> lastScores;

  ResultScreen({
    required this.score,
    required this.xp,
    required this.lastScores,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> rankEmojis = ['🥇', '🥈', '🥉', '🏅', '🎖️'];
    return Scaffold(
      appBar: AppBar(title: Text("Game Over")),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[300]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score: $score',
              style: TextStyle(
                fontSize: 32,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'XP Earned: $xp',
              style: TextStyle(fontSize: 24, color: Colors.black45),
            ),
            SizedBox(height: 30),
            Text(
              'Last 5 Scores:',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 8),
            Column(
              children: lastScores.asMap().entries.map((entry) {
                int idx = entry.key;
                String score = entry.value;
                String emoji = idx < rankEmojis.length ? rankEmojis[idx] : '🏅';
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(emoji, style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text(
                      score,
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 20,
                ),
                child: Text(
                  'Play Again',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2C3E50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
