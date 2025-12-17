import '../materials/material_data.dart';

/// Recipe difficulty tiers
enum RecipeTier {
  basic,        // 기본
  intermediate, // 중급
  advanced,     // 고급
  master,       // 마스터
  legendary,    // 전설
}

/// Crafting station types
enum CraftingStation {
  workbench,    // 작업대
  furnace,      // 용광로
  anvil,        // 대장간
  alchemyTable, // 연금술대
  enchanting,   // 마법부여대
}

/// Item types that can be crafted
enum ItemType {
  weapon,     // 무기
  armor,      // 방어구
  consumable, // 소모품
  accessory,  // 장신구
  tool,       // 도구
}

/// Quality levels for crafted items
enum Quality {
  normal,      // 일반
  good,        // 양호
  excellent,   // 우수
  masterpiece, // 걸작
}

/// Recipe definition for crafting items
class Recipe {
  final String id;
  final String name;
  final String description;
  final RecipeTier tier;
  final CraftingStation station;
  final Map<MaterialType, int> requiredMaterials;
  final ItemType outputType;
  final int craftingTime; // seconds
  final double baseQualityChance; // 0.0 to 1.0
  final int basePrice; // Sell price

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.tier,
    required this.station,
    required this.requiredMaterials,
    required this.outputType,
    required this.craftingTime,
    required this.baseQualityChance,
    required this.basePrice,
  });

  /// Get quality multiplier for sell price
  static double getQualityMultiplier(Quality quality) {
    switch (quality) {
      case Quality.normal:
        return 1.0;
      case Quality.good:
        return 1.5;
      case Quality.excellent:
        return 2.0;
      case Quality.masterpiece:
        return 3.0;
    }
  }
}

/// Pre-defined recipes
class Recipes {
  // BASIC TIER
  static const Recipe ironSword = Recipe(
    id: 'iron_sword',
    name: '철검',
    description: '기본적인 철제 검',
    tier: RecipeTier.basic,
    station: CraftingStation.anvil,
    requiredMaterials: {
      MaterialType.ironOre: 3,
      MaterialType.wood: 1,
    },
    outputType: ItemType.weapon,
    craftingTime: 5,
    baseQualityChance: 0.7,
    basePrice: 50,
  );

  static const Recipe leatherArmor = Recipe(
    id: 'leather_armor',
    name: '가죽 갑옷',
    description: '기본적인 가죽 방어구',
    tier: RecipeTier.basic,
    station: CraftingStation.workbench,
    requiredMaterials: {
      MaterialType.leather: 5,
    },
    outputType: ItemType.armor,
    craftingTime: 4,
    baseQualityChance: 0.75,
    basePrice: 40,
  );

  static const Recipe woodenShield = Recipe(
    id: 'wooden_shield',
    name: '나무 방패',
    description: '간단한 나무 방패',
    tier: RecipeTier.basic,
    station: CraftingStation.workbench,
    requiredMaterials: {
      MaterialType.wood: 4,
    },
    outputType: ItemType.armor,
    craftingTime: 3,
    baseQualityChance: 0.8,
    basePrice: 30,
  );

  // INTERMEDIATE TIER
  static const Recipe steelSword = Recipe(
    id: 'steel_sword',
    name: '강철검',
    description: '강화된 강철 검',
    tier: RecipeTier.intermediate,
    station: CraftingStation.anvil,
    requiredMaterials: {
      MaterialType.ironOre: 5,
      MaterialType.wood: 2,
      MaterialType.magicStone: 1,
    },
    outputType: ItemType.weapon,
    craftingTime: 10,
    baseQualityChance: 0.6,
    basePrice: 120,
  );

  static const Recipe ironArmor = Recipe(
    id: 'iron_armor',
    name: '철갑옷',
    description: '튼튼한 철제 갑옷',
    tier: RecipeTier.intermediate,
    station: CraftingStation.anvil,
    requiredMaterials: {
      MaterialType.ironOre: 8,
      MaterialType.leather: 3,
    },
    outputType: ItemType.armor,
    craftingTime: 12,
    baseQualityChance: 0.65,
    basePrice: 150,
  );

  static const Recipe healthPotion = Recipe(
    id: 'health_potion',
    name: '체력 물약',
    description: 'HP를 회복하는 물약',
    tier: RecipeTier.intermediate,
    station: CraftingStation.alchemyTable,
    requiredMaterials: {
      MaterialType.magicStone: 2,
      MaterialType.leather: 1,
    },
    outputType: ItemType.consumable,
    craftingTime: 6,
    baseQualityChance: 0.7,
    basePrice: 80,
  );

  // ADVANCED TIER
  static const Recipe magicSword = Recipe(
    id: 'magic_sword',
    name: '마법검',
    description: '마법이 깃든 강력한 검',
    tier: RecipeTier.advanced,
    station: CraftingStation.enchanting,
    requiredMaterials: {
      MaterialType.ironOre: 10,
      MaterialType.magicStone: 5,
      MaterialType.rareGem: 1,
    },
    outputType: ItemType.weapon,
    craftingTime: 20,
    baseQualityChance: 0.5,
    basePrice: 300,
  );

  static const Recipe dragonArmor = Recipe(
    id: 'dragon_armor',
    name: '드래곤 갑옷',
    description: '드래곤 비늘로 만든 갑옷',
    tier: RecipeTier.advanced,
    station: CraftingStation.anvil,
    requiredMaterials: {
      MaterialType.ironOre: 12,
      MaterialType.leather: 8,
      MaterialType.magicStone: 3,
    },
    outputType: ItemType.armor,
    craftingTime: 25,
    baseQualityChance: 0.45,
    basePrice: 400,
  );

  // MASTER TIER
  static const Recipe legendaryBlade = Recipe(
    id: 'legendary_blade',
    name: '전설의 검',
    description: '전설로 전해지는 강력한 검',
    tier: RecipeTier.master,
    station: CraftingStation.enchanting,
    requiredMaterials: {
      MaterialType.ironOre: 20,
      MaterialType.magicStone: 10,
      MaterialType.rareGem: 3,
    },
    outputType: ItemType.weapon,
    craftingTime: 40,
    baseQualityChance: 0.4,
    basePrice: 800,
  );

  static const Recipe phoenixRing = Recipe(
    id: 'phoenix_ring',
    name: '불사조의 반지',
    description: '부활의 힘을 지닌 반지',
    tier: RecipeTier.master,
    station: CraftingStation.enchanting,
    requiredMaterials: {
      MaterialType.rareGem: 5,
      MaterialType.magicStone: 8,
    },
    outputType: ItemType.accessory,
    craftingTime: 35,
    baseQualityChance: 0.35,
    basePrice: 1000,
  );

  /// Get all available recipes
  static List<Recipe> getAllRecipes() {
    return [
      ironSword,
      leatherArmor,
      woodenShield,
      steelSword,
      ironArmor,
      healthPotion,
      magicSword,
      dragonArmor,
      legendaryBlade,
      phoenixRing,
    ];
  }

  /// Get recipes by tier
  static List<Recipe> getRecipesByTier(RecipeTier tier) {
    return getAllRecipes().where((r) => r.tier == tier).toList();
  }

  /// Get recipes by station
  static List<Recipe> getRecipesByStation(CraftingStation station) {
    return getAllRecipes().where((r) => r.station == station).toList();
  }

  /// Get recipe by ID
  static Recipe? getRecipeById(String id) {
    try {
      return getAllRecipes().firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
