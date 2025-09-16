import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:rural_learning_app/features/game/wack-a-mole-game.dart';


class WhackAMoleScreen extends StatefulWidget {
  const WhackAMoleScreen({super.key});

  @override
  State<WhackAMoleScreen> createState() => _WhackAMoleScreenState();
}

class _WhackAMoleScreenState extends State<WhackAMoleScreen> {
  final WhackAMoleGame _game = WhackAMoleGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // **FIX 1: Add an AppBar for the back button**
      appBar: AppBar(
        // Make the AppBar transparent to see the game behind it
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Add the back button icon
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // The action to perform when the button is pressed
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      // **FIX 2: Allow the game to draw behind the transparent AppBar**
      extendBodyBehindAppBar: true,
      body: GameWidget.controlled(
        gameFactory: () => _game,
        overlayBuilderMap: {
          'GameOver': (context, WhackAMoleGame game) {
            return Center(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
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