import 'package:dio/dio.dart';

import 'package:export_trix/core/api/api_config.dart';
import 'package:export_trix/core/api/token_storage.dart';
import 'package:export_trix/core/utils/logger.dart';

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

            // List of public endpoints that don't strictly require a token
            final publicPaths = [
              '/auth/login',
              '/auth/register',
              '/auth/forgot-password',
              '/products',
            ];

            bool isPublic =
                publicPaths.any((path) => options.path.contains(path));

            AppLogger.debug(
                'API request to ${options.path} (Public: $isPublic)');

            if (token != null && token.isNotEmpty && token != 'null') {
              options.headers['Authorization'] = 'Bearer $token';
              AppLogger.debug('Token added to headers');
              handler.next(options);
            } else if (isPublic) {
              AppLogger.debug('Public endpoint access without token');
              handler.next(options);
            } else {
              AppLogger.error(
                  'BLOCKED: Protected request to ${options.path} without valid token');
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'Authentication required for this endpoint',
                  type: DioExceptionType.cancel,
                ),
                true,
              );
            }
          } catch (e) {
            AppLogger.error('Error in API interceptor', e);
            handler.next(options);
          }
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
