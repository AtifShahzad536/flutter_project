import 'package:dio/dio.dart';

import 'api_config.dart';
import 'token_storage.dart';
import '../utils/logger.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await TokenStorage.getToken();
            AppLogger.debug(
                'API request to ${options.path} with token: ${token != null ? "Bearer ${token.substring(0, 10)}..." : "null"}');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            AppLogger.error('Error getting token for API request', e);
            // Continue without token if there's an error
          }
          handler.next(options);
        },
      ),
    );

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data;
    } catch (e) {
      AppLogger.error('API GET Error: $path', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data;
    } catch (e) {
      AppLogger.error('API POST Error: $path', e);
      rethrow;
    }
  }
}
