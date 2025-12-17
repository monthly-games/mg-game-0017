import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';

import '../features/materials/material_inventory.dart';
import '../features/materials/material_data.dart';
import '../features/economy/economy_manager.dart';
import '../features/crafting/crafting_manager.dart';
import '../features/crafting/recipe_data.dart';
import '../features/crafting/recipe_unlock.dart';
import '../features/shop/shop_manager.dart';
import '../features/stations/station_manager.dart';

class TycoonScreen extends StatefulWidget {
  const TycoonScreen({super.key});

  @override
  State<TycoonScreen> createState() => _TycoonScreenState();
}

class _TycoonScreenState extends State<TycoonScreen> with TickerProviderStateMixin {
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
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

        inventory.updateProduction(1.0); // 1 second
        crafting.update();
        shop.update();

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
        title: const Text('Dungeon Craft Tycoon'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inventory), text: '재료'),
            Tab(icon: Icon(Icons.build), text: '제작'),
            Tab(icon: Icon(Icons.store), text: '상점'),
            Tab(icon: Icon(Icons.upgrade), text: '업그레이드'),
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
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCurrencyItem(Icons.monetization_on, '골드', economy.gold, Colors.yellow),
              _buildCurrencyItem(Icons.diamond, '보석', economy.gems, Colors.cyan),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrencyItem(IconData icon, String label, int amount, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text('$amount', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialsTab() {
    return Consumer<MaterialInventory>(
      builder: (context, inventory, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
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
                  backgroundColor: _getMaterialColor(type).withOpacity(0.3),
                  child: Icon(_getMaterialIcon(type), color: _getMaterialColor(type)),
                ),
                title: Text(data.name, style: AppTextStyles.body),
                subtitle: Text(
                  '${data.description}\n생산: ${rate.toStringAsFixed(1)}/초',
                  style: AppTextStyles.caption,
                ),
                trailing: Text(
                  amount.toInt().toString(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          padding: const EdgeInsets.all(16),
          itemCount: CraftingStation.values.length,
          itemBuilder: (context, index) {
            final station = CraftingStation.values[index];
            final job = crafting.getJobForStation(station);
            final stationRecipes = recipes.where((r) => r.station == station).toList();

            return _buildStationCard(station, job, stationRecipes, crafting, inventory);
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getStationIcon(station), color: AppColors.primary),
                const SizedBox(width: 8),
                Text(_getStationName(station), style: AppTextStyles.header3),
              ],
            ),
            const SizedBox(height: 12),

            // Active job or select recipe
            if (job != null && !job.isComplete) ...[
              Text('제작 중: ${job.recipe.name}', style: AppTextStyles.body),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: job.progress),
              const SizedBox(height: 4),
              Text('남은 시간: ${job.remainingTime.inSeconds}초', style: AppTextStyles.caption),
            ] else if (job != null && job.isComplete) ...[
              Text('완료: ${job.recipe.name}', style: const TextStyle(color: Colors.green)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  final item = crafting.completeCrafting(station);
                  if (item != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.name} (${_getQualityName(item.quality)}) 제작 완료!')),
                    );
                  }
                },
                child: const Text('수령하기'),
              ),
            ] else ...[
              DropdownButton<Recipe>(
                isExpanded: true,
                hint: const Text('레시피 선택...'),
                items: recipes.map((recipe) {
                  final canCraft = crafting.canStartCrafting(recipe);
                  return DropdownMenuItem(
                    value: recipe,
                    child: Text(
                      '${recipe.name} (${recipe.craftingTime}초)',
                      style: TextStyle(color: canCraft ? Colors.white : Colors.grey),
                    ),
                  );
                }).toList(),
                onChanged: (recipe) {
                  if (recipe != null && crafting.startCrafting(recipe)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${recipe.name} 제작 시작!')),
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
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text('고객: ${shop.currentCustomer!.name}', style: AppTextStyles.header3),
                    Text('예산: ${shop.currentCustomer!.budget.toInt()} 골드', style: AppTextStyles.body),
                    Text('남은 시간: ${shop.customerTimeRemaining.inSeconds}초', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],

            // Display slots
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
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
                    final interested = shop.currentCustomer?.isInterested(item) ?? false;

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

  Widget _buildDisplaySlot(CraftedItem item, bool interested, ShopManager shop, EconomyManager economy) {
    return Card(
      color: interested ? Colors.green.withOpacity(0.2) : AppColors.panel,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.name, style: AppTextStyles.body, textAlign: TextAlign.center),
            Text(_getQualityName(item.quality), style: TextStyle(color: _getQualityColor(item.quality))),
            Text('${item.sellPrice} 골드', style: const TextStyle(color: Colors.yellow)),
            if (interested)
              ElevatedButton(
                onPressed: () {
                  final price = shop.sellItem(item);
                  if (price != null) {
                    economy.addGold(price);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.name} 판매! +$price 골드')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('판매'),
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
          ? const Center(child: Text('완성품 없음', style: TextStyle(color: Colors.grey)))
          : DropdownButton<CraftedItem>(
              isExpanded: true,
              hint: const Center(child: Text('진열할 아이템...')),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text('${item.name} (${item.sellPrice}G)'),
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
    return Consumer4<StationManager, MaterialInventory, EconomyManager, CraftingManager>(
      builder: (context, stations, inventory, economy, crafting, child) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Station Upgrades Section
            Text('제작소 업그레이드', style: AppTextStyles.header2),
            const SizedBox(height: 12),
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
                  leading: Icon(_getStationIcon(station), color: AppColors.primary),
                  title: Text('${data.getName()} Lv.${data.level}'),
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
                                SnackBar(content: Text('${data.getName()} 업그레이드 완료!')),
                              );
                            }
                          }
                        : null,
                    child: const Text('업그레이드'),
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Recipe Unlocks Section
            Text('레시피 해금', style: AppTextStyles.header2),
            const SizedBox(height: 12),
            ...crafting.getAvailableUnlocks(economy.gold ~/ 100, economy.gold).map((recipe) {
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
                        (amount) => economy.spendGold(amount),
                      )) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${recipe.name} 레시피 해금!')),
                        );
                      }
                    },
                    child: const Text('해금'),
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
        return Colors.grey;
      case MaterialType.wood:
        return Colors.brown;
      case MaterialType.leather:
        return Colors.orange;
      case MaterialType.magicStone:
        return Colors.purple;
      case MaterialType.rareGem:
        return Colors.cyan;
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
        return Colors.grey;
      case RecipeTier.intermediate:
        return Colors.green;
      case RecipeTier.advanced:
        return Colors.blue;
      case RecipeTier.master:
        return Colors.purple;
      case RecipeTier.legendary:
        return Colors.orange;
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
        return Colors.grey;
      case Quality.good:
        return Colors.green;
      case Quality.excellent:
        return Colors.blue;
      case Quality.masterpiece:
        return Colors.purple;
    }
  }
}
