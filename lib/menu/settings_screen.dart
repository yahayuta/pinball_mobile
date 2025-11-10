import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/audio_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audio',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  'Music Volume:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Expanded(
                  child: Slider(
                    value: audioManager.musicVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      audioManager.setMusicVolume(value);
                    },
                  ),
                ),
                Text(
                  (audioManager.musicVolume * 100).toInt().toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'SFX Volume:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Expanded(
                  child: Slider(
                    value: audioManager.sfxVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      audioManager.setSfxVolume(value);
                    },
                  ),
                ),
                Text(
                  (audioManager.sfxVolume * 100).toInt().toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
