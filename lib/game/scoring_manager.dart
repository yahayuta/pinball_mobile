import 'package:pinball_mobile/game/pinball_game.dart';
import 'package:pinball_mobile/game/components/visual_effects.dart';

/// Manages scoring bonuses, combos, and multipliers for the pinball game
class ScoringManager {
  final PinballGame game;
  
  // Combo tracking
  int _comboCount = 0;
  double _lastHitTime = 0.0;
  static const double _comboTimeWindow = 2.0; // seconds
  
  // Lane completion tracking
  final Set<int> _topLanesHit = {};
  final Set<int> _dropTargetsHit = {};
  
  // Multiplier tracking
  int _scoreMultiplier = 1;
  double _multiplierEndTime = 0.0;
  
  // Skill shot tracking
  bool _skillShotAvailable = true;
  
  ScoringManager(this.game);
  
  /// Update combo timer
  void update(double dt, double currentTime) {
    // Reset combo if too much time has passed
    if (currentTime - _lastHitTime > _comboTimeWindow && _comboCount > 0) {
      _comboCount = 0;
    }
    
    // Reset multiplier if expired
    if (currentTime > _multiplierEndTime && _scoreMultiplier > 1) {
      _scoreMultiplier = 1;
    }
  }
  
  /// Register a hit and update combo
  void registerHit(double currentTime) {
    if (currentTime - _lastHitTime <= _comboTimeWindow) {
      _comboCount++;
    } else {
      _comboCount = 1;
    }
    _lastHitTime = currentTime;
  }
  
  /// Get current combo multiplier
  int getComboMultiplier() {
    if (_comboCount >= 10) return 5;
    if (_comboCount >= 7) return 4;
    if (_comboCount >= 5) return 3;
    if (_comboCount >= 3) return 2;
    return 1;
  }
  
  /// Register top lane hit
  void hitTopLane(int laneIndex) {
    _topLanesHit.add(laneIndex);
    if (_topLanesHit.length == 4) {
      // All lanes completed!
      completeLaneBonus();
    }
  }
  
  /// Register drop target hit
  void hitDropTarget(int targetIndex) {
    _dropTargetsHit.add(targetIndex);
    if (_dropTargetsHit.length == 5) {
      // All drop targets completed!
      completeDropTargetBank();
    }
  }
  
  /// Complete lane bonus
  void completeLaneBonus() {
    final bonus = 5000 * _scoreMultiplier;
    game.addScore(bonus, game.size / 2);
    game.audioManager.playSoundEffect('audio/lane_complete.mp3', impactForce: 1.0);
    game.add(LaneCompletionEffect(
      position: game.size / 2,
      message: 'LANES COMPLETE!',
    ));
    _topLanesHit.clear();
    
    // Activate 2x multiplier for 10 seconds
    activateMultiplier(2, 10.0);
  }
  
  /// Complete drop target bank
  void completeDropTargetBank() {
    final bonus = 10000 * _scoreMultiplier;
    game.addScore(bonus, game.size / 2);
    game.audioManager.playSoundEffect('audio/lane_complete.mp3', impactForce: 1.0);
    game.add(LaneCompletionEffect(
      position: game.size / 2,
      message: 'TARGETS COMPLETE!',
    ));
    _dropTargetsHit.clear();
    
    // Activate 3x multiplier for 15 seconds
    activateMultiplier(3, 15.0);
  }
  
  /// Activate score multiplier
  void activateMultiplier(int multiplier, double duration) {
    _scoreMultiplier = multiplier;
    _multiplierEndTime = _lastHitTime + duration;
    game.add(MultiplierEffect(
      position: game.size / 2,
      multiplier: multiplier,
    ));
  }
  
  /// Award skill shot
  void awardSkillShot() {
    if (_skillShotAvailable) {
      final bonus = 5000;
      game.addScore(bonus, game.size / 2);
      game.audioManager.playSoundEffect('audio/skill_shot.mp3', impactForce: 1.0);
      game.add(SkillShotEffect(
        position: game.size / 2,
      ));
      _skillShotAvailable = false;
    }
  }
  
  /// Reset skill shot availability (call when ball is launched)
  void resetSkillShot() {
    _skillShotAvailable = true;
  }
  
  /// Get current score multiplier
  int get scoreMultiplier => _scoreMultiplier;
  
  /// Get current combo count
  int get comboCount => _comboCount;
  
  /// Get top lanes completion progress
  String get topLanesProgress => '${_topLanesHit.length}/4';
  
  /// Get drop targets completion progress
  String get dropTargetsProgress => '${_dropTargetsHit.length}/5';
  
  /// Check if skill shot is available
  bool get isSkillShotAvailable => _skillShotAvailable;
  
  /// Reset all bonuses (call on ball lost)
  void reset() {
    _comboCount = 0;
    _lastHitTime = 0.0;
    _scoreMultiplier = 1;
    _multiplierEndTime = 0.0;
    // Don't reset lane/target progress - keep between balls
  }
  
  /// Full reset (call on game over)
  void fullReset() {
    reset();
    _topLanesHit.clear();
    _dropTargetsHit.clear();
    _skillShotAvailable = true;
  }
}
