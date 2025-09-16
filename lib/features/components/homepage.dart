import 'package:flutter/material.dart';
import 'dashboard.dart';

class AppColors {
  static const background = Color(0xFFF2F2F2);
  static const accentBlue = Color(0xFF6A8C99);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1E1E1E);
  static const alertRed = Color(0xFFFF3B30);
}

class HomePage extends StatelessWidget {
  final int xp;
  final int level;
  final int xpForNextLevel;

  const HomePage({
    super.key,
    required this.xp,
    required this.level,
    required this.xpForNextLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background shapes
          Positioned(
            top: 100,
            left: -60,
            right: -60,
            child: Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0xFFE6E6E6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(painter: DiagonalPainter()),
          ),
          // Foreground content
          LayoutBuilder(
            builder: (context, constraints) {
              final topOffset = constraints.maxHeight * 0.20;
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top: topOffset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile section centered
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.alertRed,
                              child: const Icon(
                                Icons.person,
                                size: 44,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "THOMAS",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Level: $level",
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Badge below level
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amberAccent.shade700,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "$xp / $xpForNextLevel XP",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      // Menu Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            MenuButton(
                              icon: Icons.dashboard_outlined,
                              label: "GAMES",
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 15),
                            MenuButton(
                              icon: Icons.leaderboard_outlined,
                              label: "LEADERBOARD",
                              onPressed: () {},
                            ),
                            const SizedBox(height: 15),
                            MenuButton(
                              icon: Icons.emoji_events_outlined,
                              label: "BADGES",
                              onPressed: () {},
                            ),
                            const SizedBox(height: 15),
                            MenuButton(
                              icon: Icons.card_giftcard_outlined,
                              label: "REWARDS",
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Painter for the diagonal blue shape
class DiagonalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentBlue
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.6, 0);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width * 0.6, size.height);
    path.lineTo(size.width * 0.3, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Reusable Menu Button
class MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const MenuButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardWhite,
          foregroundColor: AppColors.textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.accentBlue),
          ),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.15),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 14,
          ),
        ),
        icon: Icon(icon, color: AppColors.textDark),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }
}
