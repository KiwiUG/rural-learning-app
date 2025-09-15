// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(GuessTheABCsApp());
}

class GuessTheABCsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guess the ABC\'s',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Simple Question model
class Question {
  final String letter; // "A", "B", ...
  final String clue;
  final String answer; // canonical answer for checking

  Question({required this.letter, required this.clue, required this.answer});
}

/// Some sample questions. In production, move to JSON assets (one file per theme).
/// Only a few letters are filled for demo. Letters without questions will be skipped.
final Map<String, List<Question>> sampleQuestionsByTheme = {
  'Physics': [
    Question(letter: 'A', clue: 'The rate of change of velocity', answer: 'acceleration'),
    Question(letter: 'B', clue: 'The bending of light passing through a prism', answer: 'dispersion'), // B fallback example
    Question(letter: 'C', clue: 'Amount of matter in an object', answer: 'mass'), // intentionally letter mismatch possible
    Question(letter: 'F', clue: 'A force that opposes motion through air', answer: 'air resistance'),
    Question(letter: 'G', clue: 'Acceleration due to gravity on Earth (symbol)', answer: 'g'),
  ],
  'Math': [
    Question(letter: 'A', clue: 'A polygon with three sides', answer: 'triangle'),
    Question(letter: 'B', clue: 'Answer you get from multiplying numbers', answer: 'product'),
    Question(letter: 'C', clue: 'The value representing center of data (sum/n)', answer: 'mean'),
    Question(letter: 'P', clue: 'Ratio of circumference to diameter', answer: 'pi'),
  ],
  'Chemistry': [
    Question(letter: 'A', clue: 'Atomic number represents number of ?', answer: 'protons'),
    Question(letter: 'B', clue: 'pH value < 7 indicates', answer: 'acidic'),
    Question(letter: 'C', clue: 'Covalent bond shares ___ between atoms', answer: 'electrons'),
  ],
};

