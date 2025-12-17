import 'package:flutter/foundation.dart';
import 'dart:math';
import '../materials/material_data.dart';
import '../materials/material_inventory.dart';

/// Dungeon exploration session
class DungeonSession {
  final int depth;
  final DateTime startTime;
  final int durationSeconds;

  DungeonSession({
    required this.depth,
    required this.durationSeconds,
  }) : startTime = DateTime.now();

  bool get isComplete => DateTime.now().difference(startTime).inSeconds >= durationSeconds;

  double get progress {
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return (elapsed / durationSeconds).clamp(0.0, 1.0);
  }

  Duration get remainingTime {
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    final remaining = durationSeconds - elapsed;
    return Duration(seconds: remaining.clamp(0, durationSeconds));
  }
}

/// Dungeon exploration manager
class DungeonManager extends ChangeNotifier {
  final MaterialInventory _inventory;
  final Random _random = Random();

  DungeonSession? _activeSession;
  int _explorationLevel = 1;

  DungeonManager(this._inventory);

  DungeonSession? get activeSession => _activeSession;
  int get explorationLevel => _explorationLevel;

  /// Check if can start exploration
  bool canExplore() {
    return _activeSession == null || _activeSession!.isComplete;
  }

  /// Start dungeon exploration
  bool startExploration(int depth) {
    if (!canExplore()) return false;

    final duration = _getExplorationDuration(depth);
    _activeSession = DungeonSession(
      depth: depth,
      durationSeconds: duration,
    );

    notifyListeners();
    return true;
  }

  /// Get exploration duration based on depth
  int _getExplorationDuration(int depth) {
    switch (depth) {
      case 1:
        return 10; // 10 seconds for shallow
      case 2:
        return 20; // 20 seconds for medium
      case 3:
        return 30; // 30 seconds for deep
      default:
        return 10;
    }
  }

  /// Complete exploration and collect rewards
  Map<MaterialType, int> completeExploration() {
    if (_activeSession == null || !_activeSession!.isComplete) {
      return {};
    }

    final rewards = _calculateRewards(_activeSession!.depth);

    // Add materials to inventory
    for (final entry in rewards.entries) {
      _inventory.addMaterial(entry.key, entry.value.toDouble());
    }

    // Increase exploration level
    if (_activeSession!.depth >= _explorationLevel) {
      _explorationLevel = (_explorationLevel + 1).clamp(1, 3);
    }

    _activeSession = null;
    notifyListeners();

    return rewards;
  }

  /// Calculate rewards based on depth
  Map<MaterialType, int> _calculateRewards(int depth) {
    final rewards = <MaterialType, int>{};

    switch (depth) {
      case 1: // Shallow dungeon - basic materials
        rewards[MaterialType.ironOre] = 5 + _random.nextInt(5); // 5-10
        rewards[MaterialType.wood] = 5 + _random.nextInt(5); // 5-10
        if (_random.nextDouble() < 0.3) {
          rewards[MaterialType.leather] = 1 + _random.nextInt(3); // 1-3
        }
        break;

      case 2: // Medium dungeon - intermediate materials
        rewards[MaterialType.ironOre] = 10 + _random.nextInt(10); // 10-20
        rewards[MaterialType.wood] = 8 + _random.nextInt(8); // 8-16
        rewards[MaterialType.leather] = 3 + _random.nextInt(5); // 3-8
        if (_random.nextDouble() < 0.5) {
          rewards[MaterialType.magicStone] = 1 + _random.nextInt(2); // 1-2
        }
        break;

      case 3: // Deep dungeon - rare materials
        rewards[MaterialType.ironOre] = 15 + _random.nextInt(15); // 15-30
        rewards[MaterialType.wood] = 10 + _random.nextInt(10); // 10-20
        rewards[MaterialType.leather] = 5 + _random.nextInt(8); // 5-13
        rewards[MaterialType.magicStone] = 2 + _random.nextInt(3); // 2-5
        if (_random.nextDouble() < 0.2) {
          rewards[MaterialType.rareGem] = 1; // 20% chance for 1 gem
        }
        break;
    }

    return rewards;
  }

  /// Get dungeon info
  String getDungeonName(int depth) {
    switch (depth) {
      case 1:
        return '얕은 던전';
      case 2:
        return '중간 던전';
      case 3:
        return '깊은 던전';
      default:
        return '던전';
    }
  }

  String getDungeonDescription(int depth) {
    switch (depth) {
      case 1:
        return '초보자를 위한 쉬운 던전. 기본 재료를 얻을 수 있습니다.';
      case 2:
        return '숙련자를 위한 던전. 고급 재료가 등장합니다.';
      case 3:
        return '전문가를 위한 위험한 던전. 희귀 재료를 발견할 수 있습니다.';
      default:
        return '';
    }
  }

  /// Check if depth is unlocked
  bool isDepthUnlocked(int depth) {
    return depth <= _explorationLevel;
  }

  /// Update active session (call in game loop)
  void update() {
    if (_activeSession != null && _activeSession!.isComplete) {
      notifyListeners();
    }
  }

  /// Cancel active exploration
  void cancelExploration() {
    _activeSession = null;
    notifyListeners();
  }
}
