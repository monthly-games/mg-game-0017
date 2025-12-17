/// Achievement types
enum AchievementType {
  craftItems,      // Craft X items
  sellItems,       // Sell X items
  earnGold,        // Earn X gold total
  upgradeStations, // Upgrade stations X times
  unlockRecipes,   // Unlock X recipes
  exploreDungeons, // Complete X dungeon explorations
}

/// Achievement rewards
class AchievementReward {
  final int gold;
  final int gems;

  const AchievementReward({
    this.gold = 0,
    this.gems = 0,
  });
}

/// Achievement definition
class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final int targetValue;
  final AchievementReward reward;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.reward,
  });
}

/// All achievements
class Achievements {
  static const List<Achievement> all = [
    // Crafting achievements
    Achievement(
      id: 'craft_1',
      name: '견습 대장장이',
      description: '아이템 10개 제작',
      type: AchievementType.craftItems,
      targetValue: 10,
      reward: AchievementReward(gold: 100, gems: 1),
    ),
    Achievement(
      id: 'craft_2',
      name: '숙련 대장장이',
      description: '아이템 50개 제작',
      type: AchievementType.craftItems,
      targetValue: 50,
      reward: AchievementReward(gold: 500, gems: 3),
    ),
    Achievement(
      id: 'craft_3',
      name: '마스터 대장장이',
      description: '아이템 200개 제작',
      type: AchievementType.craftItems,
      targetValue: 200,
      reward: AchievementReward(gold: 2000, gems: 10),
    ),

    // Selling achievements
    Achievement(
      id: 'sell_1',
      name: '초보 상인',
      description: '아이템 20개 판매',
      type: AchievementType.sellItems,
      targetValue: 20,
      reward: AchievementReward(gold: 150, gems: 1),
    ),
    Achievement(
      id: 'sell_2',
      name: '베테랑 상인',
      description: '아이템 100개 판매',
      type: AchievementType.sellItems,
      targetValue: 100,
      reward: AchievementReward(gold: 750, gems: 5),
    ),
    Achievement(
      id: 'sell_3',
      name: '전설의 상인',
      description: '아이템 500개 판매',
      type: AchievementType.sellItems,
      targetValue: 500,
      reward: AchievementReward(gold: 3000, gems: 15),
    ),

    // Gold achievements
    Achievement(
      id: 'gold_1',
      name: '부자의 시작',
      description: '골드 1000 획득 (누적)',
      type: AchievementType.earnGold,
      targetValue: 1000,
      reward: AchievementReward(gold: 200, gems: 2),
    ),
    Achievement(
      id: 'gold_2',
      name: '재산가',
      description: '골드 10000 획득 (누적)',
      type: AchievementType.earnGold,
      targetValue: 10000,
      reward: AchievementReward(gold: 1000, gems: 5),
    ),
    Achievement(
      id: 'gold_3',
      name: '억만장자',
      description: '골드 100000 획득 (누적)',
      type: AchievementType.earnGold,
      targetValue: 100000,
      reward: AchievementReward(gold: 5000, gems: 20),
    ),

    // Upgrade achievements
    Achievement(
      id: 'upgrade_1',
      name: '시설 관리자',
      description: '제작소 5회 업그레이드',
      type: AchievementType.upgradeStations,
      targetValue: 5,
      reward: AchievementReward(gold: 300, gems: 2),
    ),
    Achievement(
      id: 'upgrade_2',
      name: '완벽주의자',
      description: '제작소 20회 업그레이드',
      type: AchievementType.upgradeStations,
      targetValue: 20,
      reward: AchievementReward(gold: 1500, gems: 7),
    ),

    // Recipe unlock achievements
    Achievement(
      id: 'recipe_1',
      name: '레시피 수집가',
      description: '레시피 5개 해금',
      type: AchievementType.unlockRecipes,
      targetValue: 5,
      reward: AchievementReward(gold: 250, gems: 2),
    ),
    Achievement(
      id: 'recipe_2',
      name: '레시피 마스터',
      description: '모든 레시피 해금',
      type: AchievementType.unlockRecipes,
      targetValue: 10,
      reward: AchievementReward(gold: 2000, gems: 10),
    ),

    // Dungeon exploration achievements
    Achievement(
      id: 'dungeon_1',
      name: '모험가',
      description: '던전 10회 탐험',
      type: AchievementType.exploreDungeons,
      targetValue: 10,
      reward: AchievementReward(gold: 200, gems: 2),
    ),
    Achievement(
      id: 'dungeon_2',
      name: '베테랑 탐험가',
      description: '던전 50회 탐험',
      type: AchievementType.exploreDungeons,
      targetValue: 50,
      reward: AchievementReward(gold: 1000, gems: 5),
    ),
    Achievement(
      id: 'dungeon_3',
      name: '던전 마스터',
      description: '던전 200회 탐험',
      type: AchievementType.exploreDungeons,
      targetValue: 200,
      reward: AchievementReward(gold: 4000, gems: 15),
    ),
  ];

  static Achievement? getById(String id) {
    return all.firstWhere((a) => a.id == id);
  }
}
