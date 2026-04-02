// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:pdm_malang/main.dart';
import 'package:pdm_malang/view_models/agenda_view_model.dart';
import 'package:pdm_malang/view_models/auth_view_model.dart';
import 'package:pdm_malang/view_models/home_view_model.dart';
import 'package:pdm_malang/view_models/news_view_model.dart';
import 'package:pdm_malang/view_models/notification_view_model.dart';
import 'package:pdm_malang/view_models/profile_view_model.dart';

void main() {
  testWidgets('MyApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => HomeViewModel()),
          ChangeNotifierProvider(create: (_) => AgendaViewModel()),
          ChangeNotifierProvider(create: (_) => NewsViewModel()),
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
          ChangeNotifierProvider(create: (_) => NotificationViewModel()),
          ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ],
        child: const MyApp(initialLocation: '/login'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
