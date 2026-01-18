import 'package:flutter/material.dart';
import 'package:export_trix/core/utils/logger.dart';
import 'package:export_trix/data/services/api_service.dart';
import 'package:export_trix/features/rider/view/order_detail_screen.dart';

class RiderOrdersScreen extends StatefulWidget {
  const RiderOrdersScreen({super.key});

  @override
  State<RiderOrdersScreen> createState() => _RiderOrdersScreenState();
}

class _RiderOrdersScreenState extends State<RiderOrdersScreen> {
  Future<List<dynamic>>? _ordersFuture;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _ordersFuture = ApiService.getAvailableOrders();
    });

    try {
      final orders = await _ordersFuture!;
      AppLogger.debug('Loaded ${orders.length} orders');
      AppLogger.debug('First order: ${orders[0]}');
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    } catch (e) {
      AppLogger.debug('Error loading orders: $e');
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshOrders() async {
    // Force refresh by clearing the future and reloading
    if (mounted) {
      setState(() {
        _ordersFuture = null;
      });
    }

    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Available Orders",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                SizedBox(height: 4),
                Text("Pick an order to start delivery",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            IconButton(
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: _isRefreshing ? null : _refreshOrders,
              tooltip: 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final orders = snapshot.data ?? [];
              AppLogger.debug('Orders in UI: ${orders.length} items');
              if (orders.isNotEmpty) {
                AppLogger.debug('First order in UI: ${orders[0]}');
              }

              if (orders.isEmpty) {
                AppLogger.debug('Showing empty state - orders list is empty');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No available orders',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('Check back later for new deliveries',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                );
              }

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(orders[index], isDesktop: true);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Orders',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pick an order to deliver',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white),
                onPressed: _isRefreshing ? null : _refreshOrders,
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text('Error loading orders',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700)),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _refreshOrders,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final orders = snapshot.data ?? [];

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('No Orders Available',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Check back later for deliveries',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(orders[index], isDesktop: false);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order,
      {required bool isDesktop}) {
    final String orderDbId = (order['id'] ?? '').toString();
    final String orderCode = (order['order_id'] ?? orderDbId).toString();
    final amount =
        double.tryParse((order['total_amount'] ?? '0').toString()) ?? 0.0;
    final customerName = (order['customer_name'] ?? 'Unknown').toString();
    final deliveryAddress =
        (order['customer_address'] ?? 'No address').toString();
    final status = order['status'] ?? 'Pending';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(orderId: orderDbId),
          ),
        ).then((_) => _refreshOrders()); // Refresh after returning
      },
      child: Container(
        margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${orderCode.substring(orderCode.length >= 6 ? orderCode.length - 6 : 0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customerName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    deliveryAddress,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return const Color(0xFF10B981);
      case 'pending':
      case 'confirmed':
        return const Color(0xFFF59E0B);
      case 'picked':
      case 'ontheway':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
  }
}
