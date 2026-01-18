import '../../core/constants/api_endpoints.dart';
import '../../core/api/api_client.dart';
import '../../core/api/token_storage.dart';
import '../../data/models/product_model.dart';
import '../../core/utils/logger.dart';

class ApiService {
  Future<List<Product>> getProducts() async {
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

  Future<List<Product>> getSellerProducts(String sellerId) async {
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

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      if (data is Map && data['token'] != null) {
        await TokenStorage.setToken(data['token'].toString());
      }
      if (data is Map &&
          data['user'] is Map &&
          (data['user'] as Map)['role'] != null) {
        await TokenStorage.setRole((data['user'] as Map)['role'].toString());
      }
      return (data as Map).cast<String, dynamic>();
    } catch (e) {
      throw Exception('Network error: $e');
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
      throw Exception('Network error: $e');
    }
  }

  static Future<void> forgotPassword(String email) async {
    try {
      await ApiClient.instance.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // --- Order Methods ---

  // Fetch available orders for riders (Pending/Confirmed with no rider)
  static Future<List<dynamic>> getAvailableOrders() async {
    try {
      AppLogger.debug('Fetching available orders...');
      final response =
          await ApiClient.instance.dio.get(ApiEndpoints.availableOrders);
      AppLogger.debug('Response status: ${response.statusCode}');
      AppLogger.debug('Response data: ${response.data}');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final orders = (data['data'] as List).cast<dynamic>();
        AppLogger.debug('Parsed ${orders.length} orders');
        return orders;
      }
      AppLogger.debug('No orders found in response');
      return [];
    } catch (e) {
      AppLogger.error('Exception in getAvailableOrders', e);
      throw Exception('Network error: $e');
    }
  }

  // Update order status (Pick, OnTheWay, Delivered)
  static Future<void> updateOrderStatus(String orderId, String status) async {
    await ApiClient.instance.dio.put(
      ApiEndpoints.updateOrderStatus,
      data: {'id': orderId, 'status': status},
    );
  }

  // Get rider's picked orders
  static Future<List<dynamic>> getRiderOrders() async {
    try {
      AppLogger.debug('Fetching rider orders...');
      final response =
          await ApiClient.instance.dio.get(ApiEndpoints.riderOrders);
      AppLogger.debug('Rider orders response status: ${response.statusCode}');
      AppLogger.debug('Rider orders response data: ${response.data}');
      final data = response.data;
      if (data is Map && data['data'] is List) {
        final orders = (data['data'] as List).cast<dynamic>();
        AppLogger.debug('Parsed ${orders.length} rider orders');
        return orders;
      }
      AppLogger.debug('No rider orders found in response');
      return [];
    } catch (e) {
      AppLogger.error('Exception in getRiderOrders', e);
      throw Exception('Network error: $e');
    }
  }

  // Logout method to clear token
  static Future<void> logout() async {
    await TokenStorage.clearToken();
  }
}
