/// Material types available in the game
enum MaterialType {
  ironOre,    // 철광석
  wood,       // 나무
  leather,    // 가죽
  magicStone, // 마법석
  rareGem,    // 희귀 보석
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
  };

  /// Get material data by type
  static MaterialData getByType(MaterialType type) {
    return allMaterials[type]!;
  }
}
