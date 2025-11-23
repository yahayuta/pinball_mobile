import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';

class FadingCircleParticle extends Particle {
  FadingCircleParticle({
    required this.color,
    required this.radius,
    super.lifespan,
  });

  final Color color;
  final double radius;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color.withAlpha(((1.0 - progress) * 255).toInt())
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius, paint);
  }
}

class BumperHitEffect extends ParticleSystemComponent {
  BumperHitEffect({required Vector2 position, required Color color})
    : super(
        position: position,
        particle: Particle.generate(
          count: 20,
          lifespan: 0.5,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 0),
            speed: (Vector2.random() - Vector2.all(0.5)) * 200,
            position: Vector2.zero(),
            child: FadingCircleParticle(
              radius: 2,
              color: color,
              lifespan: 0.5,
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
           style: const TextStyle(
             color: Colors.yellow,
             fontSize: 16,
             fontWeight: FontWeight.bold,
           ),
         ),
       ) {
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
          color: (textRenderer as TextPaint).style.color!.withAlpha((_opacity * 255).toInt()),
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
          style: const TextStyle(
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
            color: (textRenderer as TextPaint).style.color!.withAlpha((_opacity * 255).toInt()),
          ),
        );
      } else {
        removeFromParent();
      }
    }
  }
}

class LaneCompletionEffect extends TextComponent {
  double _opacity = 1.0;
  final double _duration = 1.5;
  double _elapsedTime = 0.0;

  LaneCompletionEffect({required Vector2 position, required String message})
    : super(
        text: message,
        position: position,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.cyan,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ) {
    add(ScaleEffect.by(Vector2.all(1.3), EffectController(duration: 0.3, reverseDuration: 0.3)));
    add(MoveEffect.by(Vector2(0, -30), EffectController(duration: _duration)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;
    if (_elapsedTime < _duration) {
      _opacity = 1.0 - (_elapsedTime / _duration);
      textRenderer = TextPaint(
        style: (textRenderer as TextPaint).style.copyWith(
          color: (textRenderer as TextPaint).style.color!.withAlpha((_opacity * 255).toInt()),
        ),
      );
    } else {
      removeFromParent();
    }
  }
}

class MultiplierEffect extends TextComponent {
  double _opacity = 1.0;
  final double _duration = 2.0;
  double _elapsedTime = 0.0;

  MultiplierEffect({required Vector2 position, required int multiplier})
    : super(
        text: '${multiplier}X MULTIPLIER!',
        position: position,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.orange, blurRadius: 10)],
          ),
        ),
      ) {
    add(ScaleEffect.by(Vector2.all(1.5), EffectController(duration: 0.4, reverseDuration: 0.4)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;
    if (_elapsedTime < _duration) {
      _opacity = 1.0 - (_elapsedTime / _duration);
      textRenderer = TextPaint(
        style: (textRenderer as TextPaint).style.copyWith(
          color: (textRenderer as TextPaint).style.color!.withAlpha((_opacity * 255).toInt()),
        ),
      );
    } else {
      removeFromParent();
    }
  }
}

class SkillShotEffect extends TextComponent {
  double _opacity = 1.0;
  final double _duration = 1.5;
  double _elapsedTime = 0.0;

  SkillShotEffect({required Vector2 position})
    : super(
        text: 'SKILL SHOT!',
        position: position,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.red, blurRadius: 15)],
          ),
        ),
      ) {
    add(ScaleEffect.by(Vector2.all(2.0), EffectController(duration: 0.5, reverseDuration: 0.5)));
    add(MoveEffect.by(Vector2(0, -50), EffectController(duration: _duration)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedTime += dt;
    if (_elapsedTime < _duration) {
      _opacity = 1.0 - (_elapsedTime / _duration);
      textRenderer = TextPaint(
        style: (textRenderer as TextPaint).style.copyWith(
          color: (textRenderer as TextPaint).style.color!.withAlpha((_opacity * 255).toInt()),
        ),
      );
    } else {
      removeFromParent();
    }
  }
}