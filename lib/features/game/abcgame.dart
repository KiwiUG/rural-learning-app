import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rural_learning_app/data/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Question model
class Question {
  final String letter;
  final String clue;
  final String answer;

  Question({required this.letter, required this.clue, required this.answer});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      letter: json['letter'],
      clue: json['clue'],
      answer: json['answer'],
    );
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
      title: "Guess The ABC's",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue.shade700,
        scaffoldBackgroundColor: Colors.grey.shade50,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
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
    });
  }

  void _startGame() {
    if (!allQuestions.containsKey(selectedTheme)) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(questions: allQuestions[selectedTheme]!),
      ),
    ).then((_) => _reloadHighScore());
  }

  Future<void> _reloadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highscore') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    final themes = allQuestions.keys.toList();

    return Scaffold(
      appBar: AppBar(title: Text("Guess the ABC's")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              "STEM Alphabet Trivia",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              "Select a theme and answer 30 questions. Type the answer before time runs out!",
              style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedTheme,
              items: themes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => selectedTheme = v ?? themes.first),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                labelText: 'Theme',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.play_arrow),
              label: Text("Start Game", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
              onPressed: _startGame,
            ),
            SizedBox(height: 30),
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.amber),
                title: Text("High Score"),
                trailing: Text("$highScore"),
              ),
            ),
          ],
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

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
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
  late Animation<double> _shakeAnim;
  Color feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _startTimer();

    _animController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _scaleAnim = Tween<double>(begin: 1, end: 1.1).animate(_animController);
    _shakeAnim = Tween<double>(begin: 0, end: 8).animate(_animController);
  }

  Question get currentQuestion => widget.questions[index];

  void _startTimer() {
    timer?.cancel();
    remainingSeconds = 20;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (remainingSeconds <= 1) {
        t.cancel();
        _applyAnswer(isCorrect: false, auto: true);
      } else setState(() => remainingSeconds--);
    });
  }

  void _applyAnswer({bool isCorrect = false, bool auto = false}) {
    timer?.cancel();
    setState(() {
      submitted = true;
      if (isCorrect) {
        int pts = 10 + remainingSeconds;
        score += pts;
        xp += 5 + remainingSeconds ~/ 2;
        streak += 1;
        feedbackText = '+$pts Points!';
        feedbackColor = Colors.green.shade400;
        _animController.forward().then((_) => _animController.reverse());

        if (streak % 5 == 0) badges.add('Streak x$streak');
      } else {
        feedbackText = auto
            ? 'Time Up! Answer: ${currentQuestion.answer}'
            : 'Wrong! Answer: ${currentQuestion.answer}';
        streak = 0;
        lives--;
        feedbackColor = Colors.red.shade300;
        _animController.forward().then((_) => _animController.reverse());
      }
    });

    Future.delayed(Duration(seconds: 1), _nextQuestion);
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
    ProfileService.addXP(xp);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResultScreen(score: score, xp: xp, badges: badges)));
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Question ${index + 1}/${widget.questions.length}')),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        color: feedbackColor.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Lives: $lives ❤️', style: TextStyle(color: Colors.blueGrey.shade800)),
                  Text('Score: $score', style: TextStyle(color: Colors.blueGrey.shade800)),
                  Text('Streak: $streak', style: TextStyle(color: Colors.blueGrey.shade800)),
                ],
              ),
              SizedBox(height: 16),
              ScaleTransition(
                scale: _scaleAnim,
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(currentQuestion.letter,
                            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        Text(currentQuestion.clue,
                            style: TextStyle(fontSize: 18), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              LinearProgressIndicator(
                value: remainingSeconds / 20,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your answer here',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onSubmitted: (_) => _submit(),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                  onPressed: _submit,
                  child: Text('Submit Answer'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700)),
              SizedBox(height: 20),
              Text(feedbackText,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade900)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- Result Screen ----------------
class ResultScreen extends StatelessWidget {
  final int score;
  final int xp;
  final List<String> badges;

  ResultScreen({required this.score, required this.xp, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Game Over")),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.grey.shade100, Colors.blue.shade100]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Score: $score', style: TextStyle(fontSize: 32, color: Colors.blueGrey.shade900)),
            SizedBox(height: 12),
            Text('XP Earned: $xp', style: TextStyle(fontSize: 24, color: Colors.blueGrey.shade700)),
            SizedBox(height: 20),
            Text('Badges:', style: TextStyle(fontSize: 20, color: Colors.blueGrey.shade900)),
            SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges
                  .map((b) => Chip(label: Text(b), backgroundColor: Colors.amber.shade400))
                  .toList(),
            ),
            SizedBox(height: 40),
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Play Again'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700)),
          ],
        ),
      ),
    );
  }
}
