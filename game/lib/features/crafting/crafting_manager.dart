import 'package:flutter/foundation.dart';
import 'dart:math';
import 'recipe_data.dart';
import 'recipe_unlock.dart';
import '../materials/material_inventory.dart';

/// Represents an item that has been crafted
class CraftedItem {
  final String id;
  final Recipe recipe;
  final Quality quality;
  final int sellPrice;

  CraftedItem({
    String? id,
    required this.recipe,
    required this.quality,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        sellPrice = (recipe.basePrice * Recipe.getQualityMultiplier(quality)).toInt();

  String get name => recipe.name;
  String get description => recipe.description;
  ItemType get type => recipe.outputType;
}

/// Represents an active crafting job
class CraftingJob {
  final String id;
  final Recipe recipe;
  final DateTime startTime;
  final DateTime endTime;

  CraftingJob({
    required this.id,
    required this.recipe,
    required this.startTime,
  }) : endTime = startTime.add(Duration(seconds: recipe.craftingTime));

  bool get isComplete => DateTime.now().isAfter(endTime);

  double get progress {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return 1.0;

    final totalDuration = endTime.difference(startTime).inMilliseconds;
    final elapsed = now.difference(startTime).inMilliseconds;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }
}

/// Manages crafting process and unlocked recipes
class CraftingManager extends ChangeNotifier {
  final MaterialInventory _inventory;
  final Random _random = Random();

  // Unlocked recipes
  final Set<String> _unlockedRecipeIds = {
    'iron_sword',
    'leather_armor',
    'wooden_shield',
  };

  // Crafted recipe history (for unlock prerequisites)
  final Set<String> _craftedRecipeIds = {};

  // Active crafting jobs by station
  final Map<CraftingStation, CraftingJob?> _activeJobs = {};

  // Completed items waiting to be collected
  final List<CraftedItem> _completedItems = [];

  CraftingManager(this._inventory) {
    // Initialize empty job slots
    for (final station in CraftingStation.values) {
      _activeJobs[station] = null;
    }
  }

  Set<String> get unlockedRecipeIds => Set.unmodifiable(_unlockedRecipeIds);
  Map<CraftingStation, CraftingJob?> get activeJobs => Map.unmodifiable(_activeJobs);
  List<CraftedItem> get completedItems => List.unmodifiable(_completedItems);

  /// Get all unlocked recipes
  List<Recipe> getUnlockedRecipes() {
    return Recipes.getAllRecipes()
        .where((r) => _unlockedRecipeIds.contains(r.id))
        .toList();
  }

  /// Check if a recipe is unlocked
  bool isRecipeUnlocked(String recipeId) {
    return _unlockedRecipeIds.contains(recipeId);
  }

  /// Unlock a new recipe
  void unlockRecipe(String recipeId) {
    if (_unlockedRecipeIds.add(recipeId)) {
      notifyListeners();
    }
  }

  /// Check if can start crafting (has materials and station available)
  bool canStartCrafting(Recipe recipe) {
    // Check if station is busy
    if (_activeJobs[recipe.station] != null && !_activeJobs[recipe.station]!.isComplete) {
      return false;
    }

    // Check materials
    return _inventory.hasMaterials(recipe.requiredMaterials);
  }

  /// Start crafting a recipe
  bool startCrafting(Recipe recipe) {
    if (!canStartCrafting(recipe)) return false;

    // Consume materials
    if (!_inventory.consumeMaterials(recipe.requiredMaterials)) {
      return false;
    }

    // Create crafting job
    final job = CraftingJob(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipe: recipe,
      startTime: DateTime.now(),
    );

    _activeJobs[recipe.station] = job;
    notifyListeners();
    return true;
  }

  /// Complete a crafting job and create the item
  CraftedItem? completeCrafting(CraftingStation station) {
    final job = _activeJobs[station];
    if (job == null || !job.isComplete) return null;

    // Roll for quality
    final quality = _rollQuality(job.recipe.baseQualityChance);

    // Create item
    final item = CraftedItem(
      recipe: job.recipe,
      quality: quality,
    );

    // Mark recipe as crafted (for unlock prerequisites)
    _craftedRecipeIds.add(job.recipe.id);

    // Clear job
    _activeJobs[station] = null;
    _completedItems.add(item);
    notifyListeners();

    return item;
  }

  /// Roll for item quality based on chance
  Quality _rollQuality(double baseChance) {
    final roll = _random.nextDouble();

    if (roll < baseChance * 0.05) {
      return Quality.masterpiece; // 5% of base chance
    } else if (roll < baseChance * 0.20) {
      return Quality.excellent; // 20% of base chance
    } else if (roll < baseChance * 0.50) {
      return Quality.good; // 50% of base chance
    } else {
      return Quality.normal;
    }
  }

  /// Update all crafting jobs (call in game loop)
  void update() {
    bool anyCompleted = false;

    for (final entry in _activeJobs.entries) {
      final job = entry.value;
      if (job != null && job.isComplete) {
        anyCompleted = true;
      }
    }

    if (anyCompleted) {
      notifyListeners();
    }
  }

  /// Instantly complete a crafting job (for premium currency)
  bool instantComplete(CraftingStation station) {
    final job = _activeJobs[station];
    if (job == null) return false;

    // Force completion by creating job with past end time
    _activeJobs[station] = CraftingJob(
      id: job.id,
      recipe: job.recipe,
      startTime: DateTime.now().subtract(Duration(seconds: job.recipe.craftingTime + 1)),
    );

    notifyListeners();
    return true;
  }

  /// Remove a completed item from inventory (when sold)
  void removeItem(CraftedItem item) {
    _completedItems.remove(item);
    notifyListeners();
  }

  /// Get active job for a station
  CraftingJob? getJobForStation(CraftingStation station) {
    return _activeJobs[station];
  }

  /// Check if any station has completed jobs
  bool hasCompletedJobs() {
    return _activeJobs.values.any((job) => job != null && job.isComplete);
  }

  /// Get recipes available for unlocking
  List<Recipe> getAvailableUnlocks(int shopLevel, int currentGold) {
    return RecipeUnlocks.getAvailableRecipes(shopLevel, _unlockedRecipeIds)
        .where((recipe) {
      final requirement = RecipeUnlocks.getRequirement(recipe.id);
      if (requirement == null) return false;

      return RecipeUnlocks.canUnlock(
        recipe.id,
        shopLevel,
        currentGold,
        _unlockedRecipeIds,
        _craftedRecipeIds,
      );
    }).toList();
  }

  /// Unlock a recipe with gold
  bool unlockRecipeWithGold(String recipeId, int shopLevel, int currentGold, Function(int) spendGold) {
    if (!RecipeUnlocks.canUnlock(recipeId, shopLevel, currentGold, _unlockedRecipeIds, _craftedRecipeIds)) {
      return false;
    }

    final requirement = RecipeUnlocks.getRequirement(recipeId);
    if (requirement == null) return false;

    // Spend gold
    if (!spendGold(requirement.goldCost)) return false;

    // Unlock recipe
    _unlockedRecipeIds.add(recipeId);
    notifyListeners();
    return true;
  }

  /// Get all recipes that have been crafted at least once
  Set<String> get craftedRecipeIds => Set.unmodifiable(_craftedRecipeIds);

  /// Restore crafted recipe history (for save/load)
  void restoreCraftedRecipes(List<String> recipeIds) {
    _craftedRecipeIds.clear();
    _craftedRecipeIds.addAll(recipeIds);
    notifyListeners();
  }
}
