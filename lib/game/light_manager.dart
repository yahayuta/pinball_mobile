import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/components/pinball_light.dart';

class LightManager extends Component {
  final Map<String, PinballLight> _lights = {};

  void registerLight(String id, PinballLight light) {
    _lights[id] = light;
  }

  void turnOn(String id, {Color? color}) {
    _lights[id]?.turnOn(color: color);
  }

  void turnOff(String id) {
    _lights[id]?.turnOff();
  }

  void blink(String id, {Duration duration = const Duration(milliseconds: 500), Color? color}) {
    _lights[id]?.blink(duration: duration, color: color);
  }

  void pulse(String id, {Duration duration = const Duration(milliseconds: 1000), Color? color}) {
    _lights[id]?.pulse(duration: duration, color: color);
  }

  void allOff() {
    for (final light in _lights.values) {
      light.turnOff();
    }
  }

  void allOn({Color? color}) {
    for (final light in _lights.values) {
      light.turnOn(color: color);
    }
  }
  
  PinballLight? getLight(String id) => _lights[id];
}
