# MG-0017 개발 진척도

**게임명 (설계)**: 던전 크래프트 타이쿤 (Dungeon Craft Tycoon)
**게임명 (실제)**: 네온 레이서 (Neon Racer) ⚠️
**장르 (설계)**: 제작/크래프팅 + 방치 생산 + 경영
**장르 (실제)**: 아케이드 장애물 회피 게임
**시작일**: 2025-07-01
**현재 진척도**: 20% (잘못된 게임 구현)

---

## ⚠️ 중요 이슈

**CRITICAL**: 이 프로젝트는 **잘못된 게임이 구현된 상태**입니다.

- **GDD 설계**: 던전 크래프트 타이쿤 (제작/크래프팅/상점 경영)
- **실제 코드**: 네온 레이서 (아케이드 장애물 회피)
- **상태**: 완전히 다른 게임이 구현됨

### 가능한 원인
1. 다른 프로젝트 코드가 잘못 복사됨
2. 프로토타입 테스트용 코드가 남아있음
3. 템플릿/보일러플레이트 코드 미교체

### 필요한 조치
**전체 재구현 필요** - 현재 코드를 삭제하고 GDD에 따라 새로 구현해야 함

---

## 🎯 GDD 설계 내용 (의도된 게임)

### 핵심 게임플레이
1. **재료 수집**: 던전 탐험과 방치 생산으로 다양한 재료 획득
2. **아이템 제작**: 레시피를 따라 무기, 방어구, 소모품 제작
3. **상점 운영**: 제작한 아이템을 모험가들에게 판매
4. **제작소 업그레이드**: 작업대, 용광로 등 제작 설비 개선

### 핵심 차별점
- 복잡한 제작 시스템 (5단계 레시피)
- 방치형 경영과 능동적 제작의 결합
- 품질 시스템 (일반/양호/우수/걸작)
- 다양한 제작소 (작업대, 용광로, 대장간, 연금술대, 마법부여대)

### 경제 시스템
- **골드**: 소프트 화폐 (아이템 판매, 방치 수익)
- **보석**: 하드 화폐 (IAP, 업적)
- **재료**: 철광석, 나무, 가죽, 마법석, 희귀 보석

---

## 💻 실제 구현 내용 (잘못된 게임)

### 1. 게임 엔진 (80%)
- ✅ Flame 엔진 통합
- ✅ Provider 상태 관리
- ✅ GetIt DI 설정
- ✅ AudioManager 통합 (mg_common_game)
- ✅ AppColors 테마 통합
- ✅ 게임 루프 (update/render)

**파일**:
- [main.dart](../game/lib/main.dart)
- [racer_game.dart](../game/lib/game/racer_game.dart)

### 2. 네온 레이서 게임 (100% 완성) ⚠️
잘못 구현된 게임이지만 기능적으로는 완성됨.

- ✅ 플레이어 우주선 컴포넌트
  - 키보드 조작 (화살표 키)
  - 삼각형 형태 렌더링
  - 충돌 감지
  - 엔진 파티클 효과
- ✅ 장애물 시스템
  - 랜덤 생성 (난이도 증가)
  - 충돌 감지
  - 화면 밖 제거
- ✅ 점수 시스템
  - 시간 기반 점수 증가
  - HUD 표시
- ✅ 게임 오버
  - 충돌 감지
  - 폭발 효과
  - 재시작 UI

**파일**:
- [player_ship.dart](../game/lib/features/player/player_ship.dart)
- [ship_engine_particles.dart](../game/lib/features/player/ship_engine_particles.dart)
- [obstacle_manager.dart](../game/lib/features/obstacles/obstacle_manager.dart)
- [obstacle.dart](../game/lib/features/obstacles/obstacle.dart)
- [game_over_overlay.dart](../game/lib/features/overlays/game_over_overlay.dart)

---

## ⬜ 미구현 기능 (GDD 기준)

### 1. 제작 시스템 (0%) ⭐ 핵심!
전혀 구현되지 않음.

**구현 필요 항목**:
```dart
// 1. Recipe Data Model
class Recipe {
  String id;
  String name;
  RecipeTier tier; // basic, intermediate, advanced, master, legendary
  CraftingStation station; // workbench, furnace, anvil, etc.
  Map<MaterialType, int> requiredMaterials; // 필요 재료
  ItemType outputItem; // 결과물
  int craftingTime; // 제작 시간 (초)
  double baseQualityChance; // 품질 확률
}

enum RecipeTier { basic, intermediate, advanced, master, legendary }

enum CraftingStation {
  workbench,    // 작업대
  furnace,      // 용광로
  anvil,        // 대장간
  alchemyTable, // 연금술대
  enchanting    // 마법부여대
}

// 2. Item System
class CraftedItem {
  String id;
  ItemType type; // weapon, armor, consumable
  Quality quality; // normal, good, excellent, masterpiece
  int basePrice; // 기본 가격
  double sellPriceMultiplier; // 품질에 따른 가격 배수
}

enum Quality { normal, good, excellent, masterpiece }

// 3. Crafting Manager
class CraftingManager extends ChangeNotifier {
  List<Recipe> unlockedRecipes = [];
  Map<String, CraftingJob> activeCraftingJobs = {};

  void startCrafting(Recipe recipe, CraftingStation station);
  void completeCrafting(String jobId);
  Quality rollQuality(double baseChance);
  CraftedItem createItem(Recipe recipe, Quality quality);
}
```

