import 'package:flutter/material.dart';

/// Decoration category
enum DecorationType {
  theme,       // Shop theme
  counter,     // Counter decoration
  floor,       // Floor pattern
  wall,        // Wall decoration
  lighting,    // Lighting
}

/// Decoration item
class Decoration {
  final String id;
  final String name;
  final String description;
  final DecorationType type;
  final int goldCost;
  final int? gemCost;
  final Color primaryColor;
  final Color? secondaryColor;

  const Decoration({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.goldCost,
    this.gemCost,
    required this.primaryColor,
    this.secondaryColor,
  });
}

/// All decorations
class Decorations {
  // Themes
  static const Decoration classicTheme = Decoration(
    id: 'theme_classic',
    name: '클래식',
    description: '전통적인 대장간 분위기',
    type: DecorationType.theme,
    goldCost: 0,
    primaryColor: Color(0xFF8B4513),
    secondaryColor: Color(0xFF654321),
  );

  static const Decoration modernTheme = Decoration(
    id: 'theme_modern',
    name: '모던',
    description: '현대적이고 깔끔한 디자인',
    type: DecorationType.theme,
    goldCost: 500,
    primaryColor: Color(0xFF2C3E50),
    secondaryColor: Color(0xFF34495E),
  );

  static const Decoration mysticTheme = Decoration(
    id: 'theme_mystic',
    name: '신비',
    description: '마법 같은 신비로운 분위기',
    type: DecorationType.theme,
    goldCost: 1000,
    primaryColor: Color(0xFF9B59B6),
    secondaryColor: Color(0xFF8E44AD),
  );

  static const Decoration royalTheme = Decoration(
    id: 'theme_royal',
    name: '로얄',
    description: '왕실의 화려한 장식',
    type: DecorationType.theme,
    goldCost: 2000,
    gemCost: 10,
    primaryColor: Color(0xFFFFD700),
    secondaryColor: Color(0xFFFFA500),
  );

  // Counter decorations
  static const Decoration woodCounter = Decoration(
    id: 'counter_wood',
    name: '나무 카운터',
    description: '기본 나무 카운터',
    type: DecorationType.counter,
    goldCost: 0,
    primaryColor: Color(0xFF8B4513),
  );

  static const Decoration marbleCounter = Decoration(
    id: 'counter_marble',
    name: '대리석 카운터',
    description: '고급스러운 대리석',
    type: DecorationType.counter,
    goldCost: 300,
    primaryColor: Color(0xFFE8E8E8),
  );

  static const Decoration crystalCounter = Decoration(
    id: 'counter_crystal',
    name: '크리스탈 카운터',
    description: '빛나는 크리스탈 카운터',
    type: DecorationType.counter,
    goldCost: 800,
    gemCost: 5,
    primaryColor: Color(0xFF00CED1),
  );

  // Floor patterns
  static const Decoration stoneFloor = Decoration(
    id: 'floor_stone',
    name: '석재 바닥',
    description: '튼튼한 돌 바닥',
    type: DecorationType.floor,
    goldCost: 0,
    primaryColor: Color(0xFF808080),
  );

  static const Decoration woodFloor = Decoration(
    id: 'floor_wood',
    name: '원목 바닥',
    description: '따뜻한 느낌의 나무 바닥',
    type: DecorationType.floor,
    goldCost: 200,
    primaryColor: Color(0xFFD2691E),
  );

  static const Decoration carpetFloor = Decoration(
    id: 'floor_carpet',
    name: '카펫 바닥',
    description: '부드러운 카펫',
    type: DecorationType.floor,
    goldCost: 600,
    primaryColor: Color(0xFFDC143C),
  );

  // Wall decorations
  static const Decoration plainWall = Decoration(
    id: 'wall_plain',
    name: '일반 벽',
    description: '기본 벽',
    type: DecorationType.wall,
    goldCost: 0,
    primaryColor: Color(0xFFD3D3D3),
  );

  static const Decoration brickWall = Decoration(
    id: 'wall_brick',
    name: '벽돌 벽',
    description: '클래식한 벽돌 벽',
    type: DecorationType.wall,
    goldCost: 250,
    primaryColor: Color(0xFFB22222),
  );

  static const Decoration tapestryWall = Decoration(
    id: 'wall_tapestry',
    name: '태피스트리',
    description: '화려한 벽걸이 장식',
    type: DecorationType.wall,
    goldCost: 700,
    gemCost: 3,
    primaryColor: Color(0xFF4B0082),
  );

  // Lighting
  static const Decoration torchLight = Decoration(
    id: 'light_torch',
    name: '횃불',
    description: '기본 조명',
    type: DecorationType.lighting,
    goldCost: 0,
    primaryColor: Color(0xFFFF6347),
  );

  static const Decoration lanternLight = Decoration(
    id: 'light_lantern',
    name: '랜턴',
    description: '부드러운 빛의 랜턴',
    type: DecorationType.lighting,
    goldCost: 150,
    primaryColor: Color(0xFFFFE4B5),
  );

  static const Decoration crystalLight = Decoration(
    id: 'light_crystal',
    name: '크리스탈 조명',
    description: '마법의 크리스탈 빛',
    type: DecorationType.lighting,
    goldCost: 500,
    gemCost: 5,
    primaryColor: Color(0xFF87CEEB),
  );

  static List<Decoration> getAllByType(DecorationType type) {
    return all.where((d) => d.type == type).toList();
  }

  static Decoration? getById(String id) {
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  static const List<Decoration> all = [
    // Themes
    classicTheme,
    modernTheme,
    mysticTheme,
    royalTheme,
    // Counters
    woodCounter,
    marbleCounter,
    crystalCounter,
    // Floors
    stoneFloor,
    woodFloor,
    carpetFloor,
    // Walls
    plainWall,
    brickWall,
    tapestryWall,
    // Lighting
    torchLight,
    lanternLight,
    crystalLight,
  ];
}
