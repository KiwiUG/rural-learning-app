// models/level.dart
import 'dart:math';
import 'robot.dart';

class Level {
  final int number;
  final Robot robot;
  final int targetX;
  final int targetY;
  final List<List<bool>> walls; // 5x5 grid, true if wall

  Level._({
    required this.number,
    required this.robot,
    required this.targetX,
    required this.targetY,
    required this.walls,
  });

  static Level generate(int levelNumber) {
    List<List<bool>> walls = List.generate(5, (_) => List.filled(5, false));

    int robotX, robotY, targetX, targetY;
    Direction robotDirection;

    if (levelNumber == 1) {
      robotX = 0;
      robotY = 0;
      robotDirection = Direction.east;
      targetX = 4;
      targetY = 4;
    } else if (levelNumber == 2) {
      robotX = 0;
      robotY = 2;
      robotDirection = Direction.east;
      targetX = 4;
      targetY = 2;
      // Add walls
      walls[2][1] = true;
      walls[2][2] = true;
      walls[2][3] = true;
    } else if (levelNumber == 3) {
      robotX = 0;
      robotY = 0;
      robotDirection = Direction.east;
      targetX = 4;
      targetY = 4;
      // Add walls
      walls[1][1] = true;
      walls[1][2] = true;
      walls[1][3] = true;
      walls[2][1] = true;
      walls[3][1] = true;
      walls[3][2] = true;
      walls[3][3] = true;
    } else {
      // Random levels
      Random random = Random();
      robotX = random.nextInt(5);
      robotY = random.nextInt(5);
      robotDirection = Direction.values[random.nextInt(4)];
      do {
        targetX = random.nextInt(5);
        targetY = random.nextInt(5);
      } while (targetX == robotX && targetY == robotY);
    }

    return Level._(
      number: levelNumber,
      robot: Robot(x: robotX, y: robotY, direction: robotDirection),
      targetX: targetX,
      targetY: targetY,
      walls: walls,
    );
  }
}
