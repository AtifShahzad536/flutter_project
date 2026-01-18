import 'package:flutter/material.dart';
import 'package:export_trix/data/models/product_model.dart';
import 'package:export_trix/data/services/api_service.dart';
import 'package:export_trix/core/widgets/responsive_layout.dart';
import 'package:export_trix/features/products/view/product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Trix Marketplace'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          final products = snapshot.data!;
          return ResponsiveLayout(
            mobile: _buildProductGrid(products, crossAxisCount: 2),
            tablet: _buildProductGrid(products, crossAxisCount: 3),
            desktop: _buildProductGrid(products, crossAxisCount: 4),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products,
      {required int crossAxisCount}) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Card(
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.grey[200],
                    child: Center(
                      // In real app, use Image.network(product.imageUrl)
                      child:
                          Icon(Icons.image, size: 50, color: Colors.grey[400]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${product.price}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
