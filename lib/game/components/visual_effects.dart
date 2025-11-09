import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';

class BumperHitEffect extends ParticleSystemComponent {
  BumperHitEffect({required Vector2 position, required Color color})
    : super(
        position: position,
        particle: Particle.generate(
          count: 10,
          lifespan: 0.5,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 100),
            speed: Vector2.random() * 100,
            position: Vector2.zero(),
            child: CircleParticle(
              radius: 2,
              paint: Paint()..color = color.withAlpha((255 * 0.5).toInt()),
            ),
          ),
        ),
      );
}

class ScorePopup extends TextComponent {
  double _opacity = 1.0;
  final double _fadeDuration = 0.5;
  double _elapsedTime = 0.0;

  ScorePopup({
    required Vector2 position,
    required int score,
    required int combo,
  }) : super(
         text: '+${score * (combo + 1)}',
         position: position,
         textRenderer: TextPaint(
           style: TextStyle(
             color: Colors.yellow,
             fontSize: 16,
             fontWeight: FontWeight.bold,
           ),
         ),
       ) {
    // Initial position and scale effects
    add(MoveEffect.by(Vector2(0, -50), EffectController(duration: _fadeDuration)));
    add(ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.2)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;
    if (_elapsedTime < _fadeDuration) {
      _opacity = 1.0 - (_elapsedTime / _fadeDuration);
      textRenderer = TextPaint(
        style: (textRenderer as TextPaint).style.copyWith(
          color: (textRenderer as TextPaint).style.color!.withOpacity(_opacity),
        ),
      );
    } else {
      removeFromParent();
    }
  }
}

class ComboEffect extends TextComponent {
  double _opacity = 1.0;
  final double _fadeDuration = 0.5;
  double _elapsedTime = 0.0;
  final double _startDelay = 0.5;

  ComboEffect({required Vector2 position, required int combo})
    : super(
        text: '${combo}x COMBO!',
        position: position,
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.orange,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ) {
    add(
      ScaleEffect.by(
        Vector2.all(1.5),
        EffectController(duration: 0.2, reverseDuration: 0.2),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;
    if (_elapsedTime > _startDelay) {
      final currentFadeTime = _elapsedTime - _startDelay;
      if (currentFadeTime < _fadeDuration) {
        _opacity = 1.0 - (currentFadeTime / _fadeDuration);
        textRenderer = TextPaint(
          style: (textRenderer as TextPaint).style.copyWith(
            color: (textRenderer as TextPaint).style.color!.withOpacity(_opacity),
          ),
        );
      } else {
        removeFromParent();
      }
    }
  }
}