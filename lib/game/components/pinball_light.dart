import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum LightShape {
  circle,
  arrow,
  triangle,
  rect,
}

enum LightState {
  off,
  on,
  blinking,
  pulsing,
}

class PinballLight extends PositionComponent {
  final String id;
  final LightShape shape;
  final Color defaultColor;
  
  LightState _state = LightState.off;
  Color _currentColor;
  double _opacity = 0.5; // Dim when off
  
  // Blinking/Pulsing state
  double _timer = 0.0;
  double _blinkDuration = 0.5;
  double _pulseDuration = 1.0;
  bool _blinkOn = false;

  PinballLight({
    required this.id,
    required Vector2 position,
    required Vector2 size,
    this.shape = LightShape.circle,
    this.defaultColor = Colors.yellow,
  }) : _currentColor = defaultColor,
       super(position: position, size: size, anchor: Anchor.center, priority: 10); // Higher priority than background

  void turnOn({Color? color}) {
    _state = LightState.on;
    _currentColor = color ?? defaultColor;
    _opacity = 1.0;
  }

  void turnOff() {
    _state = LightState.off;
    _opacity = 0.5;
  }

  void blink({Duration duration = const Duration(milliseconds: 500), Color? color}) {
    _state = LightState.blinking;
    _blinkDuration = duration.inMilliseconds / 1000.0;
    _currentColor = color ?? defaultColor;
    _timer = 0.0;
    _blinkOn = true;
    _opacity = 1.0;
  }

  void pulse({Duration duration = const Duration(milliseconds: 1000), Color? color}) {
    _state = LightState.pulsing;
    _pulseDuration = duration.inMilliseconds / 1000.0;
    _currentColor = color ?? defaultColor;
    _timer = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_state == LightState.blinking) {
      _timer += dt;
      if (_timer >= _blinkDuration) {
        _timer = 0.0;
        _blinkOn = !_blinkOn;
        _opacity = _blinkOn ? 1.0 : 0.5;
      }
    } else if (_state == LightState.pulsing) {
      _timer += dt;
      final t = (_timer % _pulseDuration) / _pulseDuration;
      // Sine wave for pulsing
      _opacity = 0.5 + 0.5 * (0.5 * (1 + sin(t * 6.28))); // 0.5 to 1.0
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw glow
    if (_state != LightState.off) {
      final glowPaint = Paint()
        ..color = _currentColor.withValues(alpha: _opacity * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      switch (shape) {
        case LightShape.circle:
          canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.8, glowPaint);
          break;
        case LightShape.rect:
          canvas.drawRect(size.toRect().inflate(4), glowPaint);
          break;
        case LightShape.triangle:
        case LightShape.arrow:
          // Simplified glow for complex shapes
          canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.8, glowPaint);
          break;
      }
    }

    final paint = Paint()
      ..color = _currentColor.withAlpha((_opacity * 255).toInt())
      ..style = PaintingStyle.fill;

    switch (shape) {
      case LightShape.circle:
        canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
        break;
      case LightShape.rect:
        canvas.drawRect(size.toRect(), paint);
        break;
      case LightShape.triangle:
        final path = Path()
          ..moveTo(size.x / 2, 0)
          ..lineTo(size.x, size.y)
          ..lineTo(0, size.y)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case LightShape.arrow:
        final path = Path()
          ..moveTo(size.x / 2, 0)
          ..lineTo(size.x, size.y * 0.6)
          ..lineTo(size.x * 0.7, size.y * 0.6)
          ..lineTo(size.x * 0.7, size.y)
          ..lineTo(size.x * 0.3, size.y)
          ..lineTo(size.x * 0.3, size.y * 0.6)
          ..lineTo(0, size.y * 0.6)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
    
    // Draw border/housing
    final borderPaint = Paint()
      ..color = Colors.black.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
     switch (shape) {
      case LightShape.circle:
        canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, borderPaint);
        break;
      case LightShape.rect:
        canvas.drawRect(size.toRect(), borderPaint);
        break;
      case LightShape.triangle:
        final path = Path()
          ..moveTo(size.x / 2, 0)
          ..lineTo(size.x, size.y)
          ..lineTo(0, size.y)
          ..close();
        canvas.drawPath(path, borderPaint);
        break;
      case LightShape.arrow:
        final path = Path()
          ..moveTo(size.x / 2, 0)
          ..lineTo(size.x, size.y * 0.6)
          ..lineTo(size.x * 0.7, size.y * 0.6)
          ..lineTo(size.x * 0.7, size.y)
          ..lineTo(size.x * 0.3, size.y)
          ..lineTo(size.x * 0.3, size.y * 0.6)
          ..lineTo(0, size.y * 0.6)
          ..close();
        canvas.drawPath(path, borderPaint);
        break;
    }
  }
}
