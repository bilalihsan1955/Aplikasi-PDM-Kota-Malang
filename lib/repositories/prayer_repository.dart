import 'package:pdm_malang/services/prayer/prayer_time_service.dart';
export 'package:pdm_malang/services/prayer/prayer_time_service.dart' show PrayerTimeResult;
import 'package:geolocator/geolocator.dart';

class PrayerRepository {
  final PrayerTimeService _apiService;

  PrayerRepository({required PrayerTimeService apiService})
      : _apiService = apiService;

  Future<Position?> getCurrentPosition() async {
    return await _apiService.getCurrentPosition();
  }

  Future<PrayerTimeResult?> getTodayPrayerTimes({
    double? lat,
    double? lng,
    bool useDeviceLocation = true,
  }) async {
    return await _apiService.getTodayPrayerTimes(
      lat: lat,
      lng: lng,
      useDeviceLocation: useDeviceLocation,
    );
  }

  Future<double?> getQiblaDirection({double? lat, double? lng}) async {
    return await _apiService.getQiblaDirection(lat: lat, lng: lng);
  }
}
