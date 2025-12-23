import 'package:flutter_test/flutter_test.dart';
import 'package:game/features/materials/material_inventory.dart';
import 'package:game/features/materials/material_data.dart';
import 'package:game/features/crafting/crafting_manager.dart';
import 'package:game/features/crafting/recipe_data.dart';
import 'package:game/features/economy/economy_manager.dart';

void main() {
  group('Phase 1 - MaterialInventory', () {
    late MaterialInventory inventory;

    setUp(() {
      inventory = MaterialInventory();
      inventory.reset();
    });

    test('Initial materials are correct', () {
      expect(inventory.getMaterial(MaterialType.ironOre), 10.0);
      expect(inventory.getMaterial(MaterialType.wood), 15.0);
    });

    test('Production updates correctly', () {
      // Iron ore rate is 1.0/sec
      const dt = 5.0; // 5 seconds
      final initialIron = inventory.getMaterial(MaterialType.ironOre);

      inventory.updateProduction(dt);

      expect(inventory.getMaterial(MaterialType.ironOre), initialIron + 5.0);
    });

    test('Consuming materials works', () {
      final required = {MaterialType.ironOre: 5};
      expect(inventory.consumeMaterials(required), true);
      expect(inventory.getMaterial(MaterialType.ironOre), 5.0); // 10 - 5
    });

    test('Consuming insufficient materials fails', () {
      final required = {MaterialType.ironOre: 20}; // Have 10
      expect(inventory.consumeMaterials(required), false);
      expect(inventory.getMaterial(MaterialType.ironOre), 10.0);
    });
  });

  group('Phase 1 - CraftingManager', () {
    late MaterialInventory inventory;
    late CraftingManager craftingManager;

    setUp(() {
      inventory = MaterialInventory();
      inventory.reset();
      craftingManager = CraftingManager(inventory);
    });

    test('Can start crafting with sufficient materials', () {
      final recipe = Recipes.ironSword;
      // Requirements: IronOre: 3, Wood: 1. Initial: 10, 15.

      expect(craftingManager.canStartCrafting(recipe), true);
      expect(craftingManager.startCrafting(recipe), true);

      // Materials consumed?
      expect(inventory.getMaterial(MaterialType.ironOre), 7.0);
      expect(inventory.getMaterial(MaterialType.wood), 14.0);

      // Job active?
      expect(craftingManager.getJobForStation(recipe.station), isNotNull);
    });

    test('Cannot start crafting with insufficient materials', () {
      final recipe = Recipes.ironSword;
      final cost = {MaterialType.ironOre: 100}; // Force fail
      inventory.consumeMaterials(
        cost,
      ); // Just to drain if needed in real flow, but here we can just verify via canStart logic if we modify requirements, but recipes are const.
      // Instead, drain inventory manually
      inventory.consumeMaterials({MaterialType.ironOre: 10}); // Drain iron

      expect(craftingManager.canStartCrafting(recipe), false);
      expect(craftingManager.startCrafting(recipe), false);
    });

    test('Crafting completes after time', () async {
      final recipe = Recipes.ironSword; // 5 seconds
      craftingManager.startCrafting(recipe);

      final job = craftingManager.getJobForStation(recipe.station)!;

      // Initially not complete
      expect(job.isComplete, false);

      // Simulate time passing (instant completion for test)
      craftingManager.instantComplete(recipe.station);

      // Now complete
      // Re-fetch job as instantComplete replaces it
      final completedJob = craftingManager.getJobForStation(recipe.station)!;
      expect(completedJob.isComplete, true);

      // Collect
      final item = craftingManager.completeCrafting(recipe.station);
      expect(item, isNotNull);
      expect(item!.name, recipe.name);

      // Added to completed items
      expect(craftingManager.completedItems.contains(item), true);
    });
  });

  group('Phase 1 - EconomyManager', () {
    late EconomyManager economy;

    setUp(() {
      economy = EconomyManager();
      economy.reset();
    });

    test('Initial currency', () {
      expect(economy.gold, 500);
      expect(economy.gems, 10);
    });

    test('Add/Spend Gold', () {
      economy.addGold(100);
      expect(economy.gold, 600);

      expect(economy.spendGold(200), true);
      expect(economy.gold, 400);

      expect(economy.spendGold(1000), false);
      expect(economy.gold, 400);
    });
  });
}
