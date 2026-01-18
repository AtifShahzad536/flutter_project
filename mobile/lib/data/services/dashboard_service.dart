import '../../core/api/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/utils/logger.dart';

class DashboardService {
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      AppLogger.debug(
          'Fetching dashboard stats from ${ApiEndpoints.dashboardStats}');
      final response =
          await ApiClient.instance.dio.get(ApiEndpoints.dashboardStats);
      AppLogger.debug('Dashboard response status: ${response.statusCode}');
      AppLogger.debug('Dashboard response data: ${response.data}');

      final body = response.data;
      if (body is Map && body['success'] == true && body['data'] is Map) {
        final data = (body['data'] as Map).cast<String, dynamic>();
        AppLogger.debug('Parsed dashboard data: $data');
        return data;
      }
      if (body is Map && body['message'] != null) {
        throw Exception(body['message'].toString());
      }
      throw Exception('Failed to load stats');
    } catch (e) {
      AppLogger.error('Dashboard service exception', e);
      throw Exception('Network error: $e');
    }
  }
}
