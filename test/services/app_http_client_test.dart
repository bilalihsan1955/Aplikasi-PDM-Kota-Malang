import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pdm_malang/services/api/app_http.dart';

void main() {
  group('AppHttpClient', () {
    test('menambahkan User-Agent dan X-Requested-With aplikasi', () async {
      late http.BaseRequest captured;
      final client = AppHttpClient(MockClient((request) async {
        captured = request;
        return http.Response('{}', 200, headers: {'content-type': 'application/json'});
      }));

      await client.get(Uri.parse('https://example.test/api/v1/news'));

      expect(captured.headers['User-Agent'], AppHttp.userAgent);
      expect(captured.headers['X-Requested-With'], AppHttp.appId);
      expect(captured.headers['User-Agent'], isNot(contains('Dart/')));
    });

    test('tidak menimpa User-Agent yang diset service', () async {
      late http.BaseRequest captured;
      final client = AppHttpClient(MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      }));

      await client.get(
        Uri.parse('https://example.test'),
        headers: {'User-Agent': 'Custom/1.0'},
      );

      expect(captured.headers['User-Agent'], 'Custom/1.0');
    });

    test('mengubah halaman blokir non-JSON menjadi JSON dengan pesan ramah', () async {
      final client = AppHttpClient(MockClient((_) async => http.Response(
            'Access denied by Imunify360 bot-protection. IPs used for automation should be whitelisted',
            415,
            headers: {'content-type': 'text/html'},
          )));

      final response = await client.post(
        Uri.parse('https://example.test/api/v1/login'),
        headers: {'Accept': 'application/json'},
      );

      expect(response.statusCode, 415);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['success'], false);
      expect(body['message'], AppHttp.nonJsonErrorMessage(415));
      expect(response.body, isNot(contains('Imunify360')));
    });

    test('membiarkan error JSON dari backend apa adanya', () async {
      const backendBody = '{"message":"Email atau password salah"}';
      final client = AppHttpClient(MockClient((_) async => http.Response(
            backendBody,
            422,
            headers: {'content-type': 'application/json'},
          )));

      final response = await client.post(
        Uri.parse('https://example.test/api/v1/login'),
        headers: {'Accept': 'application/json'},
      );

      expect(response.body, backendBody);
    });

    test('tidak mengubah respons untuk request yang tidak meminta JSON', () async {
      final client = AppHttpClient(MockClient((_) async => http.Response(
            '<html>Forbidden</html>',
            403,
            headers: {'content-type': 'text/html'},
          )));

      final response = await client.get(Uri.parse('https://example.test/storage/a.jpg'));

      expect(response.body, '<html>Forbidden</html>');
    });

    test('melempar TimeoutException bila server tidak merespons', () async {
      final client = AppHttpClient(
        MockClient((_) => Completer<http.Response>().future),
        timeout: const Duration(milliseconds: 50),
      );

      expect(
        client.get(Uri.parse('https://example.test/api/v1/news')),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
