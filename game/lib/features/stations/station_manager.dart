import 'package:flutter/foundation.dart';
import '../crafting/recipe_data.dart';
import '../materials/material_data.dart';
import '../economy/economy_manager.dart';

/// Data for a crafting station and its upgrades
class StationData {
  final CraftingStation type;
  int level;

  StationData({
    required this.type,
    this.level = 1,
  });

  /// Crafting speed multiplier based on level
  double get speedMultiplier {
    return 1.0 + (level - 1) * 0.1; // +10% per level
  }

  /// Quality bonus based on level
  double get qualityBonus {
    return (level - 1) * 0.05; // +5% per level
  }

  /// Get upgrade cost in gold
  int getUpgradeCostGold() {
    return 100 * level * level; // Exponential scaling
  }

  /// Get upgrade material requirements
  Map<MaterialType, int> getUpgradeMaterialCost() {
    switch (type) {
      case CraftingStation.workbench:
        return {
          MaterialType.wood: 5 * level,
          MaterialType.ironOre: 2 * level,
        };
      case CraftingStation.furnace:
        return {
          MaterialType.ironOre: 8 * level,
          MaterialType.wood: 3 * level,
        };
      case CraftingStation.anvil:
        return {
          MaterialType.ironOre: 10 * level,
          MaterialType.magicStone: level,
        };
      case CraftingStation.alchemyTable:
        return {
          MaterialType.magicStone: 3 * level,
          MaterialType.wood: 4 * level,
        };
      case CraftingStation.enchanting:
        return {
          MaterialType.magicStone: 5 * level,
          MaterialType.rareGem: level,
        };
    }
  }

  /// Get station name in Korean
  String getName() {
    switch (type) {
      case CraftingStation.workbench:
        return '작업대';
      case CraftingStation.furnace:
        return '용광로';
      case CraftingStation.anvil:
        return '대장간';
      case CraftingStation.alchemyTable:
        return '연금술대';
      case CraftingStation.enchanting:
        return '마법부여대';
    }
  }

  /// Get station description
  String getDescription() {
    switch (type) {
      case CraftingStation.workbench:
        return '기본 아이템을 제작합니다';
      case CraftingStation.furnace:
        return '금속을 제련합니다';
      case CraftingStation.anvil:
        return '무기와 방어구를 제작합니다';
      case CraftingStation.alchemyTable:
        return '물약과 소모품을 제작합니다';
      case CraftingStation.enchanting:
        return '마법 아이템을 제작합니다';
    }
  }
}

/// Manages all crafting stations and their upgrades
class StationManager extends ChangeNotifier {
  final Map<CraftingStation, StationData> _stations = {};

  StationManager() {
    // Initialize all stations at level 1
    for (final station in CraftingStation.values) {
      _stations[station] = StationData(type: station, level: 1);
    }
  }

  Map<CraftingStation, StationData> get stations => Map.unmodifiable(_stations);

  /// Get data for a specific station
  StationData getStation(CraftingStation type) {
    return _stations[type]!;
  }

  /// Check if can upgrade a station
  bool canUpgrade(
    CraftingStation type,
    EconomyManager economy,
    bool Function(Map<MaterialType, int>) hasMaterials,
  ) {
    final station = _stations[type]!;

    // Check gold
    if (economy.gold < station.getUpgradeCostGold()) {
      return false;
    }

    // Check materials
    if (!hasMaterials(station.getUpgradeMaterialCost())) {
      return false;
    }

    return true;
  }

  /// Upgrade a station
  bool upgradeStation(
    CraftingStation type,
    EconomyManager economy,
    bool Function(Map<MaterialType, int>) consumeMaterials,
  ) {
    final station = _stations[type]!;

    // Check and spend gold
    if (!economy.spendGold(station.getUpgradeCostGold())) {
      return false;
    }

    // Consume materials
    if (!consumeMaterials(station.getUpgradeMaterialCost())) {
      // Refund gold if materials not available
      economy.addGold(station.getUpgradeCostGold());
      return false;
    }

    // Upgrade
    station.level++;
    notifyListeners();
    return true;
  }

  /// Get modified crafting time based on station level
  int getModifiedCraftingTime(Recipe recipe) {
    final station = _stations[recipe.station]!;
    final baseDuration = recipe.craftingTime;
    final modifiedDuration = (baseDuration / station.speedMultiplier).ceil();
    return modifiedDuration;
  }

  /// Get modified quality chance based on station level
  double getModifiedQualityChance(Recipe recipe) {
    final station = _stations[recipe.station]!;
    return (recipe.baseQualityChance + station.qualityBonus).clamp(0.0, 1.0);
  }

  /// Reset all stations (for testing)
  void reset() {
    for (final station in _stations.values) {
      station.level = 1;
    }
    notifyListeners();
  }
}
