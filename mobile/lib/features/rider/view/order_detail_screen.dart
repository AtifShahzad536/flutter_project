import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:export_trix/core/utils/logger.dart';
import 'package:export_trix/core/constants/api_endpoints.dart';
import 'package:export_trix/core/api/api_client.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Future<Map<String, dynamic>>? _orderFuture;
  bool _isPickingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<Map<String, dynamic>> _fetchOrderDetails() async {
    try {
      AppLogger.debug('Fetching order details for ID: ${widget.orderId}');
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.orderById(widget.orderId),
      );
      AppLogger.debug('Order detail response status: ${response.statusCode}');
      AppLogger.debug('Order detail response data: ${response.data}');

      final body = response.data;
      if (body is Map && body['success'] == true && body['data'] is Map) {
        final orderData = (body['data'] as Map).cast<String, dynamic>();
        AppLogger.debug('Parsed order data: $orderData');
        return orderData;
      }
      if (body is Map && body['message'] != null) {
        throw Exception(body['message'].toString());
      }
      throw Exception('Failed to load order details');
    } catch (e) {
      AppLogger.error('Exception in _fetchOrderDetails', e);
      rethrow;
    }
  }

  void _loadOrderDetails() {
    setState(() {
      _orderFuture = _fetchOrderDetails();
    });
  }

  Future<void> _pickOrder() async {
    setState(() {
      _isPickingOrder = true;
    });

    try {
      AppLogger.debug('Attempting to pick order ${widget.orderId}');
      AppLogger.debug('API endpoint: ${ApiEndpoints.pickOrder}');

      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.pickOrder,
        data: {'id': widget.orderId},
      );

      AppLogger.debug('Pick order response status: ${response.statusCode}');
      AppLogger.debug('Pick order response data: ${response.data}');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order picked successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Go back to orders list
        }
      } else {
        final data = response.data;
        if (data is Map && data['message'] != null) {
          throw Exception(data['message'].toString());
        }
        throw Exception('Failed to pick order');
      }
    } catch (e) {
      AppLogger.error('Exception in _pickOrder', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderFuture,
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
                    onPressed: _loadOrderDetails,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final order = snapshot.data!;
          return _buildOrderDetails(order);
        },
      ),
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> order) {
    final status = (order['status'] ?? 'Pending').toString();
    final rider = order['rider_id'];

    final isAvailable =
        rider == null && (status == 'Pending' || status == 'Confirmed');

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return _buildDesktopLayout(order, isAvailable);
        } else {
          return _buildMobileLayout(order, isAvailable);
        }
      },
    );
  }

  Widget _buildDesktopLayout(Map<String, dynamic> order, bool isAvailable) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Order Info
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildInfoCard(order),
                const SizedBox(height: 24),
                _buildCustomerCard(order),
                if (isAvailable) ...[
                  const SizedBox(height: 24),
                  _buildPickOrderButton(),
                ],
              ],
            ),
          ),
          const SizedBox(width: 32),
          // Right: Map
          Expanded(
            flex: 1,
            child: _buildMapCard(order),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(Map<String, dynamic> order, bool isAvailable) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMapCard(order),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildInfoCard(order),
                const SizedBox(height: 16),
                _buildCustomerCard(order),
                if (isAvailable) ...[
                  const SizedBox(height: 24),
                  _buildPickOrderButton(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> order) {
    final orderCode = (order['order_id'] ?? order['id'] ?? 'N/A').toString();
    final amount =
        double.tryParse((order['total_amount'] ?? '0').toString()) ?? 0.0;
    final status = (order['status'] ?? 'Pending').toString();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              const Text('Order Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          const Divider(height: 32),
          _buildInfoRow('Order ID',
              '#${orderCode.substring(orderCode.length >= 8 ? orderCode.length - 8 : 0)}'),
          const SizedBox(height: 12),
          _buildInfoRow('Total Amount', '\$${amount.toStringAsFixed(2)}',
              valueColor: const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _buildInfoRow(
              'Payment Type', (order['payment_type'] ?? 'Cash').toString()),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> order) {
    final customerName = (order['customer_name'] ?? 'N/A').toString();
    final customerPhone = (order['customer_phone'] ?? 'N/A').toString();
    final customerAddress =
        (order['customer_address'] ?? 'Not specified').toString();
    final pickupAddress =
        (order['pickup_address'] ?? 'Not specified').toString();
    final deliveryAddress =
        (order['delivery_address'] ?? customerAddress).toString();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          const Text('Delivery Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(height: 32),
          _buildLocationSection(
            'Pickup Location',
            pickupAddress,
            Icons.store,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 20),
          _buildLocationSection(
            'Delivery Location',
            deliveryAddress,
            Icons.location_on,
            const Color(0xFF10B981),
          ),
          const Divider(height: 32),
          _buildInfoRow('Customer Name', customerName),
          const SizedBox(height: 12),
          _buildInfoRow('Phone', customerPhone),
        ],
      ),
    );
  }

  Widget _buildMapCard(Map<String, dynamic> order) {
    final pickupAddress =
        (order['pickup_address'] ?? 'Not specified').toString();
    final deliveryAddress =
        (order['delivery_address'] ?? 'Not specified').toString();

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Mock Map Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.green.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CustomPaint(
                painter: MapGridPainter(),
                child: const SizedBox.expand(),
              ),
            ),
            // Markers
            Positioned(
              top: 80,
              left: 60,
              child: _buildMarker('A', 'Pickup', const Color(0xFF3B82F6)),
            ),
            Positioned(
              bottom: 80,
              right: 60,
              child: _buildMarker('B', 'Delivery', const Color(0xFF10B981)),
            ),
            // Route Line
            CustomPaint(
              painter: RoutePainter(),
              child: const SizedBox.expand(),
            ),
            // Map Label
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map, size: 16, color: Color(0xFF1E3A8A)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Route Map',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12)),
                        Text(
                          '$pickupAddress → $deliveryAddress',
                          style: const TextStyle(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarker(String label, String title, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(
      String title, String address, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(address,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: valueColor ?? const Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildPickOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isPickingOrder ? null : _pickOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isPickingOrder
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 24),
                  SizedBox(width: 12),
                  Text('Pick This Order',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

// Custom painter for map grid background
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for route line
class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(60, 100); // Start at pickup marker
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2,
      size.width - 60,
      size.height - 100, // End at delivery marker
    );

    // Draw dashed line
    const dashWidth = 10;
    const dashSpace = 5;
    double distance = 0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