### 2. 재료 시스템 (0%)
재료 수집 및 관리.

**구현 필요 항목**:
```dart
enum MaterialType {
  ironOre,    // 철광석
  wood,       // 나무
  leather,    // 가죽
  magicStone, // 마법석
  rareGem     // 희귀 보석
}

class MaterialInventory extends ChangeNotifier {
  Map<MaterialType, int> materials = {};

  void addMaterial(MaterialType type, int amount);
  bool hasMaterials(Map<MaterialType, int> required);
  void consumeMaterials(Map<MaterialType, int> required);
}

// 방치 생산 시스템
class IdleProduction extends ChangeNotifier {
  Map<MaterialType, double> productionRate = {}; // 초당 생산량

  void updateProduction(double dt);
  void upgradeProductionRate(MaterialType type, double increase);
}
```

### 3. 상점 경영 시스템 (0%)
모험가 NPC에게 아이템 판매.

**구현 필요 항목**:
```dart
// 1. Shop System
class Shop extends ChangeNotifier {
  List<CraftedItem> displayItems = []; // 진열대
  int maxDisplaySlots = 5; // 진열 가능 수

  void displayItem(CraftedItem item);
  void sellItem(CraftedItem item);
  void expandShop(int additionalSlots);
}

// 2. Customer System
class Customer {
  String name;
  ItemType desiredType;
  Quality minQuality;
  double budget;

  bool isInterested(CraftedItem item);
  void buyItem(CraftedItem item);
}

class CustomerManager extends ChangeNotifier {
  void spawnCustomer();
  void processCustomerVisit(Customer customer, Shop shop);
}
```

### 4. 제작소 업그레이드 시스템 (0%)
제작 설비 개선.

**구현 필요 항목**:
```dart
class CraftingStationData {
  CraftingStation type;
  int level;
  double craftingSpeedMultiplier; // 제작 속도 배수
  double qualityBonus; // 품질 보너스
  int upgradeCostGold;
  Map<MaterialType, int> upgradeCostMaterials;

  void upgrade();
}

class StationManager extends ChangeNotifier {
  Map<CraftingStation, CraftingStationData> stations = {};

  void upgradeStation(CraftingStation station);
  bool canUpgrade(CraftingStation station);
}
```

### 5. 던전 탐험 시스템 (0%)
재료를 획득하는 미니게임/자동 시스템.

**구현 필요 항목**:
- 간단한 던전 탐험 미니게임 또는 방치형 탐험
- 재료 드롭 시스템
- 탐험 레벨 및 난이도
- 보상 확률

### 6. 레시피 해금 시스템 (0%)
상점 확장에 따른 레시피 언락.

**구현 필요 항목**:
- 레시피 트리/진행도
- 해금 조건 (골드, 상점 레벨, 특정 아이템 제작)
- 레시피 UI (도감)

### 7. 화폐 및 경제 시스템 (0%)
골드/보석 관리.

**구현 필요 항목**:
```dart
class Economy extends ChangeNotifier {
  int gold = 0;
  int gems = 0;

  // 골드 획득/소비
  void earnGold(int amount);
  bool spendGold(int amount);

  // 보석 획득/소비 (IAP)
  void earnGems(int amount);
  bool spendGems(int amount);

  // 방치 수익
  void calculateIdleIncome(Duration offlineTime);
}
```

### 8. UI/UX (0%)
타이쿤 게임 UI.

**필요한 화면**:
- 메인 상점 화면 (진열대, 제작소)
- 제작 메뉴 (레시피 선택, 재료 확인)
- 재료 인벤토리
- 상점 업그레이드 메뉴
- 고객 방문 알림
- 레시피 도감

---

## 📋 우선순위별 작업 목록

### 우선순위 0: 프로젝트 정리 (긴급)
1. ⬜ **잘못된 코드 제거**
   - 네온 레이서 관련 파일 전부 삭제
   - game/lib/features/ 폴더 정리
   - game/lib/game/racer_game.dart 삭제
2. ⬜ **프로젝트 재설정**
   - 새로운 main.dart 구조
   - 타이쿤 게임 기본 구조 설정

