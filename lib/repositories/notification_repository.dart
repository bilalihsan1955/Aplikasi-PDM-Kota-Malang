import 'package:pdm_malang/services/api/notification_api_service.dart';

class NotificationRepository {
  Future<NotificationListResult> fetchNotifications({
    required String token,
    required int userId,
    int limit = 30,
  }) async {
    return await NotificationApiService.fetchNotifications(
      token: token,
      userId: userId,
      limit: limit,
    );
  }
}
