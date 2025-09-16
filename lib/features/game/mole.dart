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
  }) : super(position: position, size: Vector2.all(80), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Circle
    _molePaint.color = const Color.fromARGB(255, 10, 94, 113);
    _moleCircle = CircleComponent(
      radius: size.x / 2,
      paint: _molePaint,
      anchor: Anchor.center,
      position: size / 2,
    );

    // Centered TextComponent inside circle
    double fontSize = 14;
    if (text.length > 6) fontSize = 12;
    if (text.length > 10) fontSize = 10;

    _textComponent = TextComponent(
      text: text,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  void popUp() {
    state = MoleState.visible;
    addAll([_moleCircle, _textComponent]);

    add(ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(duration: 0.2, curve: Curves.easeOutBack),
    ));
  }

  void reveal(bool isCorrect, bool wasTapped) {
    if (wasTapped) {
      _molePaint.color = isCorrect ? Colors.greenAccent : Colors.redAccent;
    } else if (isCorrect) {
      _molePaint.color = Colors.greenAccent;
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