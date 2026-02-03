import 'dart:convert';
import 'package:export_trix/core/constants/api_endpoints.dart';
import 'package:export_trix/core/api/api_client.dart';
import 'package:export_trix/core/api/token_storage.dart';
import 'package:export_trix/data/models/product_model.dart';
import 'package:export_trix/core/utils/logger.dart';

class ApiService {
  static Future<List<Product>> getProducts() async {
    try {
      final response = await ApiClient.instance.dio.get(ApiEndpoints.products);
      final data = response.data;
      final list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : <dynamic>[];
      return list
          .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Product>> getSellerProducts(String sellerId) async {
    try {
      final response = await ApiClient.instance.dio
          .get(ApiEndpoints.productsBySeller(sellerId));
      final data = response.data;
      final list = (data is Map && data['data'] is List)
          ? data['data'] as List
          : <dynamic>[];
      return list
          .map((dynamic item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Map<String, dynamic> _handleResponse(dynamic data) {
    AppLogger.debug('Handling response: $data (Type: ${data.runtimeType})');
    if (data is Map) {
      return data.cast<String, dynamic>();
    } else if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          AppLogger.debug('Successfully decoded string response: $decoded');
          return decoded.cast<String, dynamic>();
        } else {
          AppLogger.info('Decoded string is not a Map: $decoded');
        }
      } catch (e) {
        AppLogger.error('Failed to decode string response: $data', e);
      }
    }
    AppLogger.info('Unexpected response format: $data');
    return {'success': false, 'message': 'Unexpected response format'};
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      AppLogger.debug('Logging in user: $email');
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      AppLogger.debug('Login response raw data: ${response.data}');
      final data = _handleResponse(response.data);
      AppLogger.debug('Login response handled data: $data');

      if (data['success'] == true) {
        final nestedData = data['data'];
        if (nestedData is Map) {
          if (nestedData['token'] != null) {
            final token = nestedData['token'].toString();
            AppLogger.debug('Saving token: ${token.substring(0, 10)}...');
            await TokenStorage.setToken(token);
          } else {
            AppLogger.info('Login successful but token is null in nested data');
          }

          if (nestedData['user'] is Map &&
              (nestedData['user'] as Map)['role'] != null) {
            final role = (nestedData['user'] as Map)['role'].toString();
            AppLogger.debug('Saving role: $role');
            await TokenStorage.setRole(role);
          }
        }
      }
      return data;
    } catch (e) {
      AppLogger.error('Login technical error', e);
      throw Exception(
          'Connection error: Please check if backend is running and database is connected.');
    }
  }

  static Future<void> register(
      String name, String email, String password, String role) async {
    try {
      await ApiClient.instance.dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  static Future<void> forgotPassword(String email) async {
    try {
      await ApiClient.instance.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('Forgot password error: $e');
    }
  }

  // --- Profile Methods ---

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiClient.instance.dio.get(ApiEndpoints.profile);
      final data = _handleResponse(response.data);
      if (data['success'] == true && data['data'] is Map) {
        return (data['data'] as Map).cast<String, dynamic>();
      }
      throw Exception(data['message'] ?? 'Failed to load profile');
    } catch (e) {
      throw Exception('Profile error: $e');
    }
  }

  // --- Order Methods ---

  static Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.orderById(orderId),
      );
      final data = _handleResponse(response.data);
      if (data['success'] == true && data['data'] is Map) {
        return (data['data'] as Map).cast<String, dynamic>();
      }
      throw Exception(data['message'] ?? 'Failed to load order details');
    } catch (e) {
      throw Exception('Order details error: $e');
    }
  }

  static Future<void> pickOrder(String orderId) async {
    try {
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.pickOrder,
        data: {'id': orderId},
      );
      if (response.statusCode != 200) {
        final data = _handleResponse(response.data);
        throw Exception(data['message'] ?? 'Failed to pick order');
      }
    } catch (e) {
      throw Exception('Pick order error: $e');
    }
  }

  // Fetch available orders for riders (Pending/Confirmed with no rider)
  static Future<List<dynamic>> getAvailableOrders() async {
    try {
      AppLogger.debug('Fetching available orders...');
      final response =
          await ApiClient.instance.dio.get(ApiEndpoints.availableOrders);
      final data = _handleResponse(response.data);
      if (data['data'] is List) {
        final orders = (data['data'] as List).cast<dynamic>();
        AppLogger.debug('Parsed ${orders.length} orders');
        return orders;
      }
      return [];
    } catch (e) {
      AppLogger.error('Exception in getAvailableOrders', e);
      throw Exception('Failed to fetch available orders');
    }
  }

  // Update order status (Pick, OnTheWay, Delivered)
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await ApiClient.instance.dio.put(
        ApiEndpoints.updateOrderStatus,
        data: {'id': orderId, 'status': status},
      );
    } catch (e) {
      throw Exception('Update status error: $e');
    }
  }

  // Get rider's picked orders
  static Future<List<dynamic>> getRiderOrders() async {
    try {
      AppLogger.debug('Fetching rider orders...');
      final response =
          await ApiClient.instance.dio.get(ApiEndpoints.riderOrders);
      final data = _handleResponse(response.data);
      if (data['data'] is List) {
        final orders = (data['data'] as List).cast<dynamic>();
        AppLogger.debug('Parsed ${orders.length} rider orders');
        return orders;
      }
      return [];
    } catch (e) {
      AppLogger.error('Exception in getRiderOrders', e);
      throw Exception('Failed to fetch rider orders');
    }
  }

  // --- Dashboard Methods ---

  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      AppLogger.debug(
          'Fetching dashboard stats from ${ApiEndpoints.dashboardStats}');
      final response =
          await ApiClient.instance.dio.get(ApiEndpoints.dashboardStats);
      final data = _handleResponse(response.data);
      if (data['success'] == true && data['data'] is Map) {
        return (data['data'] as Map).cast<String, dynamic>();
      }
      throw Exception(data['message'] ?? 'Failed to load stats');
    } catch (e) {
      AppLogger.error('Dashboard service exception', e);
      throw Exception('Dashboard stats error: $e');
    }
  }

  // Logout method to clear token
  static Future<void> logout() async {
    await TokenStorage.clearToken();
  }
}
