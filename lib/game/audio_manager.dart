import 'package:audioplayers/audioplayers.dart';

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
    await _backgroundPlayer.setVolume(_musicVolume);
    await _backgroundPlayer.play(AssetSource(assetPath));
  }

  Future<void> playSoundEffect(String assetPath) async {
    if (!_effectPlayers.containsKey(assetPath)) {
      _effectPlayers[assetPath] = AudioPlayer();
      _effectPlayers[assetPath]!.setReleaseMode(ReleaseMode.release);
    }
    await _effectPlayers[assetPath]!.setVolume(_effectVolume);
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
