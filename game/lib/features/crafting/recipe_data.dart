import '../materials/material_data.dart';

/// Recipe difficulty tiers
enum RecipeTier {
  basic, // 기본
  intermediate, // 중급
  advanced, // 고급
  master, // 마스터
  legendary, // 전설
}

/// Crafting station types
enum CraftingStation {
  workbench, // 작업대
  furnace, // 용광로
  anvil, // 대장간
  alchemyTable, // 연금술대
  enchanting, // 마법부여대
}

/// Item types that can be crafted
enum ItemType {
  weapon, // 무기
  armor, // 방어구
  consumable, // 소모품
  accessory, // 장신구
  tool, // 도구
}

/// Quality levels for crafted items
enum Quality {
  normal, // 일반
  good, // 양호
  excellent, // 우수
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
    requiredMaterials: {MaterialType.ironOre: 3, MaterialType.wood: 1},
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
    requiredMaterials: {MaterialType.leather: 5},
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
    requiredMaterials: {MaterialType.wood: 4},
    outputType: ItemType.armor,
    craftingTime: 3,
    baseQualityChance: 0.8,
    basePrice: 30,
  );

  static const Recipe copperDagger = Recipe(
    id: 'copper_dagger',
    name: '구리 단검',
    description: '가볍고 빠른 단검',
    tier: RecipeTier.basic,
    station: CraftingStation.anvil,
    requiredMaterials: {MaterialType.copper: 2, MaterialType.wood: 1},
    outputType: ItemType.weapon,
    craftingTime: 3,
    baseQualityChance: 0.8,
    basePrice: 25,
  );

  static const Recipe copperHelmet = Recipe(
    id: 'copper_helmet',
    name: '구리 투구',
    description: '머리를 보호하는 기본 투구',
    tier: RecipeTier.basic,
    station: CraftingStation.anvil,
    requiredMaterials: {MaterialType.copper: 3},
    outputType: ItemType.armor,
    craftingTime: 4,
    baseQualityChance: 0.75,
    basePrice: 35,
  );

  static const Recipe clothTunic = Recipe(
    id: 'cloth_tunic',
    name: '천 옷',
    description: '활동하기 편한 옷',
    tier: RecipeTier.basic,
    station: CraftingStation.workbench,
    requiredMaterials: {MaterialType.cloth: 4},
    outputType: ItemType.armor,
    craftingTime: 3,
    baseQualityChance: 0.85,
    basePrice: 20,
  );

  static const Recipe woodenStaff = Recipe(
    id: 'wooden_staff',
    name: '나무 지팡이',
    description: '초보 마법사를 위한 지팡이',
    tier: RecipeTier.basic,
    station: CraftingStation.workbench,
    requiredMaterials: {MaterialType.wood: 3},
    outputType: ItemType.weapon,
    craftingTime: 4,
    baseQualityChance: 0.8,
    basePrice: 30,
  );

  static const Recipe tinBoots = Recipe(
    id: 'tin_boots',
    name: '주석 부츠',
    description: '광택이 나는 부츠',
    tier: RecipeTier.intermediate,
    station: CraftingStation.anvil,
    requiredMaterials: {MaterialType.tin: 3, MaterialType.leather: 1},
    outputType: ItemType.armor,
    craftingTime: 9,
    baseQualityChance: 0.65,
    basePrice: 110,
  );

  // INTERMEDIATE TIER
  static const Recipe ironAxe = Recipe(
    id: 'iron_axe',
    name: '철 도끼',
    description: '강력한 베기 공격이 가능한 도끼',
    tier: RecipeTier.intermediate,
    station: CraftingStation.anvil,
    requiredMaterials: {MaterialType.ironOre: 4, MaterialType.wood: 2},
    outputType: ItemType.weapon,
    craftingTime: 8,
    baseQualityChance: 0.65,
    basePrice: 90,
  );

  static const Recipe silverRing = Recipe(
    id: 'silver_ring',
    name: '은 반지',
    description: '세련된 은제 반지',
    tier: RecipeTier.intermediate,
    station: CraftingStation.enchanting,
    requiredMaterials: {MaterialType.silver: 2},
    outputType: ItemType.accessory,
    craftingTime: 15,
    baseQualityChance: 0.7,
    basePrice: 150,
  );

  static const Recipe silkRobe = Recipe(
    id: 'silk_robe',
    name: '비단 로브',
    description: '마법 저항력이 있는 로브',
    tier: RecipeTier.intermediate,
    station: CraftingStation.workbench,
    requiredMaterials: {MaterialType.silk: 5, MaterialType.magicStone: 1},
    outputType: ItemType.armor,
    craftingTime: 12,
    baseQualityChance: 0.6,
    basePrice: 200,
  );

  static const Recipe manaPotion = Recipe(
    id: 'mana_potion',
    name: '마나 물약',
    description: 'MP를 회복하는 물약',
    tier: RecipeTier.intermediate,
    station: CraftingStation.alchemyTable,
    requiredMaterials: {
      MaterialType.herb: 2,
      MaterialType.root: 1,
      MaterialType.magicStone: 1,
    },
    outputType: ItemType.consumable,
    craftingTime: 8,
    baseQualityChance: 0.7,
    basePrice: 100,
  );

  static const Recipe speedPotion = Recipe(
    id: 'speed_potion',
    name: '신속의 물약',
    description: '이동 속도를 높여주는 물약',
    tier: RecipeTier.intermediate,
    station: CraftingStation.alchemyTable,
    requiredMaterials: {MaterialType.flower: 2, MaterialType.herb: 1},
    outputType: ItemType.consumable,
    craftingTime: 7,
    baseQualityChance: 0.75,
    basePrice: 90,
  );
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
    requiredMaterials: {MaterialType.ironOre: 8, MaterialType.leather: 3},
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
    requiredMaterials: {MaterialType.magicStone: 2, MaterialType.leather: 1},
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

  static const Recipe goldAmulet = Recipe(
    id: 'gold_amulet',
    name: '황금 목걸이',
    description: '부귀의 상징',
    tier: RecipeTier.advanced,
    station: CraftingStation.enchanting,
    requiredMaterials: {MaterialType.gold: 3, MaterialType.rareGem: 1},
    outputType: ItemType.accessory,
    craftingTime: 25,
    baseQualityChance: 0.5,
    basePrice: 500,
  );

  static const Recipe mythrilShield = Recipe(
    id: 'mythril_shield',
    name: '미스릴 방패',
    description: '절대 부서지지 않는 방패',
    tier: RecipeTier.advanced,
    station: CraftingStation.anvil,
    requiredMaterials: {MaterialType.mythril: 4},
    outputType: ItemType.armor,
    craftingTime: 30,
    baseQualityChance: 0.45,
    basePrice: 600,
  );

  static const Recipe magicWand = Recipe(
    id: 'magic_wand',
    name: '마법봉',
    description: '마법을 집중시키는 도구',
    tier: RecipeTier.advanced,
    station: CraftingStation.enchanting,
    requiredMaterials: {
      MaterialType.wood: 2,
      MaterialType.magicStone: 3,
      MaterialType.gold: 1,
    },
    outputType: ItemType.weapon,
    craftingTime: 22,
    baseQualityChance: 0.55,
    basePrice: 350,
  );

  static const Recipe elixir = Recipe(
    id: 'elixir',
    name: '엘릭서',
    description: '모든 상태이상을 치료하는 영약',
    tier: RecipeTier.advanced,
    station: CraftingStation.alchemyTable,
    requiredMaterials: {
      MaterialType.herb: 5,
      MaterialType.flower: 5,
      MaterialType.rareGem: 1,
    },
    outputType: ItemType.consumable,
    craftingTime: 30,
    baseQualityChance: 0.4,
    basePrice: 450,
  );

  // MASTER TIER
  static const Recipe dragonSlayer = Recipe(
    id: 'dragon_slayer',
    name: '드래곤 슬레이어',
    description: '용을 잡기 위해 만들어진 거대한 검',
    tier: RecipeTier.master,
    station: CraftingStation.anvil,
    requiredMaterials: {
      MaterialType.mythril: 10,
      MaterialType.gold: 5,
      MaterialType.rareGem: 2,
    },
    outputType: ItemType.weapon,
    craftingTime: 60,
    baseQualityChance: 0.3,
    basePrice: 1500,
  );

  static const Recipe angelWing = Recipe(
    id: 'angel_wing',
    name: '천사의 날개',
    description: '하늘을 날 수 있을 것 같은 장신구',
    tier: RecipeTier.master,
    station: CraftingStation.enchanting,
    requiredMaterials: {
      MaterialType.silk: 10,
      MaterialType.gold: 5,
      MaterialType.rareGem: 3,
    },
    outputType: ItemType.accessory,
    craftingTime: 50,
    baseQualityChance: 0.35,
    basePrice: 1200,
  );
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
    requiredMaterials: {MaterialType.rareGem: 5, MaterialType.magicStone: 8},
    outputType: ItemType.accessory,
    craftingTime: 35,
    baseQualityChance: 0.35,
    basePrice: 1000,
  );

  /// Get all available recipes
  static List<Recipe> getAllRecipes() {
    return [
      ironSword,
      copperDagger,
      copperHelmet,
      leatherArmor,
      clothTunic,
      woodenShield,
      woodenStaff,
      steelSword,
      ironAxe,
      ironArmor,
      silkRobe,
      tinBoots, // Wait, I didn't define tinBoots in previous call? Checking...
      healthPotion,
      manaPotion,
      speedPotion,
      silverRing,
      magicSword,
      magicWand,
      dragonArmor,
      mythrilShield,
      goldAmulet,
      elixir,
      legendaryBlade,
      dragonSlayer,
      phoenixRing,
      angelWing,
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
