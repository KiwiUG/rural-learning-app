// models/robot.dart
enum Direction { north, east, south, west }

class Robot {
  int x;
  int y;
  Direction direction;

  Robot({required this.x, required this.y, required this.direction});

  void moveForward() {
    switch (direction) {
      case Direction.north:
        y = (y - 1).clamp(0, 4);
        break;
      case Direction.east:
        x = (x + 1).clamp(0, 4);
        break;
      case Direction.south:
        y = (y + 1).clamp(0, 4);
        break;
      case Direction.west:
        x = (x - 1).clamp(0, 4);
        break;
    }
  }

  void moveBackward() {
    switch (direction) {
      case Direction.north:
        y = (y + 1).clamp(0, 4);
        break;
      case Direction.east:
        x = (x - 1).clamp(0, 4);
        break;
      case Direction.south:
        y = (y - 1).clamp(0, 4);
        break;
      case Direction.west:
        x = (x + 1).clamp(0, 4);
        break;
    }
  }

  void turnLeft() {
    switch (direction) {
      case Direction.north:
        direction = Direction.west;
        break;
      case Direction.east:
        direction = Direction.north;
        break;
      case Direction.south:
        direction = Direction.east;
        break;
      case Direction.west:
        direction = Direction.south;
        break;
    }
  }

  void turnRight() {
    switch (direction) {
      case Direction.north:
        direction = Direction.east;
        break;
      case Direction.east:
        direction = Direction.south;
        break;
      case Direction.south:
        direction = Direction.west;
        break;
      case Direction.west:
        direction = Direction.north;
        break;
    }
  }

  double getRotation() {
    switch (direction) {
      case Direction.north:
        return 0;
      case Direction.east:
        return 1.5708; // 90 degrees in radians
      case Direction.south:
        return 3.14159; // 180 degrees
      case Direction.west:
        return 4.71239; // 270 degrees
    }
  }
}
