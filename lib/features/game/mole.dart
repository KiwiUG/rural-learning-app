import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

enum MoleState { hidden, visible }

class Mole extends PositionComponent with TapCallbacks {
  final String text;
  final VoidCallback onTap;
  MoleState state = MoleState.hidden;

  late final CircleComponent _moleCircle;
  late final TextComponent _textComponent;
  final Paint _molePaint = Paint();

  Mole({
    required this.text,
    required this.onTap,
    required Vector2 position,
    required double diameter,
  }) : super(
          position: position,
          size: Vector2.all(diameter),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    _molePaint.color = const Color.fromARGB(255, 10, 94, 113);

    _moleCircle = CircleComponent(
      radius: size.x / 2,
      paint: _molePaint,
      anchor: Anchor.center,
      position: size / 2,
    );

    // Dynamically adjust font size based on text length and mole size
    double baseFontSize = size.x * 0.25;
    if (text.length > 6) baseFontSize *= 0.7;
    if (text.length > 10) baseFontSize *= 0.8;

    _textComponent = TextComponent(
      text: text,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: baseFontSize,
        ),
      ),
    );

    // Pop-up animation logic
    state = MoleState.visible;
    scale = Vector2.zero(); // Start scaled down
    addAll([_moleCircle, _textComponent]);
    add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: 0.25, curve: Curves.easeOutBack),
    ));
  }

  void reveal(bool isCorrect, bool wasTapped) {
    if (wasTapped) {
      _molePaint.color = isCorrect ? Colors.greenAccent : Colors.redAccent;
    } else if (isCorrect) {
      _molePaint.color = Colors.greenAccent;
      // Add a slight "pulse" effect to highlight the correct answer
      add(ScaleEffect.to(
        Vector2.all(1.1),
        EffectController(duration: 0.15, alternate: true, repeatCount: 2),
      ));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (state == MoleState.visible) {
      onTap();
    }
  }
}