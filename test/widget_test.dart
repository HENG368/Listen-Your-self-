import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:listen_your_self/main.dart';

void main() {
  testWidgets('renders the local music library', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Listen Your Self'), findsOneWidget);
    expect(find.text('YOUR LIBRARY'), findsNothing);
    expect(find.text('Your music,\nyour space.'), findsNothing);
    expect(find.text('Add music'), findsNothing);
    expect(find.text('Your library is empty'), findsOneWidget);
    expect(find.byTooltip('Import music'), findsOneWidget);
  });

  testWidgets('local library search is available', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    final search = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'Search library',
    );
    expect(search, findsOneWidget);

    await tester.enterText(search, 'piano');
    await tester.pump();
    expect(find.text('Your library is empty'), findsOneWidget);
  });
}
