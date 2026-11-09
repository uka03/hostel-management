import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostel/main.dart';

void main() {
  testWidgets('tab shell fits at 360 px in Mongolian and switches tabs', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Every label is in the tab bar; only the active page adds its title.
    expect(find.text('Нүүр'), findsNWidgets(2));
    for (final label in ['Цэвэрлэгээ', 'Зардал', 'Асуудал', 'Профайл']) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('Зардал'));
    await tester.pump();

    expect(find.text('Зардал'), findsNWidgets(2));
    expect(find.text('Нүүр'), findsOneWidget);
  });
}
