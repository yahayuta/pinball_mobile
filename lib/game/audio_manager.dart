import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
 // Import for ChangeNotifier

class AudioManager extends ChangeNotifier {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final List<AudioPlayer> _effectPlayerPool = [];
  static const int _maxEffectPlayers = 5; // Limit the number of concurrent effect players
  int _nextPlayerIndex = 0;

  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> init() async {
    _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
    for (int i = 0; i < _maxEffectPlayers; i++) {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.release);
      _effectPlayerPool.add(player);
    }
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

    // Get next available player from the pool
    final player = _effectPlayerPool[_nextPlayerIndex];
    _nextPlayerIndex = (_nextPlayerIndex + 1) % _maxEffectPlayers;

    final double scaledVolume = _sfxVolume * impactForce.clamp(0.2, 1.0);
    await player.setVolume(scaledVolume);
    await player.play(AssetSource(selectedAssetPath));
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    _backgroundPlayer.setVolume(_musicVolume);
    notifyListeners();
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume;
    for (var player in _effectPlayerPool) {
      player.setVolume(_sfxVolume);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose(); // Call super.dispose() as recommended by the analyzer
    _backgroundPlayer.dispose();
    for (var player in _effectPlayerPool) {
      player.dispose();
    }
    _effectPlayerPool.clear();
  }
}
