// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dart_neutral/main.dart';
import 'package:dart_neutral/viewmodels/monitor_viewmodel.dart';

void main() {
  testWidgets('App renders correctly smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MonitorViewModel()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that our app bar title exists
    expect(find.text('Tanque de Neutralización'), findsOneWidget);
  });

  testWidgets('Boron button is not visible by default', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MonitorViewModel()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Consultar Boron'), findsNothing);
  });

  testWidgets('Boron button is visible when showBoronButton is true', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'showBoronButton': true});
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MonitorViewModel()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Consultar Boron'), findsOneWidget);
  });
}
