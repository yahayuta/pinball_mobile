import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final Map<String, AudioPlayer> _effectPlayers = {};
  double _musicVolume = 0.5;
  double _effectVolume = 0.7;

  Future<void> init() async {
    _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBackgroundMusic(String assetPath) async {
    if (kIsWeb) return;
    await _backgroundPlayer.setVolume(_musicVolume);
    await _backgroundPlayer.play(AssetSource(assetPath));
  }

  Future<void> playSoundEffect(String assetPath, {double impactForce = 1.0}) async {
    if (kIsWeb) return;
    if (!_effectPlayers.containsKey(assetPath)) {
      _effectPlayers[assetPath] = AudioPlayer();
      _effectPlayers[assetPath]!.setReleaseMode(ReleaseMode.release);
    }
    final double scaledVolume = _effectVolume * impactForce.clamp(0.2, 1.0);
    await _effectPlayers[assetPath]!.setVolume(scaledVolume);
    await _effectPlayers[assetPath]!.play(AssetSource(assetPath));
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    _backgroundPlayer.setVolume(_musicVolume);
  }

  void setEffectVolume(double volume) {
    _effectVolume = volume;
    for (var player in _effectPlayers.values) {
      player.setVolume(_effectVolume);
    }
  }

  void dispose() {
    _backgroundPlayer.dispose();
    for (var player in _effectPlayers.values) {
      player.dispose();
    }
    _effectPlayers.clear();
  }
}
