import 'package:flutter_test/flutter_test.dart';

import 'package:cityscope_flutter/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CityScopeApp());
    expect(find.text('CityScope'), findsOneWidget);
  });
}
