import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinball_mobile/main.dart';

void main() {
  testWidgets('MainMenu has a title and a play button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Pinball'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}
