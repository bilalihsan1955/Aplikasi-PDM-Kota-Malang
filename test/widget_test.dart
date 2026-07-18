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
import 'package:pdm_malang/view_models/home_view_model.dart';
import 'package:pdm_malang/view_models/agenda_view_model.dart';
import 'package:pdm_malang/view_models/news_view_model.dart';
import 'package:pdm_malang/view_models/profile_view_model.dart';
import 'package:pdm_malang/view_models/notification_view_model.dart';
import 'package:pdm_malang/view_models/auth_view_model.dart';
import 'package:pdm_malang/view_models/amal_usaha_view_model.dart';

import 'package:pdm_malang/services/api/event_api_service.dart';
import 'package:pdm_malang/services/api/news_api_service.dart';
import 'package:pdm_malang/services/prayer/prayer_time_service.dart';

import 'package:pdm_malang/services/auth/auth_api_service.dart';
import 'package:pdm_malang/services/auth/auth_local_service.dart';
import 'package:pdm_malang/services/api/amal_usaha_api_service.dart';

import 'package:pdm_malang/repositories/agenda_repository.dart';
import 'package:pdm_malang/repositories/news_repository.dart';
import 'package:pdm_malang/repositories/prayer_repository.dart';
import 'package:pdm_malang/repositories/notification_repository.dart';
import 'package:pdm_malang/repositories/auth_repository.dart';
import 'package:pdm_malang/repositories/amal_usaha_repository.dart';

void main() {
  testWidgets('MyApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<EventApiService>(create: (_) => EventApiService()),
          Provider<NewsApiService>(create: (_) => NewsApiService()),
          Provider<PrayerTimeService>(create: (_) => PrayerTimeService()),
          Provider<AuthApiService>(create: (_) => AuthApiService()),
          Provider<AmalUsahaApiService>(create: (_) => AmalUsahaApiService()),
          
          ProxyProvider<EventApiService, AgendaRepository>(
            update: (_, api, __) => AgendaRepository(apiService: api),
          ),
          ProxyProvider<NewsApiService, NewsRepository>(
            update: (_, api, __) => NewsRepository(apiService: api),
          ),
          ProxyProvider<PrayerTimeService, PrayerRepository>(
            update: (_, api, __) => PrayerRepository(apiService: api),
          ),
          Provider<NotificationRepository>(
            create: (_) => NotificationRepository(),
          ),
          ProxyProvider<AuthApiService, AuthRepository>(
            update: (_, api, __) => AuthRepository(
              apiService: api,
              localService: AuthLocalService(),
            ),
          ),
          ProxyProvider<AmalUsahaApiService, AmalUsahaRepository>(
            update: (_, api, __) => AmalUsahaRepository(apiService: api),
          ),

          ChangeNotifierProvider(
            create: (context) => HomeViewModel(
              newsRepository: context.read<NewsRepository>(),
              agendaRepository: context.read<AgendaRepository>(),
              prayerRepository: context.read<PrayerRepository>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => AgendaViewModel(
              repository: context.read<AgendaRepository>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => NewsViewModel(
              repository: context.read<NewsRepository>(),
            ),
          ),
          ChangeNotifierProvider(create: (_) => ProfileViewModel()),
          ChangeNotifierProvider(
            create: (context) => NotificationViewModel(
              repository: context.read<NotificationRepository>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => AuthViewModel(
              repository: context.read<AuthRepository>(),
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => AmalUsahaViewModel(
              repository: context.read<AmalUsahaRepository>(),
            ),
          ),
        ],
        child: const MyApp(initialLocation: '/login'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
