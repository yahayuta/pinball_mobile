import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager with ChangeNotifier {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal();

  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final Map<String, AudioPlayer> _effectPlayers = {};
  double _musicVolume = 0.5;
  double _effectVolume = 0.7;

  double get musicVolume => _musicVolume;
  double get sfxVolume => _effectVolume;

  Future<void> init() async {
    _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBackgroundMusic(String assetPath) async {
    await _backgroundPlayer.setVolume(_musicVolume);
    await _backgroundPlayer.play(AssetSource(assetPath));
  }

  Future<void> playSoundEffect(dynamic assetPath, {double impactForce = 1.0}) async {

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
    final double scaledVolume = _effectVolume * impactForce.clamp(0.2, 1.0);
    await _effectPlayers[selectedAssetPath]!.setVolume(scaledVolume);
    await _effectPlayers[selectedAssetPath]!.play(AssetSource(selectedAssetPath));
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    _backgroundPlayer.setVolume(_musicVolume);
    notifyListeners();
  }

  void setSfxVolume(double volume) {
    _effectVolume = volume;
    for (var player in _effectPlayers.values) {
      player.setVolume(_effectVolume);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _backgroundPlayer.dispose();
    for (var player in _effectPlayers.values) {
      player.dispose();
    }
    _effectPlayers.clear();
    super.dispose();
  }
}
