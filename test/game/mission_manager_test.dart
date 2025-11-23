import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pinball_mobile/game/mission_manager.dart';
import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:pinball_mobile/game/audio_manager.dart';
import 'package:flame/game.dart';

class MockPinballGame extends Mock implements PinballGame {}
class MockAudioManager extends Mock implements AudioManager {}

class FakeVector2 extends Fake implements Vector2 {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeVector2());
  });

  group('MissionManager', () {
    late MissionManager missionManager;
    late MockPinballGame mockGame;
    late MockAudioManager mockAudioManager;

    setUp(() {
      mockGame = MockPinballGame();
      mockAudioManager = MockAudioManager();
      when(() => mockGame.audioManager).thenReturn(mockAudioManager);
      when(() => mockGame.size).thenReturn(Vector2.zero());
      when(() => mockGame.addScore(any(), any())).thenReturn(null);
      when(() => mockAudioManager.playSoundEffect(any(), impactForce: any(named: 'impactForce'))).thenAnswer((_) async {});
      
      missionManager = MissionManager(mockGame);
    });

    test('Mission starts and completes correctly', () {
      final mission = Mission(
        id: 'test_mission',
        title: 'Test Mission',
        description: 'Test',
        type: MissionType.collection,
        scoreReward: 1000,
        requiredTargetIds: ['target_1', 'target_2'],
      );

      missionManager.addMission(mission);
      missionManager.startMission('test_mission');

      expect(missionManager.currentMission, isNotNull);
      expect(missionManager.currentMission!.status, MissionStatus.active);

      missionManager.onObjectHit('target_1');
      expect(missionManager.currentMission!.status, MissionStatus.active);
      expect(missionManager.currentMission!.progress, 0.5);

      missionManager.onObjectHit('target_2');
      missionManager.update(0.1); // Update to trigger completion logic

      expect(missionManager.currentMission, isNull); // Should be cleared after completion
      verify(() => mockGame.addScore(1000, any())).called(1);
    });

    test('Sequence mission enforces order', () {
      final mission = Mission(
        id: 'sequence_mission',
        title: 'Sequence Mission',
        description: 'Test',
        type: MissionType.sequence,
        scoreReward: 1000,
        requiredTargetIds: ['1', '2', '3'],
      );

      missionManager.addMission(mission);
      missionManager.startMission('sequence_mission');

      // Wrong order
      missionManager.onObjectHit('2');
      expect(missionManager.currentMission!.progress, 0.0);

      // Correct order
      missionManager.onObjectHit('1');
      expect(missionManager.currentMission!.progress, 1/3);

      missionManager.onObjectHit('2');
      expect(missionManager.currentMission!.progress, 2/3);
      
      missionManager.onObjectHit('3');
      missionManager.update(0.1);
      
      expect(missionManager.currentMission, isNull);
      verify(() => mockGame.addScore(1000, any())).called(1);
    });
  });
}
