class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String sellerId;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.sellerId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final dynamic rawSeller = json['sellerId'] ?? json['seller_id'];
    final String sellerId = rawSeller is Map
        ? (rawSeller['_id']?.toString() ?? rawSeller['id']?.toString() ?? '')
        : (rawSeller?.toString() ?? '');

    return Product(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      category: json['category'] ?? '',
      sellerId: sellerId,
    );
  }
}
