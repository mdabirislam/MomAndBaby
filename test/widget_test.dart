import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pregnancy_care/app.dart';

void main() {
  testWidgets('Mom & Baby app launches successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MomAndBabyApp()));

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
