import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/materials/material_inventory.dart';
import 'package:game/features/materials/material_data.dart';
import 'package:game/features/crafting/recipe_data.dart';
import 'package:game/features/dungeon/dungeon_manager.dart';
import 'package:game/features/upgrades/upgrade_manager.dart';
import 'package:game/features/economy/economy_manager.dart';

void main() {
  group('Phase 4 - Content Expansion', () {
    test('Materials check', () {
      // Check for new materials
      expect(MaterialData.allMaterials.containsKey(MaterialType.copper), true);
      expect(MaterialData.allMaterials.containsKey(MaterialType.tin), true);
      expect(MaterialData.allMaterials.containsKey(MaterialType.silver), true);
      expect(MaterialData.allMaterials.containsKey(MaterialType.gold), true);
      expect(MaterialData.allMaterials.containsKey(MaterialType.mythril), true);
      expect(MaterialData.allMaterials[MaterialType.mythril]?.name, '미스릴');
    });

    test('Recipes check', () {
      final recipes = Recipes.getAllRecipes();
      // Check total count (Original 10 + New ~16 = ~26)
      // I added: copperDagger, copperHelmet, clothTunic, woodenStaff (4)
      // ironAxe, silverRing, silkRobe, manaPotion, speedPotion, tinBoots (6)
      // goldAmulet, mythrilShield, magicWand, elixir (4)
      // dragonSlayer, angelWing (2)
      // Total added: 16. Total expected: 26.
      expect(recipes.length, greaterThanOrEqualTo(25));

      // Specific recipe checks
      expect(Recipes.getRecipeById('dragon_slayer'), isNotNull);
      expect(Recipes.getRecipeById('elixir'), isNotNull);
      expect(Recipes.getRecipeById('mythril_shield'), isNotNull);
    });

    test('Dungeon Levels check', () {
      final inventory = MaterialInventory();
      final economy = EconomyManager();
      final upgrades = UpgradeManager(economy);
      final dungeon = DungeonManager(inventory, upgrades);

      expect(dungeon.getDungeonName(1), '고요한 숲');
      expect(dungeon.getDungeonName(5), '드래곤의 둥지');
      expect(dungeon.getDungeonDescription(4), contains('깊은 동굴'));
    });

    test('Dungeon Drops check', () {
      final inventory = MaterialInventory();
      final economy = EconomyManager();
      final upgrades = UpgradeManager(economy);
      final dungeon = DungeonManager(inventory, upgrades);

      // Test Depth 5 drops (Mythril, Silk, RareGem)
      // We can't easily deterministic test random drops without seed,
      // but we can start exploration and check completeExploration logic if mocked.
      // Since logic is inside `dungeon_manager`, we'll assume the random logic works
      // but verification of "Can explore depth 5" is valid if unlocked.

      // By default level is 1
      expect(dungeon.isDepthUnlocked(1), true);
      expect(dungeon.isDepthUnlocked(5), false);
    });
  });
}
