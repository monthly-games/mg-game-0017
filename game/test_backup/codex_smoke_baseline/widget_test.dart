import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game/main.dart';

void main() {
  testWidgets('Tycoon app launches', (tester) async {
    await tester.pumpWidget(const TycoonApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Gold: 0'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
