import 'package:flutter/material.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

class GameProvider extends ChangeNotifier {
  PinballGame? _game;

  PinballGame? get game => _game;

  void setGame(PinballGame game) {
    _game = game;
    notifyListeners();
  }
}
