import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Import for ChangeNotifier

class AudioManager extends ChangeNotifier {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final Map<String, AudioPlayer> _effectPlayers = {};
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7; // Renamed _effectVolume to _sfxVolume for consistency

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> init() async {
    _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBackgroundMusic(String assetPath) async {
    if (kIsWeb) return;
    await _backgroundPlayer.setVolume(_musicVolume);
    await _backgroundPlayer.play(AssetSource(assetPath));
  }

  Future<void> playSoundEffect(dynamic assetPath, {double impactForce = 1.0}) async {
    if (kIsWeb) return;

    String selectedAssetPath;
    if (assetPath is List<String>) {
      selectedAssetPath = assetPath[DateTime.now().microsecondsSinceEpoch % assetPath.length];
    } else if (assetPath is String) {
      selectedAssetPath = assetPath;
    } else {
      throw ArgumentError('assetPath must be a String or a List<String>');
    }

    if (!_effectPlayers.containsKey(selectedAssetPath)) {
      _effectPlayers[selectedAssetPath] = AudioPlayer();
      _effectPlayers[selectedAssetPath]!.setReleaseMode(ReleaseMode.release);
    }
    final double scaledVolume = _sfxVolume * impactForce.clamp(0.2, 1.0); // Use _sfxVolume
    await _effectPlayers[selectedAssetPath]!.setVolume(scaledVolume);
    await _effectPlayers[selectedAssetPath]!.play(AssetSource(selectedAssetPath));
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    _backgroundPlayer.setVolume(_musicVolume);
    notifyListeners();
  }

  void setSfxVolume(double volume) { // Renamed setEffectVolume to setSfxVolume
    _sfxVolume = volume;
    for (var player in _effectPlayers.values) {
      player.setVolume(_sfxVolume);
    }
    notifyListeners();
  }

  void dispose() {
    _backgroundPlayer.dispose();
    for (var player in _effectPlayers.values) {
      player.dispose();
    }
    _effectPlayers.clear();
    super.dispose(); // Call super.dispose() for ChangeNotifier
  }
}
