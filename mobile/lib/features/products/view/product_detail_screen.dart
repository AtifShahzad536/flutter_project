import 'package:flutter/material.dart';
import 'package:export_trix/data/models/product_model.dart';
import 'package:export_trix/core/widgets/responsive_layout.dart';
import 'package:export_trix/features/seller_store/view/seller_store_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 300,
            color: Colors.grey[200],
            child: const Icon(Icons.image, size: 100, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildProductInfo(context),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 500,
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 1,
            child: _buildProductInfo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '\$${product.price}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(product.description),
        const SizedBox(height: 24),
        Text(
          'Seller Info',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.store)),
          title:
              const Text('View Seller Store'), // In real app, fetch seller name
          subtitle: const Text('Verified Seller'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SellerStoreScreen(
                  sellerId: product.sellerId,
                  sellerName:
                      'Seller ${product.sellerId.substring(0, 4)}', // Mock name for now
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Add to Cart'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
