// screens/game_screen.dart
import 'package:flutter/material.dart';
import 'models/level.dart';
import 'models/robot.dart';
import '../widgets/grid_widget.dart';
import '../widgets/command_input.dart';

class GameScreen extends StatefulWidget {
  final int levelNumber;

  GameScreen({required this.levelNumber});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Level level;
  bool isWon = false;
  bool isExecuting = false;

  @override
  void initState() {
    super.initState();
    level = Level.generate(widget.levelNumber);
  }

  Future<void> executeCommands(List<String> commands) async {
    setState(() {
      isExecuting = true;
    });

    for (String command in commands) {
      String cmd = command.trim().toLowerCase();

      int nextX = level.robot.x;
      int nextY = level.robot.y;

      switch (cmd) {
        case 'forward':
          switch (level.robot.direction) {
            case Direction.north:
              nextY = (level.robot.y - 1).clamp(0, 4);
              break;
            case Direction.east:
              nextX = (level.robot.x + 1).clamp(0, 4);
              break;
            case Direction.south:
              nextY = (level.robot.y + 1).clamp(0, 4);
              break;
            case Direction.west:
              nextX = (level.robot.x - 1).clamp(0, 4);
              break;
          }
          break;
        case 'backward':
          switch (level.robot.direction) {
            case Direction.north:
              nextY = (level.robot.y + 1).clamp(0, 4);
              break;
            case Direction.east:
              nextX = (level.robot.x - 1).clamp(0, 4);
              break;
            case Direction.south:
              nextY = (level.robot.y - 1).clamp(0, 4);
              break;
            case Direction.west:
              nextX = (level.robot.x + 1).clamp(0, 4);
              break;
          }
          break;
        case 'turn left':
          level.robot.turnLeft();
          break;
        case 'turn right':
          level.robot.turnRight();
          break;
        default:
          // Invalid command - skip
          continue;
      }

      // Check for walls before moving
      if (cmd == 'forward' || cmd == 'backward') {
        if (!level.walls[nextY][nextX]) {
          level.robot.x = nextX;
          level.robot.y = nextY;
        }
      }

      setState(() {});
      await Future.delayed(Duration(milliseconds: 800));

      // Check win condition
      if (level.robot.x == level.targetX && level.robot.y == level.targetY) {
        setState(() {
          isWon = true;
          isExecuting = false;
        });
        _showWinDialog();
        return;
      }
    }

    setState(() {
      isExecuting = false;
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('🎉 Level Complete!'),
          content: Text(
            'Congratulations! You successfully guided the robot to the target.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Return to level select
              },
              child: Text('Next Level'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetLevel();
              },
              child: Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _resetLevel() {
    setState(() {
      level = Level.generate(widget.levelNumber);
      isWon = false;
      isExecuting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        (mediaQuery.size.height -
                mediaQuery.padding.top -
                kToolbarHeight -
                mediaQuery.viewInsets.bottom -
                16 * 2)
            .clamp(0, double.infinity); // padding top and bottom

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Level ${widget.levelNumber}'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetLevel),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    (availableHeight - 20).clamp(0, double.infinity) * 0.6,
              ),
              child: GridWidget(
                robot: level.robot,
                targetX: level.targetX,
                targetY: level.targetY,
                isWon: isWon,
                walls: level.walls,
              ),
            ),
            SizedBox(height: 20),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    (availableHeight - 20).clamp(0, double.infinity) * 0.4,
              ),
              child: CommandInput(
                onExecute: executeCommands,
                isExecuting: isExecuting,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
