import 'package:flutter/material.dart';
import 'package:rural_learning_app/features/game/spelling_game.dart';
import 'package:rural_learning_app/features/game/wack-a-mole-screen.dart';
import 'package:rural_learning_app/features/game/abcgame.dart';
import 'package:rural_learning_app/robo/screens/splash_screen.dart';

class AppColors {
  static const gradientStart = Color(0xFFEFEFEF);
  static const gradientEnd = Color(0xFFBDBDBD);
  static const darkButton = Color(0xFF2E2E2E);
  static const textWhite = Colors.white;
  static const accentBlue = Color(0xFF6A8C99);
  static const darkGrey = Color(0xFF333333);
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: Stack(
          children: [
            // Bottom geometric mountains
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: const Size(double.infinity, 160),
                painter: MountainPainter(),
              ),
            ),

            // Foreground content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const SizedBox(height: 40),
                    // Big Home Icon
                    Icon(Icons.home, size: 80, color: AppColors.accentBlue),
                    const SizedBox(height: 16),
                    const Text(
                      "Dashboard",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const Spacer(),

                    // Buttons centered and redirecting to respective screens
                    MenuButton(
                      label: "SPELL THE SOUND",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SpellingGameScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    MenuButton(
                      label: "MAP IT",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SplashScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    MenuButton(
                      label: "WACK-A-MOLE",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WhackAMoleScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    MenuButton(
                      label: "STEM QUIZ",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ABCGame()),
                        );
                      },
                    ),

                    const Spacer(flex: 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for bottom shapes
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = const Color(0xFF333333);
    final paint2 = Paint()..color = const Color(0xFF6A8C99);
    final paint3 = Paint()..color = const Color(0xFF9E9E9E);

    // Left dark mountain
    final path1 = Path();
    path1.moveTo(0, size.height);
    path1.lineTo(size.width * 0.25, 0);
    path1.lineTo(size.width * 0.5, size.height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Middle blue mountainimport 'robo/screens/splash_screen.dart';

    final path2 = Path();
    path2.moveTo(size.width * 0.2, size.height);
    path2.lineTo(size.width * 0.5, 0);
    path2.lineTo(size.width * 0.8, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);

    // Right grey mountain
    final path3 = Path();
    path3.moveTo(size.width * 0.5, size.height);
    path3.lineTo(size.width * 0.75, 0);
    path3.lineTo(size.width, size.height);
    path3.close();
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Reusable button
class MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkButton,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
