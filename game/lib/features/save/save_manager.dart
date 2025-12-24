import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../materials/material_inventory.dart';
import '../materials/material_data.dart';
import '../crafting/recipe_data.dart';
import '../shop/shop_manager.dart';
import '../economy/economy_manager.dart';
import '../crafting/crafting_manager.dart';
import '../stations/station_manager.dart';
import '../upgrades/upgrade_manager.dart';

/// Manages saving and loading game state
class SaveManager extends ChangeNotifier {
  static const String _saveKey = 'dungeon_craft_save';
  static const String _lastSaveTimeKey = 'last_save_time';

  final MaterialInventory _inventory;
  final CraftingManager _crafting;
  final ShopManager _shop;
  final EconomyManager _economy;
  final StationManager _stations;
  final UpgradeManager _upgrades;

  DateTime? _lastSaveTime;
  DateTime? get lastSaveTime => _lastSaveTime;

  SaveManager({
    required MaterialInventory inventory,
    required CraftingManager crafting,
    required ShopManager shop,
    required EconomyManager economy,
    required StationManager stations,
    required UpgradeManager upgrades,
  }) : _inventory = inventory,
       _crafting = crafting,
       _shop = shop,
       _economy = economy,
       _stations = stations,
       _upgrades = upgrades;

  /// Save all game state
  Future<bool> saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Build save data
      final saveData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'economy': {'gold': _economy.gold, 'gems': _economy.gems},
        'upgrades': _upgrades.toJson(),
        'materials': {
          for (var type in MaterialType.values)
            type.name: {
              'amount': _inventory.getMaterialAmount(type),
              'productionRate': _inventory.getProductionRate(type),
            },
        },
        'stations': {
          for (var station in CraftingStation.values)
            station.name: {'level': _stations.getStation(station).level},
        },
        'crafting': {
          'unlockedRecipes': _crafting.unlockedRecipeIds.toList(),
          'craftedRecipes': _crafting.craftedRecipeIds.toList(),
        },
        'shop': {'displaySlots': _shop.maxDisplaySlots},
      };

      // Save to SharedPreferences
      await prefs.setString(_saveKey, jsonEncode(saveData));
      await prefs.setString(_lastSaveTimeKey, DateTime.now().toIso8601String());

      _lastSaveTime = DateTime.now();
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Error saving game: $e');
      return false;
    }
  }

  /// Load game state
  Future<bool> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get save data
      final saveDataString = prefs.getString(_saveKey);
      if (saveDataString == null) {
        debugPrint('No save data found');
        return false;
      }

      final saveData = jsonDecode(saveDataString) as Map<String, dynamic>;

      // Load economy
      final economy = saveData['economy'] as Map<String, dynamic>;
      _economy.reset();
      _economy.setGold(economy['gold'] as int);
      _economy.setGems(economy['gems'] as int);

      // Load materials
      final materials = saveData['materials'] as Map<String, dynamic>;
      for (var entry in materials.entries) {
        final type = MaterialType.values.firstWhere((t) => t.name == entry.key);
        final data = entry.value as Map<String, dynamic>;

        _inventory.setMaterialAmount(type, data['amount'] as int);
        _inventory.setProductionRate(type, data['productionRate'] as double);
      }

      // Load stations
      final stations = saveData['stations'] as Map<String, dynamic>;
      for (var entry in stations.entries) {
        final station = CraftingStation.values.firstWhere(
          (s) => s.name == entry.key,
        );
        final data = entry.value as Map<String, dynamic>;
        final level = data['level'] as int;

        // Upgrade station to saved level
        for (var i = 1; i < level; i++) {
          _stations.getStation(station).level = i + 1;
        }
      }

      // Load crafting
      final crafting = saveData['crafting'] as Map<String, dynamic>;
      final unlockedRecipes = (crafting['unlockedRecipes'] as List)
          .cast<String>();
      final craftedRecipes = (crafting['craftedRecipes'] as List)
          .cast<String>();

      for (var recipeId in unlockedRecipes) {
        _crafting.unlockRecipe(recipeId);
      }

      // Restore crafted recipe history
      _crafting.restoreCraftedRecipes(craftedRecipes);

      // Load shop
      final shop = saveData['shop'] as Map<String, dynamic>;
      final displaySlots = shop['displaySlots'] as int;
      _shop.loadState(displaySlots, 1);

      // Load upgrades
      if (saveData['upgrades'] != null) {
        _upgrades.loadFromJson(saveData['upgrades'] as Map<String, dynamic>);
      }

      // Calculate offline production
      final lastSaveTimeString = prefs.getString(_lastSaveTimeKey);
      if (lastSaveTimeString != null) {
        final lastSave = DateTime.parse(lastSaveTimeString);
        final offlineDuration = DateTime.now().difference(lastSave);

        _inventory.calculateOfflineProduction(offlineDuration);
        _economy.calculateOfflineIncome(offlineDuration);

        _lastSaveTime = lastSave;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error loading game: $e');
      return false;
    }
  }

  /// Check if save data exists
  Future<bool> hasSaveData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }

  /// Delete save data
  Future<bool> deleteSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKey);
      await prefs.remove(_lastSaveTimeKey);
      _lastSaveTime = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting save: $e');
      return false;
    }
  }

  /// Auto-save every 30 seconds
  void startAutoSave() {
    Future.delayed(const Duration(seconds: 30), () {
      saveGame();
      startAutoSave();
    });
  }
}
