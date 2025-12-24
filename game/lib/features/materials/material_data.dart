/// Material types available in the game
enum MaterialType {
  ironOre, // 철광석
  wood, // 나무
  leather, // 가죽
  magicStone, // 마법석
  rareGem, // 희귀 보석
  // Phase 4 New Materials
  copper, // 구리
  tin, // 주석
  silver, // 은
  gold, // 금
  mythril, // 미스릴
  cloth, // 천
  silk, // 비단
  herb, // 약초
  root, // 나무뿌리
  flower, // 마력꽃
}

/// Material data with production and display information
class MaterialData {
  final MaterialType type;
  final String name;
  final String description;
  final double baseProductionRate; // Per second when upgraded

  const MaterialData({
    required this.type,
    required this.name,
    required this.description,
    required this.baseProductionRate,
  });

  /// All available materials
  static const Map<MaterialType, MaterialData> allMaterials = {
    MaterialType.ironOre: MaterialData(
      type: MaterialType.ironOre,
      name: '철광석',
      description: '기본 금속 재료. 무기와 방어구 제작에 필수.',
      baseProductionRate: 2.0,
    ),
    MaterialType.wood: MaterialData(
      type: MaterialType.wood,
      name: '나무',
      description: '다용도 재료. 도구와 가구 제작에 사용.',
      baseProductionRate: 3.0,
    ),
    MaterialType.leather: MaterialData(
      type: MaterialType.leather,
      name: '가죽',
      description: '유연한 재료. 갑옷과 가방 제작에 사용.',
      baseProductionRate: 1.5,
    ),
    MaterialType.magicStone: MaterialData(
      type: MaterialType.magicStone,
      name: '마법석',
      description: '마법이 깃든 돌. 마법 아이템 제작에 필요.',
      baseProductionRate: 0.5,
    ),
    MaterialType.rareGem: MaterialData(
      type: MaterialType.rareGem,
      name: '희귀 보석',
      description: '귀중한 보석. 고급 장신구 제작에 필수.',
      baseProductionRate: 0.2,
    ),
    // New Materials
    MaterialType.copper: MaterialData(
      type: MaterialType.copper,
      name: '구리',
      description: '가공하기 쉬운 금속.',
      baseProductionRate: 2.5,
    ),
    MaterialType.tin: MaterialData(
      type: MaterialType.tin,
      name: '주석',
      description: '구리와 섞어 청동을 만드는 금속.',
      baseProductionRate: 2.5,
    ),
    MaterialType.silver: MaterialData(
      type: MaterialType.silver,
      name: '은',
      description: '마법 전도율이 높은 귀금속.',
      baseProductionRate: 1.0,
    ),
    MaterialType.gold: MaterialData(
      type: MaterialType.gold,
      name: '금',
      description: '화려하고 가치 있는 귀금속.',
      baseProductionRate: 0.5,
    ),
    MaterialType.mythril: MaterialData(
      type: MaterialType.mythril,
      name: '미스릴',
      description: '가볍고 단단한 전설의 금속.',
      baseProductionRate: 0.1,
    ),
    MaterialType.cloth: MaterialData(
      type: MaterialType.cloth,
      name: '천',
      description: '기본적인 직물 재료.',
      baseProductionRate: 4.0,
    ),
    MaterialType.silk: MaterialData(
      type: MaterialType.silk,
      name: '비단',
      description: '부드럽고 고급스러운 천.',
      baseProductionRate: 1.5,
    ),
    MaterialType.herb: MaterialData(
      type: MaterialType.herb,
      name: '약초',
      description: '치유 성분이 있는 풀.',
      baseProductionRate: 3.0,
    ),
    MaterialType.root: MaterialData(
      type: MaterialType.root,
      name: '나무뿌리',
      description: '약재로 쓰이는 뿌리.',
      baseProductionRate: 2.0,
    ),
    MaterialType.flower: MaterialData(
      type: MaterialType.flower,
      name: '마력꽃',
      description: '마력을 머금은 꽃.',
      baseProductionRate: 1.0,
    ),
  };

  /// Get material data by type
  static MaterialData getByType(MaterialType type) {
    return allMaterials[type]!;
  }
}
