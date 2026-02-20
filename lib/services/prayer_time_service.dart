import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

/// Service waktu sholat: utama dari API [waktu-sholat](https://github.com/maftuh23/waktu-sholat) (data Kemenag),
/// lokasi & jadwal by latitude/longitude. Fallback MyQuran + Nominatim jika API utama gagal.
/// Set WAKTU_SHOLAT_API_URL di .env ke URL deploy Anda (mis. dari Vercel).
class PrayerTimeService {
  static const double _defaultLat = -7.9666;
  static const double _defaultLng = 112.6326;
  static const String _defaultCityName = 'KOTA MALANG';

  String get _waktuSholatBaseUrl {
    final url = dotenv.env['WAKTU_SHOLAT_API_URL']?.trim();
    if (url != null && url.isNotEmpty) return url.replaceAll(RegExp(r'/$'), '');
    return 'https://waktu-sholat.vercel.app';
  }

  List<Map<String, String>>? _cityListCache;

  /// Ambil posisi perangkat (dipaksa baca terbaru, kurangi pakai cache). Return null jika permission ditolak atau error.
  Future<Position?> getCurrentPosition() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested != LocationPermission.whileInUse &&
            requested != LocationPermission.always) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );
      Position? first = await Geolocator.getCurrentPosition(locationSettings: settings);
      // Panggil lagi setelah jeda agar sistem pakai posisi terbaru (bukan last-known cache)
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      try {
        final second = await Geolocator.getCurrentPosition(locationSettings: settings);
        return second;
      } catch (_) {
        return first;
      }
    } catch (_) {
      return null;
    }
  }

  /// GET /location?latitude=&longitude= — kota terdekat dari API waktu-sholat.
  Future<({String cityName, String provinceName})?> _getLocationFromWaktuSholat(
    double lat,
    double lng,
  ) async {
    try {
      final base = _waktuSholatBaseUrl;
      final uri = Uri.parse(
        '$base/location?latitude=$lat&longitude=$lng',
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('timeout'),
      );
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      final province = body['province'];
      final city = body['city'];
      if (city == null) return null;
      final cityName = (city['name'] ?? city['nama'] ?? '').toString();
      final provinceName = province != null
          ? (province['name'] ?? province['nama'] ?? '').toString()
          : '';
      if (cityName.isEmpty) return null;
      return (cityName: cityName, provinceName: provinceName);
    } catch (_) {
      return null;
    }
  }

  /// GET /prayer?latitude=&longitude= — jadwal hari ini dari API waktu-sholat.
  Future<PrayerTimeResult?> _getPrayerFromWaktuSholat(
    double lat,
    double lng,
    String cityDisplay,
  ) async {
    try {
      final base = _waktuSholatBaseUrl;
      final uri = Uri.parse(
        '$base/prayer?latitude=$lat&longitude=$lng',
      );
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('timeout'),
      );
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      final prayers = body['prayers'] as List<dynamic>?;
      if (prayers == null || prayers.isEmpty) return null;
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      Map<String, dynamic>? today;
      for (final p in prayers) {
        final date = (p is Map ? p['date'] : null)?.toString();
        if (date == todayStr) {
          today = p is Map<String, dynamic> ? p : Map<String, dynamic>.from(p as Map);
          break;
        }
      }
      today ??= prayers.isNotEmpty && prayers.first is Map
          ? Map<String, dynamic>.from(prayers.first as Map)
          : null;
      if (today == null) return null;
      final fajr = _clean(today['subuh']);
      final sunrise = _clean(today['terbit']);
      final dhuhr = _clean(today['dzuhur']);
      final asr = _clean(today['ashar']);
      final maghrib = _clean(today['maghrib']);
      final isha = _clean(today['isya']);
      if (fajr.isEmpty && dhuhr.isEmpty) return null;
      return PrayerTimeResult(
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha,
        city: cityDisplay,
      );
    } catch (_) {
      return null;
    }
  }

  /// Jadwal sholat hari ini: coba API waktu-sholat (lokasi + jadwal by lat/lng), fallback MyQuran + Nominatim.
  Future<PrayerTimeResult?> getTodayPrayerTimes({
    double? lat,
    double? lng,
    bool useDeviceLocation = true,
  }) async {
    double latitude = _defaultLat;
    double longitude = _defaultLng;

    if (useDeviceLocation && (lat == null || lng == null)) {
      final position = await getCurrentPosition();
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
      }
    } else if (lat != null && lng != null) {
      latitude = lat;
      longitude = lng;
    }

    // 1) Coba API waktu-sholat (lokasi + jadwal dari koordinat)
    final location = await _getLocationFromWaktuSholat(latitude, longitude);
    if (location != null) {
      final cityDisplay = location.provinceName.isNotEmpty
          ? '${location.cityName}, ${location.provinceName}'
          : location.cityName;
      final result = await _getPrayerFromWaktuSholat(
        latitude,
        longitude,
        cityDisplay,
      );
      if (result != null) return result;
    }

    // 2) Fallback: MyQuran + Nominatim
    return _getTodayPrayerTimesFallback(latitude, longitude);
  }

  Future<PrayerTimeResult?> _getTodayPrayerTimesFallback(
    double latitude,
    double longitude,
  ) async {
    const defaultCityId = '1634';
    String cityName = _defaultCityName;
    final geoCity = await _reverseGeocodeCity(latitude, longitude);
    if (geoCity != null && geoCity.isNotEmpty) {
      final resolved = await _resolveCityId(geoCity);
      if (resolved != null) {
        final list = await _getCityList();
        final found = list.cast<Map<String, String>>().where((e) => e['id'] == resolved);
        if (found.isNotEmpty) cityName = found.first['lokasi'] ?? _defaultCityName;
        final date = DateTime.now();
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        try {
          final uri = Uri.parse(
            'https://api.myquran.com/v2/sholat/jadwal/$resolved/$dateStr',
          );
          final response = await http.get(uri);
          if (response.statusCode == 200) {
            final body = jsonDecode(response.body);
            if (body['status'] == true) {
              final data = body['data'];
              final jadwal = data?['jadwal'] as Map<String, dynamic>?;
              if (jadwal != null) {
                return PrayerTimeResult(
                  fajr: _clean(jadwal['subuh']),
                  sunrise: _clean(jadwal['terbit']),
                  dhuhr: _clean(jadwal['dzuhur']),
                  asr: _clean(jadwal['ashar']),
                  maghrib: _clean(jadwal['maghrib']),
                  isha: _clean(jadwal['isya']),
                  city: (data['lokasi'] ?? cityName) as String? ?? cityName,
                );
              }
            }
          }
        } catch (_) {}
      }
    }
    try {
      final date = DateTime.now();
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final uri = Uri.parse(
        'https://api.myquran.com/v2/sholat/jadwal/$defaultCityId/$dateStr',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      if (body['status'] != true) return null;
      final data = body['data'];
      final jadwal = data?['jadwal'] as Map<String, dynamic>?;
      if (jadwal == null) return null;
      return PrayerTimeResult(
        fajr: _clean(jadwal['subuh']),
        sunrise: _clean(jadwal['terbit']),
        dhuhr: _clean(jadwal['dzuhur']),
        asr: _clean(jadwal['ashar']),
        maghrib: _clean(jadwal['maghrib']),
        isha: _clean(jadwal['isya']),
        city: (data['lokasi'] ?? cityName) as String? ?? cityName,
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> _reverseGeocodeCity(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat&lon=$lng&format=json&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {
          'Accept-Language': 'id',
          'User-Agent': 'PDMMalang/1.0 (jadwal sholat)',
        },
      );
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      final address = body['address'] as Map<String, dynamic>?;
      if (address == null) return null;
      final city = address['city'] as String?;
      final county = address['county'] as String?;
      final state = address['state'] as String?;
      if (city != null && city.isNotEmpty) return city;
      if (county != null && county.isNotEmpty) return county;
      if (state != null && state.isNotEmpty) return state;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, String>>> _getCityList() async {
    if (_cityListCache != null) return _cityListCache!;
    try {
      final uri = Uri.parse('https://api.myquran.com/v2/sholat/kota/semua');
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];
      final body = jsonDecode(response.body);
      final data = body['data'] as List<dynamic>?;
      if (data == null) return [];
      final list = data
          .map((e) => {
                'id': (e['id'] ?? '').toString(),
                'lokasi': (e['lokasi'] ?? '').toString().toUpperCase(),
              })
          .toList();
      _cityListCache = list;
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<String?> _resolveCityId(String cityName) async {
    if (cityName.isEmpty) return null;
    final list = await _getCityList();
    final upper = cityName.toUpperCase().trim();
    final key = upper.replaceFirst(RegExp(r'^(KOTA|KAB\.?)\s*'), '').trim();
    if (key.isEmpty) return null;
    for (final e in list) {
      final lokasi = e['lokasi'] ?? '';
      if (lokasi == upper) return e['id'];
      if (lokasi.startsWith('KOTA ') && lokasi.contains(key)) return e['id'];
    }
    for (final e in list) {
      if ((e['lokasi'] ?? '').contains(key)) return e['id'];
    }
    return null;
  }

  static String _clean(dynamic raw) {
    if (raw == null) return '';
    final s = raw.toString().trim();
    final idx = s.indexOf(' ');
    return idx > 0 ? s.substring(0, idx) : s;
  }

  /// Arah kiblat (derajat dari utara) — Aladhan by koordinat.
  Future<double?> getQiblaDirection({double? lat, double? lng}) async {
    double latitude = lat ?? _defaultLat;
    double longitude = lng ?? _defaultLng;
    if (lat == null && lng == null) {
      final position = await getCurrentPosition();
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
      }
    }
    try {
      final uri = Uri.parse(
        'https://api.aladhan.com/v1/qibla/$latitude/$longitude',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      final direction = body['data']?['direction'];
      if (direction is num) return direction.toDouble();
      return null;
    } catch (_) {
      return null;
    }
  }
}

class PrayerTimeResult {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String city;

  PrayerTimeResult({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.city,
  });

  ({String name, String time}) get nextPrayer {
    final now = DateTime.now();
    final prayers = [
      ('Subuh', fajr),
      ('Dzuhur', dhuhr),
      ('Ashar', asr),
      ('Maghrib', maghrib),
      ('Isya', isha),
    ];

    for (final (name, timeStr) in prayers) {
      final parts = timeStr.split(':');
      if (parts.length < 2) continue;
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final prayerDt = DateTime(now.year, now.month, now.day, h, m);
      if (prayerDt.isAfter(now)) {
        return (name: name, time: _dotFormat(timeStr));
      }
    }
    return (name: 'Subuh', time: _dotFormat(fajr));
  }

  static String _dotFormat(String t) => t.replaceAll(':', '.');
}
