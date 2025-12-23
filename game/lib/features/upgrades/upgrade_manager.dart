import 'package:flutter/foundation.dart';
import '../economy/economy_manager.dart';

enum UpgradeType { explorationSpeed, lootLuck }

class UpgradeManager extends ChangeNotifier {
  final EconomyManager _economy;

  // Key: UpgradeType.name, Value: Level
  final Map<String, int> _upgradeLevels = {
    UpgradeType.explorationSpeed.name: 0,
    UpgradeType.lootLuck.name: 0,
  };

  UpgradeManager(this._economy);

  int getLevel(UpgradeType type) => _upgradeLevels[type.name] ?? 0;

  double get speedMultiplier {
    // 10% speed increase per level
    // Duration = Base / (1 + 0.1 * level)
    final level = getLevel(UpgradeType.explorationSpeed);
    return 1.0 + (level * 0.1);
  }

  double get luckMultiplier {
    // 10% luck increase per level
    // Chance = Base * (1 + 0.1 * level)
    final level = getLevel(UpgradeType.lootLuck);
    return 1.0 + (level * 0.1);
  }

  int getUpgradeCost(UpgradeType type) {
    final level = getLevel(type);
    // Base cost 100, increases by 50% each level
    // 100, 150, 225, ...
    return (100 * (1 + 0.5 * level)).round();
  }

  bool canAfford(UpgradeType type) {
    return _economy.gold >= getUpgradeCost(type);
  }

  bool buyUpgrade(UpgradeType type) {
    final cost = getUpgradeCost(type);
    if (_economy.spendGold(cost)) {
      _upgradeLevels[type.name] = getLevel(type) + 1;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Persistence
  Map<String, dynamic> toJson() {
    return {'upgradeLevels': _upgradeLevels};
  }

  void loadFromJson(Map<String, dynamic> json) {
    if (json['upgradeLevels'] != null) {
      final levels = Map<String, dynamic>.from(json['upgradeLevels']);
      _upgradeLevels.clear();
      levels.forEach((key, value) {
        _upgradeLevels[key] = value as int;
      });
      notifyListeners();
    }
  }
}
