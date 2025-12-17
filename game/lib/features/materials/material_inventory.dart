import 'package:flutter/foundation.dart';
import 'material_data.dart';

/// Manages player's material inventory with idle production
class MaterialInventory extends ChangeNotifier {
  // Current material amounts
  final Map<MaterialType, double> _materials = {
    MaterialType.ironOre: 10.0,
    MaterialType.wood: 15.0,
    MaterialType.leather: 5.0,
    MaterialType.magicStone: 2.0,
    MaterialType.rareGem: 0.0,
  };

  // Production rates (per second)
  final Map<MaterialType, double> _productionRates = {
    MaterialType.ironOre: 1.0,
    MaterialType.wood: 1.5,
    MaterialType.leather: 0.5,
    MaterialType.magicStone: 0.2,
    MaterialType.rareGem: 0.1,
  };

  // Last update time for idle production
  DateTime _lastUpdateTime = DateTime.now();

  Map<MaterialType, double> get materials => Map.unmodifiable(_materials);
  Map<MaterialType, double> get productionRates => Map.unmodifiable(_productionRates);

  /// Get amount of a specific material
  double getMaterial(MaterialType type) {
    return _materials[type] ?? 0.0;
  }

  /// Add material to inventory
  void addMaterial(MaterialType type, double amount) {
    _materials[type] = (_materials[type] ?? 0.0) + amount;
    notifyListeners();
  }

  /// Check if player has required materials
  bool hasMaterials(Map<MaterialType, int> required) {
    for (final entry in required.entries) {
      if (getMaterial(entry.key) < entry.value) {
        return false;
      }
    }
    return true;
  }

  /// Consume materials (returns false if not enough)
  bool consumeMaterials(Map<MaterialType, int> required) {
    if (!hasMaterials(required)) return false;

    for (final entry in required.entries) {
      _materials[entry.key] = _materials[entry.key]! - entry.value;
    }

    notifyListeners();
    return true;
  }

  /// Update idle production based on elapsed time
  void updateProduction(double dt) {
    for (final entry in _productionRates.entries) {
      final type = entry.key;
      final rate = entry.value;
      _materials[type] = (_materials[type] ?? 0.0) + (rate * dt);
    }
    _lastUpdateTime = DateTime.now();
    notifyListeners();
  }

  /// Calculate offline production when app reopens
  void calculateOfflineProduction() {
    final now = DateTime.now();
    final offlineSeconds = now.difference(_lastUpdateTime).inSeconds.toDouble();

    // Cap offline time to 8 hours
    final cappedSeconds = offlineSeconds.clamp(0.0, 8 * 60 * 60);

    if (cappedSeconds > 0) {
      for (final entry in _productionRates.entries) {
        final type = entry.key;
        final rate = entry.value;
        _materials[type] = (_materials[type] ?? 0.0) + (rate * cappedSeconds);
      }
      _lastUpdateTime = now;
      notifyListeners();
    }
  }

  /// Upgrade production rate for a material
  void upgradeProductionRate(MaterialType type, double increase) {
    _productionRates[type] = (_productionRates[type] ?? 0.0) + increase;
    notifyListeners();
  }

  /// Reset inventory (for testing)
  void reset() {
    _materials.clear();
    _materials.addAll({
      MaterialType.ironOre: 10.0,
      MaterialType.wood: 15.0,
      MaterialType.leather: 5.0,
      MaterialType.magicStone: 2.0,
      MaterialType.rareGem: 0.0,
    });
    _lastUpdateTime = DateTime.now();
    notifyListeners();
  }
}
