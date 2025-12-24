/// 가챠 시스템 어댑터 - MG-0017 Dungeon Craft
library;

import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/gacha/gacha_config.dart';
import 'package:mg_common_game/systems/gacha/gacha_manager.dart';

/// 게임 내 Equipment 모델
class Equipment {
  final String id;
  final String name;
  final GachaRarity rarity;
  final Map<String, dynamic> stats;

  const Equipment({
    required this.id,
    required this.name,
    required this.rarity,
    this.stats = const {},
  });
}

/// Dungeon Craft 가챠 어댑터
class EquipmentGachaAdapter extends ChangeNotifier {
  final GachaManager _gachaManager = GachaManager(
    pityConfig: const PityConfig(
      softPityStart: 70,
      hardPity: 80,
      softPityBonus: 6.0,
    ),
    multiPullGuarantee: const MultiPullGuarantee(
      minRarity: GachaRarity.rare,
    ),
  );

  static const String _poolId = 'dungeoncraft_pool';

  EquipmentGachaAdapter() {
    _initPool();
  }

  void _initPool() {
    final pool = GachaPool(
      id: _poolId,
      name: 'Dungeon Craft 가챠',
      items: _generateItems(),
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 365)),
    );
    _gachaManager.registerPool(pool);
  }

  List<GachaItem> _generateItems() {
    return [
      // UR (0.6%)
      GachaItem(id: 'ur_dungeoncraft_001', name: '전설의 Equipment', rarity: GachaRarity.ultraRare, weight: 1.0),
      GachaItem(id: 'ur_dungeoncraft_002', name: '신화의 Equipment', rarity: GachaRarity.ultraRare, weight: 1.0),
      // SSR (2.4%)
      GachaItem(id: 'ssr_dungeoncraft_001', name: '영웅의 Equipment', rarity: GachaRarity.superSuperRare, weight: 1.0),
      GachaItem(id: 'ssr_dungeoncraft_002', name: '고대의 Equipment', rarity: GachaRarity.superSuperRare, weight: 1.0),
      GachaItem(id: 'ssr_dungeoncraft_003', name: '황금의 Equipment', rarity: GachaRarity.superSuperRare, weight: 1.0),
      // SR (12%)
      GachaItem(id: 'sr_dungeoncraft_001', name: '희귀한 Equipment A', rarity: GachaRarity.superRare, weight: 1.0),
      GachaItem(id: 'sr_dungeoncraft_002', name: '희귀한 Equipment B', rarity: GachaRarity.superRare, weight: 1.0),
      GachaItem(id: 'sr_dungeoncraft_003', name: '희귀한 Equipment C', rarity: GachaRarity.superRare, weight: 1.0),
      GachaItem(id: 'sr_dungeoncraft_004', name: '희귀한 Equipment D', rarity: GachaRarity.superRare, weight: 1.0),
      // R (35%)
      GachaItem(id: 'r_dungeoncraft_001', name: '우수한 Equipment A', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_dungeoncraft_002', name: '우수한 Equipment B', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_dungeoncraft_003', name: '우수한 Equipment C', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_dungeoncraft_004', name: '우수한 Equipment D', rarity: GachaRarity.rare, weight: 1.0),
      GachaItem(id: 'r_dungeoncraft_005', name: '우수한 Equipment E', rarity: GachaRarity.rare, weight: 1.0),
      // N (50%)
      GachaItem(id: 'n_dungeoncraft_001', name: '일반 Equipment A', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_dungeoncraft_002', name: '일반 Equipment B', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_dungeoncraft_003', name: '일반 Equipment C', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_dungeoncraft_004', name: '일반 Equipment D', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_dungeoncraft_005', name: '일반 Equipment E', rarity: GachaRarity.normal, weight: 1.0),
      GachaItem(id: 'n_dungeoncraft_006', name: '일반 Equipment F', rarity: GachaRarity.normal, weight: 1.0),
    ];
  }

  /// 단일 뽑기
  Equipment? pullSingle() {
    final result = _gachaManager.pull(_poolId);
    if (result == null) return null;
    notifyListeners();
    return _convertToItem(result);
  }

  /// 10연차
  List<Equipment> pullTen() {
    final results = _gachaManager.pullMulti(_poolId, 10);
    notifyListeners();
    return results.map(_convertToItem).toList();
  }

  Equipment _convertToItem(GachaItem item) {
    return Equipment(
      id: item.id,
      name: item.name,
      rarity: item.rarity,
    );
  }

  /// 천장까지 남은 횟수
  int get pullsUntilPity => _gachaManager.pullsUntilPity(_poolId);

  /// 총 뽑기 횟수
  int get totalPulls => _gachaManager.getTotalPulls(_poolId);

  /// 통계
  Map<GachaRarity, int> get stats => _gachaManager.getStatistics(_poolId);

  Map<String, dynamic> toJson() => _gachaManager.toJson();
  void loadFromJson(Map<String, dynamic> json) {
    _gachaManager.loadFromJson(json);
    notifyListeners();
  }
}