/// Utilities
String normalize(String s) => s.trim().toLowerCase();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedTheme = 'Physics';
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highscore') ?? 0;
    });
  }

  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(theme: _selectedTheme),
      ),
    ).then((_) => _loadHighScore()); // refresh high score when returning
  }

  @override
  Widget build(BuildContext context) {
    final themes = sampleQuestionsByTheme.keys.toList();
    return Scaffold(
      appBar: AppBar(title: Text('Guess the ABC\'s')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 18),
            Text(
              'STEM Trivia — Alphabet Game',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            Text(
              'Select a theme. Each letter (A → Z) will present a clue. Type the correct answer within the time limit.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              items: themes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedTheme = v ?? themes.first),
              decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'Theme'),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startGame,
              icon: Icon(Icons.play_arrow),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                child: Text('Start Game', style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
            Spacer(),
            Card(
              elevation: 2,
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text('Local High Score'),
                trailing: Text('$_highScore'),
              ),
            ),
            SizedBox(height: 8),
            Text('Tip: add more questions in sampleQuestionsByTheme or load from JSON assets.'),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final String theme;

  GameScreen({required this.theme});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game state
  final List<String> letters = List.generate(26, (i) => String.fromCharCode(65 + i)); // A..Z
  late Map<String, Question> questionsByLetter; // quick lookup for current theme
  int index = 0; // index into letters
  int lives = 3;
  int score = 0;
  int streak = 0;
  int xp = 0;
  List<String> earnedBadges = [];

  // Timer
  static const int perQuestionSeconds = 20;
  int remainingSeconds = perQuestionSeconds;
  Timer? timer;

  // input
  final TextEditingController _controller = TextEditingController();
  bool submitted = false;
  String feedbackText = '';

  @override
  void initState() {
    super.initState();
    _prepareQuestions();
    _startNextAvailable(); // start at first letter that has a question
  }

  void _prepareQuestions() {
    final list = sampleQuestionsByTheme[widget.theme] ?? [];
    questionsByLetter = { for (var q in list) q.letter.toUpperCase(): q };
  }

  void _startTimer() {
    timer?.cancel();
    setState(() {
      remainingSeconds = perQuestionSeconds;
    });
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (remainingSeconds <= 1) {
        t.cancel();
        _onTimeUp();
      } else {
        setState(() {
          remainingSeconds -= 1;
        });
      }
    });
  }

  void _onTimeUp() {
    // treat as wrong answer
    setState(() {
      submitted = true;
      feedbackText = 'Time up!';
      streak = 0;
      lives -= 1;
    });
    Future.delayed(Duration(seconds: 1), _nextLetter);
  }

  Question? get currentQuestion {
    final letter = letters[index];
    return questionsByLetter[letter];
  }

  void _submitAnswer() {
    if (submitted) return;
    final q = currentQuestion;
    if (q == null) return;
    final attempt = normalize(_controller.text);
    final correct = normalize(q.answer);
    setState(() {
      submitted = true;
      timer?.cancel();
      if (attempt.isNotEmpty && attempt == correct) {
        // correct
        final pts = 10 + remainingSeconds; // base + speed bonus
        score += pts;
        xp += (5 + (remainingSeconds ~/ 2));
        streak += 1;
        feedbackText = 'Correct! +$pts';
        if (streak > 0 && streak % 5 == 0) {
          earnedBadges.add('Streak x$streak');
        }
      } else {
        // wrong
        feedbackText = 'Wrong. Answer: ${q.answer}';
        streak = 0;
        lives -= 1;
      }
    });

    Future.delayed(Duration(milliseconds: 900), _nextLetter);
  }

  void _nextLetter() {
    _controller.clear();
    setState(() {
      submitted = false;
      feedbackText = '';
    });

    if (lives <= 0) {
      _endGame();
      return;
    }

    // Advance index to next letter that has a question; if none left, end
    int next = index + 1;
    while (next < letters.length && !questionsByLetter.containsKey(letters[next])) {
      next++;
    }
    if (next >= letters.length) {
      _endGame();
    } else {
      setState(() {
        index = next;
      });
      _startTimer();
    }
  }

  void _startNextAvailable() {
    // find first letter that has a question
    int first = 0;
    while (first < letters.length && !questionsByLetter.containsKey(letters[first])) {
      first++;
    }
    if (first >= letters.length) {
      // no questions for this theme
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('No questions'),
          content: Text('No questions are available for theme "${widget.theme}".'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ),
      ).then((_) => Navigator.pop(context));
      return;
    }
    setState(() {
      index = first;
      lives = 3;
      score = 0;
      streak = 0;
      xp = 0;
      earnedBadges = [];
    });
    _startTimer();
  }

  Future<void> _endGame() async {
    timer?.cancel();
    // award basic badges
    if (score > 0 && !earnedBadges.contains('Played')) earnedBadges.add('Played');
    if (streak >= 10) earnedBadges.add('Legendary Streak');

    final prefs = await SharedPreferences.getInstance();
    final high = prefs.getInt('highscore') ?? 0;
    if (score > high) {
      await prefs.setInt('highscore', score);
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: score,
          xp: xp,
          badges: earnedBadges,
          theme: widget.theme,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHeadsUp() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Lives: $lives', style: TextStyle(fontSize: 16)),
        Text('Score: $score', style: TextStyle(fontSize: 16)),
        Text('Streak: $streak', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = currentQuestion;
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme: ${widget.theme}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            timer?.cancel();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: q == null
          ? Center(child: Text('No question for ${letters[index]}.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeadsUp(),
                  SizedBox(height: 12),
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            letters[index],
                            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 12),
                          Text(q.clue, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: remainingSeconds / perQuestionSeconds,
                    minHeight: 8,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Time left: $remainingSeconds s'),
                      Text('Letter ${index + 1}/${letters.length}'),
                    ],
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    enabled: !submitted,
                    onSubmitted: (_) => _submitAnswer(),
                    decoration: InputDecoration(
                      labelText: 'Your answer',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _submitAnswer,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  if (feedbackText.isNotEmpty)
                    Text(
                      feedbackText,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  SizedBox(height: 12),
                  Expanded(child: SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // skip to next letter (penalty)
                          timer?.cancel();
                          setState(() {
                            lives -= 1;
                          });
                          _nextLetter();
                        },
                        icon: Icon(Icons.skip_next),
                        label: Text('Skip (-1 life)'),
                        style: ElevatedButton.styleFrom(primary: Colors.orange),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          timer?.cancel();
                          _endGame();
                        },
                        icon: Icon(Icons.stop),
                        label: Text('End Game'),
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  final int xp;
  final List<String> badges;
  final String theme;

  ResultScreen({required this.score, required this.xp, required this.badges, required this.theme});

  @override
  Widget build(BuildContext context) {
    String badgeText = badges.isEmpty ? 'No badges earned' : badges.join(', ');
    return Scaffold(
      appBar: AppBar(title: Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Text(
              'Finished — Theme: $theme',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 18),
            Card(
              child: ListTile(
                leading: Icon(Icons.score),
                title: Text('Score'),
                trailing: Text('$score'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.flash_on),
                title: Text('XP Earned'),
                trailing: Text('$xp'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.emoji_events),
                title: Text('Badges'),
                subtitle: Text(badgeText),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.replay),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => GameScreen(theme: theme)),
                );
              },
              label: Text('Play Again'),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                  (route) => false,
                );
              },
              label: Text('Back to Home'),
              style: ElevatedButton.styleFrom(primary: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
