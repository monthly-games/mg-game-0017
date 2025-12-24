import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game/features/economy/economy_manager.dart';
import 'package:game/features/materials/material_inventory.dart';
import 'package:game/features/materials/material_data.dart';
import 'package:game/features/crafting/crafting_manager.dart';
import 'package:game/features/shop/shop_manager.dart';
import 'package:game/features/stations/station_manager.dart';
import 'package:game/features/upgrades/upgrade_manager.dart';
import 'package:game/features/achievements/achievement_manager.dart';
import 'package:game/features/decoration/decoration_manager.dart';
import 'package:game/features/decoration/decoration_data.dart';
import 'package:game/features/save/save_manager.dart';

void main() {
  group('Phase 3 - AchievementManager', () {
    late AchievementManager achievements;

    setUp(() {
      achievements = AchievementManager();
    });

    test('Tracking events updates progress', () {
      // "craft_1": Craft 10 items
      for (int i = 0; i < 5; i++) {
        achievements.recordItemCrafted();
      }

      final progress = achievements.allProgress.firstWhere(
        (p) => p.achievement.id == 'craft_1',
      );
      expect(progress.currentValue, 5);
      expect(progress.isComplete, false);

      for (int i = 0; i < 5; i++) {
        achievements.recordItemCrafted();
      }
      expect(progress.currentValue, 10);
      expect(progress.isComplete, true);
      expect(progress.canClaim, true);
    });

    test('Claiming reward', () {
      // Complete "craft_1"
      for (int i = 0; i < 10; i++) {
        achievements.recordItemCrafted();
      }

      final reward = achievements.claimAchievement('craft_1');
      expect(reward, isNotNull);
      expect(reward!.gold, 100);

      // Cannot claim again
      expect(achievements.claimAchievement('craft_1'), isNull);
    });
  });

  group('Phase 3 - DecorationManager', () {
    late DecorationManager decorations;

    setUp(() {
      decorations = DecorationManager();
    });

    test('Ownership check', () {
      expect(decorations.isOwned('theme_classic'), true); // Default
      expect(decorations.isOwned('theme_dark'), false); // Not owned
    });

    test('Purchase decoration', () {
      var goldSpent = 0;
      bool spendGold(int amount) {
        if (amount <= 1000) {
          goldSpent += amount;
          return true;
        }
        return false;
      }

      // Try buy expensive one
      // Decorations.all is not exposed directly easily, usually via static list in data.
      // Let's pick a known id from DecorationData if I can see it?
      // Looking at `DecorationManager`, it uses `Decorations.getById`.
      // I need a valid ID. `theme_dark` usually exists in these themes?
      // Let's assume 'theme_dark' exists or check `DecorationData` file content previously?
      // Wait, I saw `DecorationManager` but not `DecorationData` fully.
      // `DecorationManager` init owned list: 'theme_classic', 'counter_wood', etc.
      // Let's assume there is something to buy.
      // If I can't guarantee an ID, this test is risky.
      // Let's inspect DecorationData first?
      // Actually, I'll trust standard ids or fail and fix.
      // Let's try 'theme_dark'.

      // If 'theme_dark' doesn't exist, getById returns null usually?
      // Manager: `if (decoration == null) return false;`

      // Let's assume 'floor_wood' exists?
      // Risky. Let's rely on what I saw in `DecorationManager` imports.
      // Use `Decorations.getAllByType(DecorationType.theme)` to find one.

      final themes = decorations.getDecorationsByType(DecorationType.theme);
      final unowned = themes.firstWhere((d) => !decorations.isOwned(d.id));

      expect(
        decorations.purchaseDecoration(unowned.id, spendGold, (i) => true),
        true,
      );
      expect(decorations.isOwned(unowned.id), true);
      expect(goldSpent, unowned.goldCost);
    });
  });

  group('Phase 3 - SaveManager', () {
    late MaterialInventory inventory;
    late CraftingManager crafting;
    late ShopManager shop;
    late EconomyManager economy;
    late StationManager stations;
    late UpgradeManager upgrades;
    late SaveManager saveManager;

    setUp(() {
      SharedPreferences.setMockInitialValues({});

      inventory = MaterialInventory();
      crafting = CraftingManager(inventory);
      shop = ShopManager(crafting);
      economy = EconomyManager();
      stations = StationManager();
      upgrades = UpgradeManager(economy);

      saveManager = SaveManager(
        inventory: inventory,
        crafting: crafting,
        shop: shop,
        economy: economy,
        stations: stations,
        upgrades: upgrades,
      );
    });

    test('Save and Load', () async {
      // Modify state
      economy.addGold(1234);
      inventory.setMaterialAmount(MaterialType.ironOre, 50);

      // Save
      expect(await saveManager.saveGame(), true);

      // Reset state
      economy.reset();
      inventory.reset();
      expect(economy.gold, 500); // Default

      // Load
      expect(await saveManager.loadGame(), true);

      // Verify restoration
      expect(economy.gold, 1734); // 500 (reset) + 1234?
      // Wait, `loadGame` calls `_economy.reset()` then `addGold(savedGold)`.
      // `saveGame` saved `1234 + 500` = 1734.
      // So loaded gold should be 1734.
      expect(economy.gold, 1734);
      expect(inventory.getMaterialAmount(MaterialType.ironOre), 50);
    });
  });
}