### 우선순위 1: 핵심 게임 루프 구현
1. ⬜ **재료 시스템**
   - MaterialInventory
   - 기본 재료 5종 (철광석, 나무, 가죽, 마법석, 희귀 보석)
   - 재료 획득 (임시로 버튼 클릭)
2. ⬜ **제작 시스템**
   - Recipe 데이터 모델
   - 10개 기본 레시피 (basic/intermediate)
   - CraftingManager
   - 제작 UI (레시피 선택, 제작 시작)
3. ⬜ **아이템 시스템**
   - CraftedItem 모델
   - Quality 시스템
   - 아이템 인벤토리
4. ⬜ **상점 판매 시스템**
   - Shop 진열대
   - 간단한 고객 시스템 (자동 구매)
   - 골드 획득

### 우선순위 2: 방치형 메커니즘
1. ⬜ **방치 재료 생산**
   - IdleProduction
   - 시간 기반 재료 자동 생성
   - 오프라인 수익 계산
2. ⬜ **제작소 시스템**
   - 5개 제작소 구현
   - 제작소 레벨 및 업그레이드
   - 제작 속도/품질 보너스
3. ⬜ **레시피 해금**
   - 레시피 트리
   - 해금 조건
   - 레시피 도감 UI

### 우선순위 3: 경영 확장
1. ⬜ **상점 확장**
   - 진열대 슬롯 확장
   - 상점 레벨 시스템
   - 상점 꾸미기
2. ⬜ **고객 다양화**
   - 다양한 고객 타입
   - 선호 아이템
   - 가격 협상
3. ⬜ **던전 탐험 (선택)**
   - 간단한 탐험 미니게임 또는
   - 자동 탐험 시스템

### 우선순위 4: 수익화 및 폴리싱
1. ⬜ **보석 시스템 (하드 화폐)**
   - IAP 통합
   - 즉시 제작
   - 희귀 레시피
2. ⬜ **광고 통합**
   - 보상형 광고 (제작 완료, 재료 2배)
3. ⬜ **UI/UX 개선**
   - 애니메이션
   - 파티클 효과
   - 사운드

---

## 📊 진척도 요약

| 시스템 | 진척도 | 상태 |
|--------|--------|------|
| 게임 엔진 | 80% | 🚧 준비됨 |
| **제작 시스템** | 0% | ⬜ 미착수 ⭐ |
| **재료 시스템** | 0% | ⬜ 미착수 ⭐ |
| **상점 경영** | 0% | ⬜ 미착수 ⭐ |
| 제작소 업그레이드 | 0% | ⬜ 미착수 |
| 레시피 해금 | 0% | ⬜ 미착수 |
| 던전 탐험 | 0% | ⬜ 미착수 |
| 방치 수익 | 0% | ⬜ 미착수 |
| 화폐 시스템 | 0% | ⬜ 미착수 |
| UI/UX (타이쿤) | 0% | ⬜ 미착수 |
| **네온 레이서 (잘못된 게임)** | 100% | ❌ 삭제 필요 |

**전체 진척도**: 20% (엔진만 준비, 게임 로직 0%)

---

## 🐛 알려진 이슈

1. **잘못된 게임 구현 (CRITICAL)**: 네온 레이서가 구현되어 있음, 던전 크래프트 타이쿤이 아님
2. **GDD 불일치**: 코드와 설계 문서가 완전히 다름
3. **게임 로직 부재**: 타이쿤 관련 코드 0%
4. **프로젝트 재설정 필요**: 전체 재구현 필요

---

## 📝 다음 작업

### 현재 상태
- **엔진**: Flutter + Flame 준비 완료
- **문제**: 잘못된 게임(네온 레이서)이 구현됨
- **필요**: 전체 코드 삭제 후 GDD에 따라 재구현

### 긴급 조치
1. **잘못된 코드 전체 제거**
   - player/, obstacles/, overlays/ 폴더 삭제
   - racer_game.dart 삭제
2. **프로젝트 재설정**
   - 타이쿤 게임 기본 구조 설정
   - main.dart 재작성
3. **핵심 시스템 구현 시작**
   - 재료 시스템
   - 제작 시스템
   - 상점 시스템

### 예상 일정
- **1주차**: 잘못된 코드 제거 + 기본 구조 재설정
- **2-3주차**: 재료 + 제작 + 상점 시스템 구현
- **4-6주차**: 방치형 메커니즘 + 제작소 업그레이드
- **7-8주차**: UI/UX 개선 + 수익화 통합

---

## 📚 관련 문서

- [GDD](design/gdd_game_0017.json) - 던전 크래프트 타이쿤 설계
- Economy Design - (파일 없음, 생성 필요)
- Level Design - (파일 없음, 생성 필요)

---

**작성일**: 2025-12-17
**버전**: 1.0
**작성자**: Claude Code (MG Development Assistant)

**⚠️ 주의**: 이 프로젝트는 잘못된 게임이 구현되어 전체 재구현이 필요합니다.
