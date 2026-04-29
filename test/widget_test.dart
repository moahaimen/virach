import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:racheeta/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Ensure that it doesn't crash on startup.
    await tester.pumpWidget(MyApp());

    // We can't guarantee what text will be on the first screen since it depends on the routing
    // (e.g. WelcomeScreen or Splash), so we just verify that a Scaffold or Material app is present.
    expect(find.byType(MaterialApp), findsWidgets);
  });
}
