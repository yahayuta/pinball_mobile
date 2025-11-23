import 'package:flutter/foundation.dart';
import 'package:pinball_mobile/game/pinball_game.dart';

enum MissionType {
  sequence,
  collection,
  timed,
}

enum MissionStatus {
  inactive,
  active,
  completed,
  failed,
}

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int scoreReward;
  final Duration? timeLimit;
  final List<String> requiredTargetIds;
  
  // State
  MissionStatus status = MissionStatus.inactive;
  final Set<String> _hitTargets = {};
  DateTime? _startTime;
  int _currentSequenceIndex = 0;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.scoreReward,
    required this.requiredTargetIds,
    this.timeLimit,
  });

  void start() {
    status = MissionStatus.active;
    _hitTargets.clear();
    _currentSequenceIndex = 0;
    _startTime = DateTime.now();
  }

  void update(double dt) {
    if (status != MissionStatus.active) return;

    if (timeLimit != null && _startTime != null) {
      final elapsed = DateTime.now().difference(_startTime!);
      if (elapsed > timeLimit!) {
        status = MissionStatus.failed;
      }
    }
  }

  bool onTargetHit(String targetId) {
    if (status != MissionStatus.active) return false;

    if (!requiredTargetIds.contains(targetId)) return false;

    switch (type) {
      case MissionType.collection:
        if (!_hitTargets.contains(targetId)) {
          _hitTargets.add(targetId);
          if (_hitTargets.length == requiredTargetIds.length) {
            complete();
            return true;
          }
        }
        break;
      case MissionType.sequence:
        if (requiredTargetIds[_currentSequenceIndex] == targetId) {
          _currentSequenceIndex++;
          if (_currentSequenceIndex >= requiredTargetIds.length) {
            complete();
            return true;
          }
        } else {
          // Reset sequence on wrong hit? Or just ignore?
          // For now, let's just ignore wrong hits in sequence to be forgiving
        }
        break;
      case MissionType.timed:
        // Timed missions usually involve hitting things enough times or specific things
        // For simplicity, treating timed like collection but with a timer
        if (!_hitTargets.contains(targetId)) {
          _hitTargets.add(targetId);
          if (_hitTargets.length == requiredTargetIds.length) {
            complete();
            return true;
          }
        }
        break;
    }
    return false;
  }

  void complete() {
    status = MissionStatus.completed;
  }

  void reset() {
    status = MissionStatus.inactive;
    _hitTargets.clear();
    _currentSequenceIndex = 0;
    _startTime = null;
  }

  double get progress {
    if (requiredTargetIds.isEmpty) return 0.0;
    switch (type) {
      case MissionType.collection:
      case MissionType.timed:
        return _hitTargets.length / requiredTargetIds.length;
      case MissionType.sequence:
        return _currentSequenceIndex / requiredTargetIds.length;
    }
  }
}

class MissionManager {
  final PinballGame game;
  final List<Mission> missions = [];
  Mission? currentMission;

  MissionManager(this.game);

  void addMission(Mission mission) {
    missions.add(mission);
  }

  void startMission(String missionId) {
    final mission = missions.firstWhere((m) => m.id == missionId, orElse: () => throw Exception('Mission not found'));
    if (currentMission != null && currentMission!.status == MissionStatus.active) {
      // Optional: Queue missions or cancel current?
      // For now, ignore if busy
      return;
    }
    currentMission = mission;
    currentMission!.start();
    game.audioManager.playSoundEffect('audio/mission_start.mp3', impactForce: 1.0);
    // Show HUD message
    debugPrint('Mission Started: ${mission.title}');
  }

  void update(double dt) {
    if (currentMission != null) {
      currentMission!.update(dt);
      if (currentMission!.status == MissionStatus.completed) {
        _onMissionComplete(currentMission!);
        currentMission = null;
      } else if (currentMission!.status == MissionStatus.failed) {
        _onMissionFailed(currentMission!);
        currentMission = null;
      }
    }
  }

  void onObjectHit(String objectId) {
    if (currentMission != null) {
      currentMission!.onTargetHit(objectId);
    }
  }

  void _onMissionComplete(Mission mission) {
    game.addScore(mission.scoreReward, game.size / 2);
    game.audioManager.playSoundEffect('audio/mission_complete.mp3', impactForce: 1.0);
    debugPrint('Mission Complete: ${mission.title}');
    // Trigger visual effects
  }

  void _onMissionFailed(Mission mission) {
    game.audioManager.playSoundEffect('audio/mission_fail.mp3', impactForce: 1.0);
    debugPrint('Mission Failed: ${mission.title}');
  }
}
