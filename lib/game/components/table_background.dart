import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TableBackground extends PositionComponent {
  final Sprite sprite;

  TableBackground({
    required this.sprite,
    required Vector2 size,
  }) : super(size: size);

  @override
  void render(Canvas canvas) {
    sprite.render(canvas, position: Vector2.zero(), size: size);
  }
}
