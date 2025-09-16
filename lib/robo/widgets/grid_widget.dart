// widgets/grid_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/models/robot.dart';

class GridWidget extends StatelessWidget {
  final Robot robot;
  final int targetX;
  final int targetY;
  final bool isWon;
  final List<List<bool>> walls;

  GridWidget({
    required this.robot,
    required this.targetX,
    required this.targetY,
    required this.isWon,
    required this.walls,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
          ),
          itemCount: 25,
          itemBuilder: (context, index) {
            int x = index % 5;
            int y = index ~/ 5;

            bool isRobotHere = robot.x == x && robot.y == y;
            bool isTargetHere = targetX == x && targetY == y;
            bool isWonCell = isWon && isTargetHere;
            bool isWallHere = walls[y][x];

            return Container(
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: isWonCell
                    ? Colors.green.shade400
                    : isTargetHere
                    ? Colors.red.shade400
                    : isWallHere
                    ? Colors.grey.shade600
                    : Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: isRobotHere
                  ? Center(
                      child: Transform.rotate(
                        angle: robot.getRotation(),
                        child: SvgPicture.asset(
                          'assets/robot.svg',
                          width: 60,
                          height: 60,
                        ),
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
