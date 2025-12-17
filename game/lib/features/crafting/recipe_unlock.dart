import 'recipe_data.dart';

/// Requirements for unlocking a recipe
class UnlockRequirement {
  final String recipeId;
  final int goldCost;
  final int shopLevelRequired;
  final List<String>? prerequisiteRecipes; // Must craft these first

  const UnlockRequirement({
    required this.recipeId,
    required this.goldCost,
    required this.shopLevelRequired,
    this.prerequisiteRecipes,
  });
}

/// Recipe unlock configuration
class RecipeUnlocks {
  /// Get unlock requirements for all recipes
  static const Map<String, UnlockRequirement> unlockRequirements = {
    // BASIC - Start unlocked
    'iron_sword': UnlockRequirement(
      recipeId: 'iron_sword',
      goldCost: 0,
      shopLevelRequired: 1,
    ),
    'leather_armor': UnlockRequirement(
      recipeId: 'leather_armor',
      goldCost: 0,
      shopLevelRequired: 1,
    ),
    'wooden_shield': UnlockRequirement(
      recipeId: 'wooden_shield',
      goldCost: 0,
      shopLevelRequired: 1,
    ),

    // INTERMEDIATE - Requires shop level 2 and gold
    'steel_sword': UnlockRequirement(
      recipeId: 'steel_sword',
      goldCost: 200,
      shopLevelRequired: 2,
      prerequisiteRecipes: ['iron_sword'],
    ),
    'iron_armor': UnlockRequirement(
      recipeId: 'iron_armor',
      goldCost: 250,
      shopLevelRequired: 2,
      prerequisiteRecipes: ['leather_armor'],
    ),
    'health_potion': UnlockRequirement(
      recipeId: 'health_potion',
      goldCost: 150,
      shopLevelRequired: 2,
    ),

    // ADVANCED - Requires shop level 3
    'magic_sword': UnlockRequirement(
      recipeId: 'magic_sword',
      goldCost: 500,
      shopLevelRequired: 3,
      prerequisiteRecipes: ['steel_sword'],
    ),
    'dragon_armor': UnlockRequirement(
      recipeId: 'dragon_armor',
      goldCost: 600,
      shopLevelRequired: 3,
      prerequisiteRecipes: ['iron_armor'],
    ),

    // MASTER - Requires shop level 4
    'legendary_blade': UnlockRequirement(
      recipeId: 'legendary_blade',
      goldCost: 1000,
      shopLevelRequired: 4,
      prerequisiteRecipes: ['magic_sword'],
    ),
    'phoenix_ring': UnlockRequirement(
      recipeId: 'phoenix_ring',
      goldCost: 1200,
      shopLevelRequired: 4,
    ),
  };

  /// Get unlock requirement for a recipe
  static UnlockRequirement? getRequirement(String recipeId) {
    return unlockRequirements[recipeId];
  }

  /// Check if a recipe can be unlocked
  static bool canUnlock(
    String recipeId,
    int shopLevel,
    int currentGold,
    Set<String> unlockedRecipeIds,
    Set<String> craftedRecipeIds,
  ) {
    final requirement = unlockRequirements[recipeId];
    if (requirement == null) return false;

    // Already unlocked?
    if (unlockedRecipeIds.contains(recipeId)) return false;

    // Check shop level
    if (shopLevel < requirement.shopLevelRequired) return false;

    // Check gold
    if (currentGold < requirement.goldCost) return false;

    // Check prerequisites (must have crafted them)
    if (requirement.prerequisiteRecipes != null) {
      for (final prereq in requirement.prerequisiteRecipes!) {
        if (!craftedRecipeIds.contains(prereq)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Get all recipes available for unlocking at current shop level
  static List<Recipe> getAvailableRecipes(
    int shopLevel,
    Set<String> unlockedRecipeIds,
  ) {
    return Recipes.getAllRecipes().where((recipe) {
      // Already unlocked?
      if (unlockedRecipeIds.contains(recipe.id)) return false;

      // Check shop level requirement
      final requirement = unlockRequirements[recipe.id];
      if (requirement == null) return false;

      return shopLevel >= requirement.shopLevelRequired;
    }).toList();
  }

  /// Get recipes by tier that are unlockable
  static List<Recipe> getRecipesByTier(
    RecipeTier tier,
    int shopLevel,
    Set<String> unlockedRecipeIds,
  ) {
    return getAvailableRecipes(shopLevel, unlockedRecipeIds)
        .where((r) => r.tier == tier)
        .toList();
  }
}
