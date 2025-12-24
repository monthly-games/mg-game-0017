import 'package:flutter/foundation.dart';
import 'dart:math';
import '../materials/material_data.dart';
import '../materials/material_inventory.dart';
import '../upgrades/upgrade_manager.dart';

/// Dungeon exploration session
class DungeonSession {
  final int depth;
  final DateTime startTime;
  final int durationSeconds;

  DungeonSession({required this.depth, required this.durationSeconds})
    : startTime = DateTime.now();

  bool get isComplete =>
      DateTime.now().difference(startTime).inSeconds >= durationSeconds;

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
  final UpgradeManager _upgrades;
  final Random _random = Random();

  DungeonSession? _activeSession;
  int _explorationLevel = 1;

  DungeonManager(this._inventory, this._upgrades);

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
    _activeSession = DungeonSession(depth: depth, durationSeconds: duration);

    notifyListeners();
    return true;
  }

  // Use speed upgrade
  int _getExplorationDuration(int depth) {
    int baseDuration;
    switch (depth) {
      case 1:
        baseDuration = 10;
        break;
      case 2:
        baseDuration = 20;
        break;
      case 3:
        baseDuration = 30;
        break;
      default:
        baseDuration = 10;
    }
    // Apply speed multiplier: Duration / Multiplier
    return (baseDuration / _upgrades.speedMultiplier).round();
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
      case 1: // Shallow Forest
        rewards[MaterialType.wood] = 5 + _random.nextInt(10);
        rewards[MaterialType.herb] = 3 + _random.nextInt(5);
        if (_random.nextDouble() < 0.5) {
          rewards[MaterialType.root] = 2 + _random.nextInt(3);
        }
        if (_random.nextDouble() < 0.3) {
          rewards[MaterialType.copper] = 1 + _random.nextInt(3);
        }
        break;

      case 2: // Iron Mine
        rewards[MaterialType.ironOre] = 8 + _random.nextInt(8);
        rewards[MaterialType.tin] = 5 + _random.nextInt(5);
        rewards[MaterialType.copper] = 5 + _random.nextInt(5);
        if (_random.nextDouble() < 0.2) {
          rewards[MaterialType.silver] = 1 + _random.nextInt(2);
        }
        break;

      case 3: // Magic Ruins
        rewards[MaterialType.magicStone] = 3 + _random.nextInt(5);
        rewards[MaterialType.silver] = 3 + _random.nextInt(5);
        rewards[MaterialType.cloth] = 5 + _random.nextInt(5);
        if (_random.nextDouble() < 0.4) {
          rewards[MaterialType.gold] = 1 + _random.nextInt(3);
        }
        if (_random.nextDouble() < 0.2) {
          rewards[MaterialType.silk] = 1 + _random.nextInt(3);
        }
        break;

      case 4: // Deep Cavern (New)
        rewards[MaterialType.gold] = 3 + _random.nextInt(5);
        rewards[MaterialType.flower] = 3 + _random.nextInt(5);
        rewards[MaterialType.rareGem] = 1;
        if (_random.nextDouble() < 0.1) rewards[MaterialType.mythril] = 1;
        break;

      case 5: // Dragon's Lair (New)
        rewards[MaterialType.mythril] = 3 + _random.nextInt(4);
        rewards[MaterialType.rareGem] = 2 + _random.nextInt(3);
        rewards[MaterialType.silk] = 5 + _random.nextInt(10);
        break;
    }

    return rewards;
  }

  /// Get dungeon info
  String getDungeonName(int depth) {
    switch (depth) {
      case 1:
        return '고요한 숲';
      case 2:
        return '철 광산';
      case 3:
        return '마법 유적';
      case 4:
        return '심연의 동굴';
      case 5:
        return '드래곤의 둥지';
      default:
        return '미지의 던전';
    }
  }

  String getDungeonDescription(int depth) {
    switch (depth) {
      case 1:
        return '약초와 나무를 구할 수 있는 안전한 숲입니다.';
      case 2:
        return '다양한 광석이 매장된 광산입니다.';
      case 3:
        return '고대 마법의 기운이 느껴지는 유적입니다.';
      case 4:
        return '희귀한 보석과 꽃이 피어나는 깊은 동굴입니다.';
      case 5:
        return '전설의 금속 미스릴을 얻을 수 있는 위험한 곳입니다.';
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
