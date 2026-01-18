import 'api_config.dart';

class ApiEndpoints {
  static String get baseUrl => ApiConfig.baseUrl;

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get forgotPassword => '$baseUrl/auth/forgot-password';

  static String get products => '$baseUrl/products';
  static String productById(String id) => '$baseUrl/products/$id';
  static String productsBySeller(String sellerId) =>
      '$baseUrl/products/seller/$sellerId';

  static String get orders => '$baseUrl/orders';
  static String get myOrders => '$baseUrl/orders/my-orders';
  static String get availableOrders => '$baseUrl/orders/available';
  static String orderById(String id) => '$baseUrl/orders/$id';
  static String get pickOrder => '$baseUrl/orders/pick';
  static String get updateOrderStatus => '$baseUrl/orders/status';

  static String get profile => '$baseUrl/auth/profile';
  static String get dashboardStats => '$baseUrl/dashboard';
  static String get riderOrders => '$baseUrl/orders/rider';

  static String get notifications => '$baseUrl/notifications';
  static String get markNotificationRead => '$baseUrl/notifications/read';

  static String get chats => '$baseUrl/chats';
  static String chatHistory(String id) => '$baseUrl/chats/history/$id';
  static String get sendMessage => '$baseUrl/chats/send';
  static String get users => '$baseUrl/users';
}
