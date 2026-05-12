import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GetIt.I.reset();
    await initializeGameServices();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('TycoonApp builds the dungeon craft shell', (tester) async {
    await tester.pumpWidget(const TycoonApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
