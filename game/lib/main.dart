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

class TycoonApp extends StatelessWidget {
  const TycoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaterialInventory()),
        ChangeNotifierProvider(create: (_) => EconomyManager()),
        ChangeNotifierProvider(create: (_) => StationManager()),
        ChangeNotifierProxyProvider<MaterialInventory, CraftingManager>(
          create: (context) => CraftingManager(
            Provider.of<MaterialInventory>(context, listen: false),
          ),
          update: (context, inventory, previous) =>
              previous ?? CraftingManager(inventory),
        ),
        ChangeNotifierProxyProvider<CraftingManager, ShopManager>(
          create: (context) => ShopManager(
            Provider.of<CraftingManager>(context, listen: false),
          ),
          update: (context, crafting, previous) =>
              previous ?? ShopManager(crafting),
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
        home: const TycoonScreen(),
      ),
    );
  }
}
