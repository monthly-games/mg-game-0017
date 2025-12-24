import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/audio/audio_manager.dart';
import 'package:mg_common_game/core/ui/theme/app_colors.dart';

import 'features/materials/material_inventory.dart';
import 'features/economy/economy_manager.dart';
import 'features/crafting/crafting_manager.dart';
import 'features/shop/shop_manager.dart';
import 'features/stations/station_manager.dart';
import 'features/save/save_manager.dart';
import 'features/dungeon/dungeon_manager.dart';
import 'features/upgrades/upgrade_manager.dart';
import 'features/achievements/achievement_manager.dart';
import 'features/decoration/decoration_manager.dart';
import 'screens/tycoon_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupDI();
  await GetIt.I<AudioManager>().initialize();

  runApp(const TycoonApp());
}

void _setupDI() {
  if (!GetIt.I.isRegistered<AudioManager>()) {
    GetIt.I.registerSingleton<AudioManager>(AudioManager());
  }
}

class TycoonApp extends StatefulWidget {
  const TycoonApp({super.key});

  @override
  State<TycoonApp> createState() => _TycoonAppState();
}

class _TycoonAppState extends State<TycoonApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaterialInventory()),
        ChangeNotifierProvider(create: (_) => EconomyManager()),
        ChangeNotifierProvider(create: (_) => StationManager()),
        ChangeNotifierProvider(create: (_) => AchievementManager()),
        ChangeNotifierProvider(create: (_) => DecorationManager()),
        ChangeNotifierProxyProvider<MaterialInventory, CraftingManager>(
          create: (context) => CraftingManager(
            Provider.of<MaterialInventory>(context, listen: false),
          ),
          update: (context, inventory, previous) =>
              previous ?? CraftingManager(inventory),
        ),
        ChangeNotifierProxyProvider<CraftingManager, ShopManager>(
          create: (context) =>
              ShopManager(Provider.of<CraftingManager>(context, listen: false)),
          update: (context, crafting, previous) =>
              previous ?? ShopManager(crafting),
        ),
        ChangeNotifierProxyProvider2<
          MaterialInventory,
          UpgradeManager,
          DungeonManager
        >(
          create: (context) => DungeonManager(
            Provider.of<MaterialInventory>(context, listen: false),
            Provider.of<UpgradeManager>(context, listen: false),
          ),
          update: (context, inventory, upgrades, previous) =>
              previous ?? DungeonManager(inventory, upgrades),
        ),
        ChangeNotifierProxyProvider<EconomyManager, UpgradeManager>(
          create: (context) => UpgradeManager(
            Provider.of<EconomyManager>(context, listen: false),
          ),
          update: (context, economy, previous) =>
              previous ?? UpgradeManager(economy),
        ),
        ProxyProvider6<
          MaterialInventory,
          CraftingManager,
          ShopManager,
          EconomyManager,
          StationManager,
          UpgradeManager,
          SaveManager
        >(
          create: (context) => SaveManager(
            inventory: Provider.of<MaterialInventory>(context, listen: false),
            crafting: Provider.of<CraftingManager>(context, listen: false),
            shop: Provider.of<ShopManager>(context, listen: false),
            economy: Provider.of<EconomyManager>(context, listen: false),
            stations: Provider.of<StationManager>(context, listen: false),
            upgrades: Provider.of<UpgradeManager>(context, listen: false),
          ),
          update:
              (
                context,
                inventory,
                crafting,
                shop,
                economy,
                stations,
                upgrades,
                previous,
              ) =>
                  previous ??
                  SaveManager(
                    inventory: inventory,
                    crafting: crafting,
                    shop: shop,
                    economy: economy,
                    stations: stations,
                    upgrades: upgrades,
                  ),
        ),
      ],
      child: MaterialApp(
        title: 'Dungeon Craft Tycoon',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
        ),
        home: Builder(
          builder: (context) {
            // Auto-load game when app starts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final saveManager = context.read<SaveManager>();
              saveManager.loadGame().then((loaded) {
                if (loaded) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('게임 불러오기 완료!')));
                }
                // Start auto-save
                saveManager.startAutoSave();
              });
            });
            return const TycoonScreen();
          },
        ),
      ),
    );
  }
}
