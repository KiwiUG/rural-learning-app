import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'wack-a-mole-game.dart';

class WhackAMoleScreen extends StatelessWidget {
  const WhackAMoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GameWidget(
        game: WhackAMoleGame(),
        overlayBuilderMap: {
          'GameOver': (context, WhackAMoleGame game) {
            return Center(
              child: Container(
                color: Colors.black54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Game Over!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        game.restart();
                      },
                      child: const Text("Play Again"),
                    ),
                  ],
                ),
              ),
            );
          },
        },
      ),
    );
  }
}