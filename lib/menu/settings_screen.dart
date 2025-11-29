import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
import 'package:pinball_mobile/menu/menu_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/menu_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.7),
          ),
          Column(
            children: [
              AppBar(
                title: Text('SETTINGS', style: GameMenuTheme.titleStyle.copyWith(fontSize: 28)),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: GameMenuTheme.primaryColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AUDIO',
                        style: GameMenuTheme.buttonTextStyle.copyWith(color: GameMenuTheme.secondaryColor),
                      ),
                      const SizedBox(height: 20),
                      _buildSlider(
                        'Music Volume',
                        audioManager.musicVolume,
                        (value) => audioManager.setMusicVolume(value),
                      ),
                      const SizedBox(height: 20),
                      _buildSlider(
                        'SFX Volume',
                        audioManager.sfxVolume,
                        (value) => audioManager.setSfxVolume(value),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GameMenuTheme.bodyTextStyle.copyWith(fontSize: 18),
            ),
            Text(
              (value * 100).toInt().toString(),
              style: GameMenuTheme.bodyTextStyle.copyWith(fontSize: 18, color: GameMenuTheme.primaryColor),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: GameMenuTheme.primaryColor,
            inactiveTrackColor: Colors.grey[800],
            thumbColor: GameMenuTheme.secondaryColor,
            overlayColor: GameMenuTheme.secondaryColor.withValues(alpha: 0.2),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
