import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:game/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:game/game/level_design_config.dart';
import 'package:game/game/wave_spawn_table.dart';
import 'package:game/game/tutorial_config.dart';

/// E2E Test for MG-0017: Dungeon Craft Tycoon (JRPG Series #2)
///
/// Tests the game loop with focus on:
/// - Dungeon building mechanics
/// - Resource management
/// - Hero/crafting systems
/// - Tycoon simulation elements
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MG-0017 Dungeon Craft Tycoon - Game Loop E2E', () {
    testWidgets('Complete dungeon tycoon progression', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify main menu elements
      expect(find.text('MG-0017'), findsOneWidget);
      expect(find.text('Dungeon Craft Tycoon'), findsOneWidget);
      expect(find.text('Core Fun: $kCoreFunLoop'), findsOneWidget);

      // Navigate to tutorial
      await tester.tap(find.text('Tutorial'));
      await tester.pumpAndSettle();

      // Complete tutorial steps
      final tutorialSteps = kOnboardingTutorial.steps;
      for (int i = 0; i < tutorialSteps.length; i++) {
        await tester.pumpAndSettle();
        expect(find.text('${i + 1}/${tutorialSteps.length}'), findsOneWidget);

        await tester.tap(find.text(i == tutorialSteps.length - 1 ? 'Done' : 'Next'));
        await tester.pumpAndSettle();
      }

      // Navigate to game screen
      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Test dungeon building progression
      int roomsBuilt = 0;
      int totalGold = 0;
      int totalXP = 0;

      for (int i = 0; i < 8 && i < kLevelDesign.length; i++) {
        await tester.pumpAndSettle();

        final levelDesign = kLevelDesign[i];
        final spawn = kWaveSpawnTable[i];

        expect(find.text('Level ${levelDesign.levelIndex} - ${levelDesign.stage}'), findsOneWidget);

        // Complete dungeon room construction
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();

        // Tycoon resource accumulation
        roomsBuilt++;
        totalGold += levelDesign.goldReward;
        totalXP += levelDesign.xpReward;

        expect(find.text('$totalGold gold / $totalXP xp'), findsOneWidget);
      }

      // Verify tycoon progression
      expect(roomsBuilt, greaterThan(0), reason: 'Should build dungeon rooms');
      expect(totalGold, greaterThan(0), reason: 'Tycoon should generate gold');
      expect(totalXP, greaterThan(0), reason: 'Should gain XP');
    });

    testWidgets('Test dungeon room variety and crafting', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Dungeon craft should have room types
      for (int i = 0; i < 10 && i < kLevelDesign.length; i++) {
        final level = kLevelDesign[i];

        // Dungeon tycoon themes
        expect(level.stage.toLowerCase(), anyOf(
          contains('dungeon'),
          contains('room'),
          contains('craft'),
          contains('trap'),
          contains('monster'),
          contains('treasure'),
          contains('build'),
        ), reason: 'Levels should have dungeon themes');

        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Verify tycoon theme and visual elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      // Verify tycoon visual elements
      expect(find.byIcon(Icons.videogame_asset_rounded), findsWidgets);
      expect(find.byIcon(Icons.construction_rounded), findsWidgets);
    });

    testWidgets('Complete full dungeon tycoon session', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Game'));
      await tester.pumpAndSettle();

      int roomsCompleted = 0;
      int maxRooms = 22;

      for (int i = 0; i < maxRooms && i < kLevelDesign.length; i++) {
        await tester.tap(find.byKey(const ValueKey('complete-action')));
        await tester.pumpAndSettle();
        roomsCompleted++;
      }

      expect(roomsCompleted, equals(maxRooms), reason: 'Should complete 22 rooms');

      // Verify tycoon rewards
      final finalGold = kLevelDesign.take(maxRooms).map((l) => l.goldReward).fold(0, (a, b) => a + b);
      final finalXP = kLevelDesign.take(maxRooms).map((l) => l.xpReward).fold(0, (a, b) => a + b);

      expect(find.textContaining('$finalGold gold'), findsOneWidget);
      expect(find.textContaining('$finalXP xp'), findsOneWidget);
    });

    testWidgets('Test tycoon retention features', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test daily dungeon management
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      expect(find.text('Daily Quests'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test tournament (dungeon competitions)
      await tester.tap(find.text('Tournament'));
      await tester.pumpAndSettle();
      expect(find.text('Tournament'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test rewards (tycoon accumulation)
      await tester.tap(find.text('Rewards'));
      await tester.pumpAndSettle();
      expect(find.text('Rewards'), findsOneWidget);
    });

    testWidgets('Verify dungeon depth progression', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Level Roadmap'));
      await tester.pumpAndSettle();

      // Dungeon should have depth levels
      for (int i = 0; i < kLevelDesign.length && i < 12; i++) {
        final level = kLevelDesign[i];
        expect(find.text('Level ${level.levelIndex} - ${level.stage}'), findsOneWidget);

        // Dungeon depth themes
        expect(level.stage.toLowerCase(), anyOf(
          contains('floor'),
          contains('depth'),
          contains('level'),
          contains('basement'),
          contains('chamber'),
        ));
      }
    });
  });
}
