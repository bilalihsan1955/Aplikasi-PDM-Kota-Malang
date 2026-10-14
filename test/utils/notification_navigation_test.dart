import 'package:flutter_test/flutter_test.dart';
import 'package:pdm_malang/models/notification_model.dart';
import 'package:pdm_malang/utils/notification_navigation.dart';

void main() {
  group('extractNotificationSlug Tests', () {
    test('extracts pure slug directly', () {
      expect(extractNotificationSlug('kajian-ramadhan-1447'), 'kajian-ramadhan-1447');
    });

    test('extracts slug from relative path /berita/slug', () {
      expect(extractNotificationSlug('/berita/acara-ramadhan'), 'acara-ramadhan');
    });

    test('extracts slug from full URL https://makotamu.org/berita/slug', () {
      expect(
        extractNotificationSlug('https://makotamu.org/berita/takbiran-dan-nyepi-2026'),
        'takbiran-dan-nyepi-2026',
      );
    });

    test('extracts slug from full URL with trailing slash', () {
      expect(
        extractNotificationSlug('https://makotamu.org/berita/takbiran-dan-nyepi-2026/'),
        'takbiran-dan-nyepi-2026',
      );
    });

    test('extracts slug from query parameter /berita/detail?slug=my-slug', () {
      expect(
        extractNotificationSlug('/berita/detail?slug=my-slug'),
        'my-slug',
      );
    });

    test('extracts agenda slug from https://makotamu.org/agenda/undangan-kajian', () {
      expect(
        extractNotificationSlug('https://makotamu.org/agenda/undangan-kajian'),
        'undangan-kajian',
      );
    });

    test('handles empty or null string gracefully', () {
      expect(extractNotificationSlug(null), '');
      expect(extractNotificationSlug(''), '');
      expect(extractNotificationSlug('   '), '');
    });
  });

  group('coldStartTargetForNotification Tests', () {
    test('resolves news notification with slug query parameter', () {
      final n = NotificationModel(
        id: 1,
        title: 'Berita Baru',
        body: 'Isi berita',
        topic: 'news',
        tipeRedirect: 'news',
        urlRedirect: 'https://makotamu.org/berita/kajian-spesial',
        createdAt: DateTime.parse('2026-03-29 08:30:00'),
      );
      final target = coldStartTargetForNotification(n);
      expect(target, isNotNull);
      expect(target!.location, '/berita/detail?slug=kajian-spesial');
      expect(target.extra, {'slug': 'kajian-spesial'});
    });

    test('resolves agenda notification with clean slug', () {
      final n = NotificationModel(
        id: 2,
        title: 'Agenda Baru',
        body: 'Isi agenda',
        topic: 'agenda',
        tipeRedirect: 'agenda',
        urlRedirect: '/agenda/tabligh-akbar',
        createdAt: DateTime.parse('2026-03-29 08:30:00'),
      );
      final target = coldStartTargetForNotification(n);
      expect(target, isNotNull);
      expect(target!.location, '/agenda/detail?slug=tabligh-akbar');
      expect(target.extra, {'slug': 'tabligh-akbar'});
    });

    test('falls back to /berita when urlRedirect is empty', () {
      final n = NotificationModel(
        id: 3,
        title: 'Berita Umum',
        body: 'Isi berita umum',
        topic: 'general',
        tipeRedirect: 'berita',
        urlRedirect: '',
        createdAt: DateTime.parse('2026-03-29 08:30:00'),
      );
      final target = coldStartTargetForNotification(n);
      expect(target, isNotNull);
      expect(target!.location, '/berita');
    });
  });
}
