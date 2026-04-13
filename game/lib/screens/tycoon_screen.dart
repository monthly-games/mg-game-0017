import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/localization/localization.dart';
import 'package:flutter/material.dart' hide MaterialType;
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';
import 'package:mg_common_game/core/ui/theme/app_text_styles.dart';
import 'package:mg_common_game/l10n/localization.dart';


import '../features/materials/material_inventory.dart';
import '../features/materials/material_data.dart';
import '../features/economy/economy_manager.dart';
import '../features/crafting/crafting_manager.dart';
import '../features/crafting/recipe_data.dart';
import '../features/crafting/recipe_unlock.dart';
import '../features/shop/shop_manager.dart';
import '../features/stations/station_manager.dart';
import '../features/save/save_manager.dart';
import '../features/dungeon/dungeon_manager.dart';
import '../features/upgrades/upgrade_manager.dart';
import '../features/achievements/achievement_manager.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

class TycoonScreen extends StatefulWidget {
  const TycoonScreen({super.key});

  @override
  State<TycoonScreen> createState() => _TycoonScreenState();
}

class _TycoonScreenState extends State<TycoonScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
      });
    });

    // Start game loop for idle production
    _startGameLoop();
  }

  void _startGameLoop() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final inventory = context.read<MaterialInventory>();
        final crafting = context.read<CraftingManager>();
        final shop = context.read<ShopManager>();
        final dungeon = context.read<DungeonManager>();

        inventory.updateProduction(1.0); // 1 second
        crafting.update();
        shop.update();
        dungeon.update();

        _startGameLoop();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ui_general_dungeon_craft_tycoon'.tr),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: '저장',
            onPressed: () async {
              final saveManager = context.read<SaveManager>();
              final messenger = ScaffoldMessenger.of(context);
              final success = await saveManager.saveGame();
              if (success && mounted) {
                messenger.showSnackBar(const SnackBar(content: Text('ui_general_게임_저장_완료'.tr)));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: '불러오기',
            onPressed: () async {
              final saveManager = context.read<SaveManager>();
              final messenger = ScaffoldMessenger.of(context);
              final success = await saveManager.loadGame();
              if (success && mounted) {
                messenger.showSnackBar(const SnackBar(content: Text('ui_general_게임_불러오기_완료'.tr)));
              } else if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('ui_general_저장된_게임이_없습니다'.tr)),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.shield),
            tooltip: 'Guild War',
            onPressed: () =>
                Navigator.of(context).pushNamed('/guild-war'),
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events),
            tooltip: 'Tournament',
            onPressed: () =>
                Navigator.of(context).pushNamed('/tournament'),
          ),
          IconButton(
            icon: const Icon(Icons.celebration),
            tooltip: 'Seasonal Event',
            onPressed: () =>
                Navigator.of(context).pushNamed('/seasonal-event'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.inventory), text: '재료'),
            Tab(icon: Icon(Icons.build), text: '제작'),
            Tab(icon: Icon(Icons.store), text: '상점'),
            Tab(icon: Icon(Icons.upgrade), text: '업그레이드'),
            Tab(icon: Icon(Icons.explore), text: '던전'),
            Tab(icon: Icon(Icons.emoji_events), text: '업적'),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildCurrencyBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMaterialsTab(),
                _buildCraftingTab(),
                _buildShopTab(),
                _buildUpgradeTab(),
                _buildDungeonTab(),
                _buildAchievementsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyBar() {
    return Consumer<EconomyManager>(
      builder: (context, economy, child) {
        return Container(
          padding: const EdgeInsets.all(MGSpacing.md),
          margin: const EdgeInsets.all(MGSpacing.xs),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCurrencyItem(
                Icons.monetization_on,
                '골드',
                economy.gold,
                Colors.yellow,
              ),
              _buildCurrencyItem(
                Icons.diamond,
                '보석',
                economy.gems,
                Colors.cyan,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyItem(
    IconData icon,
    String label,
    int amount,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: MGSpacing.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(
              '$amount',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialsTab() {
    return Consumer<MaterialInventory>(
      builder: (context, inventory, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(MGSpacing.md),
          itemCount: MaterialType.values.length,
          itemBuilder: (context, index) {
            final type = MaterialType.values[index];
            final data = MaterialData.getByType(type);
            final amount = inventory.getMaterial(type);
            final rate = inventory.productionRates[type] ?? 0.0;

            return Card(
              color: AppColors.panel,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getMaterialColor(type).withValues(alpha: 0.3),
                  child: Icon(
                    _getMaterialIcon(type),
                    color: _getMaterialColor(type),
                  ),
                ),
                title: Text(data.name, style: AppTextStyles.body),
                subtitle: Text(
                  '${data.description}\n생산: ${rate.toStringAsFixed(1)}/초',
                  style: AppTextStyles.caption,
                ),
                trailing: Text(
                  amount.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCraftingTab() {
    return Consumer2<CraftingManager, MaterialInventory>(
      builder: (context, crafting, inventory, child) {
        final recipes = crafting.getUnlockedRecipes();

        return ListView.builder(
          padding: const EdgeInsets.all(MGSpacing.md),
          itemCount: CraftingStation.values.length,
          itemBuilder: (context, index) {
            final station = CraftingStation.values[index];
            final job = crafting.getJobForStation(station);
            final stationRecipes = recipes
                .where((r) => r.station == station)
                .toList();

            return _buildStationCard(
              station,
              job,
              stationRecipes,
              crafting,
              inventory,
            );
          },
        );
      },
    );
  }

  Widget _buildStationCard(
    CraftingStation station,
    CraftingJob? job,
    List<Recipe> recipes,
    CraftingManager crafting,
    MaterialInventory inventory,
  ) {
    return Card(
      color: AppColors.panel,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getStationIcon(station), color: AppColors.primary),
                const SizedBox(width: MGSpacing.xs),
                Text(_getStationName(station), style: AppTextStyles.header2),
              ],
            ),
            const SizedBox(height: MGSpacing.sm),

            // Active job or select recipe
            if (job != null && !job.isComplete) ...[
              Text('제작 중: ${job.recipe.name}', style: AppTextStyles.body),
              const SizedBox(height: MGSpacing.xs),
              LinearProgressIndicator(value: job.progress),
              const SizedBox(height: MGSpacing.xxs),
              Text(
                '남은 시간: ${job.remainingTime.inSeconds}초',
                style: AppTextStyles.caption,
              ),
            ] else if (job != null && job.isComplete) ...[
              Text(
                '완료: ${job.recipe.name}',
                style: const TextStyle(color: MGColors.success),
              ),
              const SizedBox(height: MGSpacing.xs),
              ElevatedButton(
                onPressed: () {
                  final item = crafting.completeCrafting(station);
                  if (item != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item.name} (${_getQualityName(item.quality)}) 제작 완료!',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('수령하기'),
              ),
            ] else ...[
              DropdownButton<Recipe>(
                isExpanded: true,
                hint: Text('ui_general_레시피_선택'.tr),
                items: recipes.map((recipe) {
                  final canCraft = crafting.canStartCrafting(recipe);
                  return DropdownMenuItem(
                    value: recipe,
                    child: Text(
                      '${recipe.name} (${recipe.craftingTime}초)',
                      style: TextStyle(
                        color: canCraft ? MGColors.textHighEmphasis : MGColors.common,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (recipe) {
                  if (recipe != null && crafting.startCrafting(recipe)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ui_general_recipename_제작_시작'.tr)),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShopTab() {
    return Consumer3<ShopManager, CraftingManager, EconomyManager>(
      builder: (context, shop, crafting, economy, child) {
        return Column(
          children: [
            // Customer info
            if (shop.currentCustomer != null) ...[
              Container(
                padding: const EdgeInsets.all(MGSpacing.md),
                margin: const EdgeInsets.all(MGSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MGColors.success),
                ),
                child: Column(
                  children: [
                    Text(
                      '고객: ${shop.currentCustomer!.name}',
                      style: AppTextStyles.header2,
                    ),
                    Text(
                      '예산: ${shop.currentCustomer!.budget.toInt()} 골드',
                      style: AppTextStyles.body,
                    ),
                    Text(
                      '남은 시간: ${shop.customerTimeRemaining.inSeconds}초',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],

            // Display slots
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(MGSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: shop.maxDisplaySlots,
                itemBuilder: (context, index) {
                  if (index < shop.displayedItems.length) {
                    final item = shop.displayedItems[index];
                    final interested =
                        shop.currentCustomer?.isInterested(item) ?? false;

                    return _buildDisplaySlot(item, interested, shop, economy);
                  } else {
                    return _buildEmptySlot(crafting, shop);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDisplaySlot(
    CraftedItem item,
    bool interested,
    ShopManager shop,
    EconomyManager economy,
  ) {
    return Card(
      color: interested ? MGColors.success.withValues(alpha: 0.2) : AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.all(MGSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.name,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            Text(
              _getQualityName(item.quality),
              style: TextStyle(color: _getQualityColor(item.quality)),
            ),
            Text(
              '${item.sellPrice} 골드',
              style: const TextStyle(color: Colors.yellow),
            ),
            if (interested)
              ElevatedButton(
                onPressed: () {
                  final price = shop.sellItem(item);
                  if (price != null) {
                    economy.addGold(price);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('shop_itemname_판매_price_골드'.tr)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: MGColors.success),
                child: Text('shop_재고_count개_판매가_itembasepriceg'.tr),
              )
            else
              TextButton(
                onPressed: () => shop.removeFromDisplay(item),
                child: const Text('회수'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot(CraftingManager crafting, ShopManager shop) {
    final items = crafting.completedItems;

    return Card(
      color: AppColors.surface,
      child: items.isEmpty
          ? const Center(
              child: Text('완성품 없음', style: TextStyle(color: MGColors.common)),
            )
          : DropdownButton<CraftedItem>(
              isExpanded: true,
              hint: Center(child: Text('ui_general_진열할_아이템'.tr)),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text('shop_itemname_itemsellpriceg'.tr),
                );
              }).toList(),
              onChanged: (item) {
                if (item != null) {
                  shop.displayItem(item);
                }
              },
            ),
    );
  }

  Widget _buildUpgradeTab() {
    return Consumer4<
      StationManager,
      MaterialInventory,
      EconomyManager,
      CraftingManager
    >(
      builder: (context, stations, inventory, economy, crafting, child) {
        return ListView(
          padding: const EdgeInsets.all(MGSpacing.md),
          children: [
            // Exploration Upgrades Section
            Text('탐험 업그레이드', style: AppTextStyles.header2),
            const SizedBox(height: MGSpacing.sm),
            Consumer<UpgradeManager>(
              builder: (context, upgrades, _) {
                return Column(
                  children: UpgradeType.values.map((type) {
                    final level = upgrades.getLevel(type);
                    final cost = upgrades.getUpgradeCost(type);
                    final canAfford = upgrades.canAfford(type);

                    String name;
                    String desc;
                    IconData icon;

                    switch (type) {
                      case UpgradeType.explorationSpeed:
                        name = '탐험 속도';
                        desc = '던전 탐험 시간이 10% 감소합니다.';
                        icon = Icons.speed;
                        break;
                      case UpgradeType.lootLuck:
                        name = '행운';
                        desc = '희귀 재료 발견 확률이 10% 증가합니다.';
                        icon = Icons.auto_awesome;
                        break;
                    }

                    return Card(
                      color: AppColors.panel,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(icon, color: Colors.amber),
                        title: Text('progress_name_lvlevel'.tr),
                        subtitle: Text(
                          '$desc\n비용: $cost 골드',
                          style: AppTextStyles.caption,
                        ),
                        isThreeLine: true,
                        trailing: ElevatedButton(
                          onPressed: canAfford
                              ? () {
                                  if (upgrades.buyUpgrade(type)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('ui_general_name_업그레이드_완료'.tr),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          child: Text('ui_general_탐험_업그레이드'.tr),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: MGSpacing.lg),

            // Station Upgrades Section
            Text('제작소 업그레이드', style: AppTextStyles.header2),
            const SizedBox(height: MGSpacing.sm),
            ...CraftingStation.values.map((station) {
              final data = stations.getStation(station);
              final canUpgrade = stations.canUpgrade(
                station,
                economy,
                inventory.hasMaterials,
              );

              return Card(
                color: AppColors.panel,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    _getStationIcon(station),
                    color: AppColors.primary,
                  ),
                  title: Text('progress_datagetname_lvdatalevel'.tr),
                  subtitle: Text(
                    '속도: +${(data.speedMultiplier * 100 - 100).toInt()}% | 품질: +${(data.qualityBonus * 100).toInt()}%\n'
                    '비용: ${data.getUpgradeCostGold()} 골드',
                    style: AppTextStyles.caption,
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: canUpgrade
                        ? () {
                            if (stations.upgradeStation(
                              station,
                              economy,
                              inventory.consumeMaterials,
                            )) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('ui_general_datagetname_업그레이드_완료'.tr),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text('ui_general_탐험_업그레이드'.tr),
                  ),
                ),
              );
            }),

            const SizedBox(height: MGSpacing.lg),

            // Recipe Unlocks Section
            Text('레시피 해금', style: AppTextStyles.header2),
            const SizedBox(height: MGSpacing.sm),
            ...crafting
                .getAvailableUnlocks(economy.gold ~/ 100, economy.gold)
                .map((recipe) {
                  final requirement = RecipeUnlocks.getRequirement(recipe.id);
                  if (requirement == null) return const SizedBox.shrink();

                  return Card(
                    color: AppColors.panel,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getTierColor(recipe.tier),
                        child: Text(
                          _getTierShort(recipe.tier),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      title: Text(recipe.name),
                      subtitle: Text(
                        '${recipe.description}\n비용: ${requirement.goldCost} 골드',
                        style: AppTextStyles.caption,
                      ),
                      isThreeLine: true,
                      trailing: ElevatedButton(
                        onPressed: () {
                          if (crafting.unlockRecipeWithGold(
                            recipe.id,
                            economy.gold ~/ 100,
                            economy.gold,
                            (amount) => economy.trySpendGold(amount),
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ui_general_recipename_레시피_해금'.tr)),
                            );
                          }
                        },
                        child: Text('ui_general_레시피_해금'.tr),
                      ),
                    ),
                  );
                }),
          ],
        );
      },
    );
  }

  Color _getMaterialColor(MaterialType type) {
    switch (type) {
      case MaterialType.ironOre:
        return MGColors.common;
      case MaterialType.wood:
        return Colors.brown;
      case MaterialType.leather:
        return MGColors.warning;
      case MaterialType.magicStone:
        return Colors.purple;
      case MaterialType.rareGem:
        return Colors.cyan;
      default:
        return MGColors.common;
    }
  }

  IconData _getMaterialIcon(MaterialType type) {
    switch (type) {
      case MaterialType.ironOre:
        return Icons.landscape;
      case MaterialType.wood:
        return Icons.forest;
      case MaterialType.leather:
        return Icons.checkroom;
      case MaterialType.magicStone:
        return Icons.auto_fix_high;
      case MaterialType.rareGem:
        return Icons.diamond;
      default:
        return Icons.inventory_2;
    }
  }

  IconData _getStationIcon(CraftingStation station) {
    switch (station) {
      case CraftingStation.workbench:
        return Icons.construction;
      case CraftingStation.furnace:
        return Icons.local_fire_department;
      case CraftingStation.anvil:
        return Icons.gavel;
      case CraftingStation.alchemyTable:
        return Icons.science;
      case CraftingStation.enchanting:
        return Icons.auto_awesome;
    }
  }

  String _getStationName(CraftingStation station) {
    switch (station) {
      case CraftingStation.workbench:
        return '작업대';
      case CraftingStation.furnace:
        return '용광로';
      case CraftingStation.anvil:
        return '대장간';
      case CraftingStation.alchemyTable:
        return '연금술대';
      case CraftingStation.enchanting:
        return '마법부여대';
    }
  }

  Color _getTierColor(RecipeTier tier) {
    switch (tier) {
      case RecipeTier.basic:
        return MGColors.common;
      case RecipeTier.intermediate:
        return MGColors.success;
      case RecipeTier.advanced:
        return MGColors.info;
      case RecipeTier.master:
        return Colors.purple;
      case RecipeTier.legendary:
        return MGColors.warning;
    }
  }

  String _getTierShort(RecipeTier tier) {
    switch (tier) {
      case RecipeTier.basic:
        return '기본';
      case RecipeTier.intermediate:
        return '중급';
      case RecipeTier.advanced:
        return '고급';
      case RecipeTier.master:
        return '마스터';
      case RecipeTier.legendary:
        return '전설';
    }
  }

  String _getQualityName(Quality quality) {
    switch (quality) {
      case Quality.normal:
        return '일반';
      case Quality.good:
        return '양호';
      case Quality.excellent:
        return '우수';
      case Quality.masterpiece:
        return '걸작';
    }
  }

  Color _getQualityColor(Quality quality) {
    switch (quality) {
      case Quality.normal:
        return MGColors.common;
      case Quality.good:
        return MGColors.success;
      case Quality.excellent:
        return MGColors.info;
      case Quality.masterpiece:
        return Colors.purple;
    }
  }

  Widget _buildDungeonTab() {
    return Consumer<DungeonManager>(
      builder: (context, dungeon, child) {
        final session = dungeon.activeSession;

        return ListView(
          padding: const EdgeInsets.all(MGSpacing.md),
          children: [
            // Active session
            if (session != null) ...[
              Card(
                color: AppColors.panel,
                child: Padding(
                  padding: const EdgeInsets.all(MGSpacing.md),
                  child: Column(
                    children: [
                      Text(
                        '${dungeon.getDungeonName(session.depth)} 탐험 중',
                        style: AppTextStyles.header2,
                      ),
                      const SizedBox(height: MGSpacing.sm),
                      LinearProgressIndicator(value: session.progress),
                      const SizedBox(height: MGSpacing.xs),
                      Text(
                        '남은 시간: ${session.remainingTime.inSeconds}초',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: MGSpacing.sm),
                      if (session.isComplete)
                        ElevatedButton(
                          onPressed: () {
                            final rewards = dungeon.completeExploration();
                            if (rewards.isNotEmpty && mounted) {
                              final rewardText = rewards.entries
                                  .map(
                                    (e) =>
                                        '${MaterialData.getByType(e.key).name} ${e.value}개',
                                  )
                                  .join(', ');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('notification_획득_rewardtext'.tr)),
                              );
                            }
                          },
                          child: Text('ui_general_보상_수령'.tr),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: MGSpacing.md),
            ],

            // Dungeon options
            Text('던전 선택', style: AppTextStyles.header2),
            const SizedBox(height: MGSpacing.sm),
            ...[1, 2, 3].map((depth) {
              final unlocked = dungeon.isDepthUnlocked(depth);
              final canExplore = dungeon.canExplore() && unlocked;

              return Card(
                color: AppColors.panel,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    Icons.explore,
                    color: unlocked ? AppColors.primary : MGColors.common,
                  ),
                  title: Text(dungeon.getDungeonName(depth)),
                  subtitle: Text(
                    dungeon.getDungeonDescription(depth),
                    style: AppTextStyles.caption,
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: canExplore
                        ? () {
                            dungeon.startExploration(depth);
                          }
                        : null,
                    child: Text(unlocked ? '탐험' : '잠김'),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAchievementsTab() {
    return Consumer2<AchievementManager, EconomyManager>(
      builder: (context, achievements, economy, child) {
        final unclaimed = achievements.unclaimedAchievements;

        return ListView(
          padding: const EdgeInsets.all(MGSpacing.md),
          children: [
            // Summary
            Card(
              color: AppColors.panel,
              child: Padding(
                padding: const EdgeInsets.all(MGSpacing.md),
                child: Column(
                  children: [
                    Text('업적 진행도', style: AppTextStyles.header2),
                    const SizedBox(height: MGSpacing.sm),
                    Text(
                      '${achievements.completedAchievements} / ${achievements.totalAchievements} 달성',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: MGSpacing.xs),
                    if (unclaimed.isNotEmpty)
                      Text(
                        '수령 대기중: ${unclaimed.length}개',
                        style: TextStyle(color: MGColors.warning),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: MGSpacing.md),

            // Achievements list
            Text('업적 목록', style: AppTextStyles.header2),
            const SizedBox(height: MGSpacing.sm),
            ...achievements.allProgress.map((progress) {
              final canClaim = progress.canClaim;
              final claimed = progress.claimed;

              return Card(
                color: claimed ? AppColors.background : AppColors.panel,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    claimed ? Icons.check_circle : Icons.emoji_events,
                    color: claimed
                        ? MGColors.success
                        : (canClaim ? MGColors.warning : MGColors.common),
                  ),
                  title: Text(progress.achievement.name),
                  subtitle: Text(
                    '${progress.achievement.description}\n'
                    '진행: ${progress.currentValue} / ${progress.achievement.targetValue}\n'
                    '보상: ${progress.achievement.reward.gold} 골드, ${progress.achievement.reward.gems} 보석',
                    style: AppTextStyles.caption,
                  ),
                  isThreeLine: true,
                  trailing: canClaim
                      ? ElevatedButton(
                          onPressed: () {
                            final reward = achievements.claimAchievement(
                              progress.achievement.id,
                            );
                            if (reward != null) {
                              economy.addGold(reward.gold);
                              economy.addGems(reward.gems);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '보상 획득: ${reward.gold} 골드, ${reward.gems} 보석',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text('ui_general_보상_수령'.tr),
                        )
                      : (claimed
                            ? const Icon(Icons.check, color: MGColors.success)
                            : null),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
