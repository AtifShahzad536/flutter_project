import 'package:flutter/material.dart';
import 'package:export_trix/core/utils/logger.dart';
import 'package:export_trix/core/constants/api_endpoints.dart';
import 'package:export_trix/features/auth/view/login_screen.dart';
import 'package:export_trix/features/rider/view/rider_history_screen.dart';
import 'package:export_trix/features/rider/view/rider_profile_screen.dart';
import 'package:export_trix/features/rider/view/rider_orders_screen.dart';
import 'package:export_trix/features/rider/view/order_detail_screen.dart';
import 'package:export_trix/core/widgets/responsive_layout.dart';
import 'package:export_trix/core/api/api_client.dart';
import 'package:export_trix/core/api/token_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:export_trix/features/rider/view/rider_notifications_screen.dart';
import 'package:export_trix/features/rider/view/rider_chat_screen.dart';

class RiderDashboardScreen extends StatefulWidget {
  const RiderDashboardScreen({super.key});

  @override
  State<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends State<RiderDashboardScreen> {
  bool _isOnline = true;
  int _selectedIndex = 0;
  // No longer using separate DashboardService
  Future<List<dynamic>>? _riderOrdersFuture;
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadRiderOrders();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await ApiClient.instance.dio.get(ApiEndpoints.profile);
      if (response.data['success'] == true) {
        setState(() {
          _userProfile = response.data['data'];
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error fetching user profile', e);
      setState(() => _isLoadingProfile = false);
    }
  }

  Future<void> _loadRiderOrders() async {
    setState(() {
      _riderOrdersFuture = _fetchRiderOrders();
    });
  }

  Future<List<dynamic>> _fetchRiderOrders() async {
    try {
      final response =
          await ApiClient.instance.dio.get(ApiEndpoints.riderOrders);
      if (response.data['success'] == true) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      AppLogger.debug('Error fetching rider orders: $e');
      return [];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  // --- Desktop Layout (Sidebar + Top Navbar) ---
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // 1. Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  height: 80,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.public,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'EXPORT TRIX',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 24),
                _buildSidebarItem(0, 'Dashboard', Icons.dashboard_rounded),
                _buildSidebarItem(1, 'Orders', Icons.shopping_bag_rounded),
                _buildSidebarItem(2, 'History', Icons.history_rounded),
                _buildSidebarItem(3, 'Profile', Icons.person_rounded),
                _buildSidebarItem(4, 'Settings', Icons.settings_rounded),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextButton.icon(
                      onPressed: _logout,
                      icon:
                          const Icon(Icons.logout, color: Colors.red, size: 20),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildHeaderIcon(Icons.notifications_outlined, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RiderNotificationsScreen()),
                            );
                          }),
                          const SizedBox(width: 16),
                          _buildHeaderIcon(Icons.chat_bubble_outline, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RiderChatScreen()),
                            );
                          }),
                          const SizedBox(width: 24),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFFEFF6FF),
                                child: _isLoadingProfile
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2))
                                    : Text(
                                        _userProfile != null &&
                                                _userProfile!['name'] != null
                                            ? _userProfile!['name']
                                                .toString()
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : "U",
                                        style: TextStyle(
                                            color: Colors.blue[800],
                                            fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      _userProfile != null
                                          ? _userProfile!['name'] ?? "User"
                                          : "Loading...",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  Text(
                                      _userProfile != null
                                          ? _userProfile!['role']
                                                  ?.toString()
                                                  .toUpperCase() ??
                                              "RIDER"
                                          : "Rider",
                                      style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12)),
                                ],
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.all(32),
                    child: _buildDesktopBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 20, color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildDesktopBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDesktopDashboard();
      case 1:
        return const RiderOrdersScreen();
      case 2:
        return const RiderHistoryScreen();
      case 3:
        return const RiderProfileScreen();
      default:
        return _buildDesktopDashboard();
    }
  }

  Widget _buildDesktopDashboard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          AppLogger.debug('Desktop dashboard error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;
        AppLogger.debug('Desktop dashboard data received: $data');
        final totalEarnings =
            double.tryParse((data['today_earnings'] ?? 0).toString()) ?? 0.0;
        final completedTrips = data['total_orders'] ?? 0;
        final activeTrips = data['active_orders'] ?? 0;
        final rating =
            double.tryParse((data['avg_rating'] ?? 0).toString()) ?? 0.0;
        final earningsGraph = data['earningsGraph'] ?? [];
        final activeOrder = data['active_order'];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Dashboard",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B))),
                      const SizedBox(height: 4),
                      Text("Here is what's happening today.",
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                  _buildStatusToggle(),
                ],
              ),
              const SizedBox(height: 32),
              _buildProfileAlert(),

              // Stats Grid
              SizedBox(
                height: 140,
                child: Row(
                  children: [
                    Expanded(
                        child: _buildStatItemDesktop(
                            title: "Total Earnings",
                            value: "\$${totalEarnings.toStringAsFixed(2)}",
                            icon: Icons.attach_money,
                            color: Colors.white,
                            startColor: const Color(0xFF10B981),
                            endColor: const Color(0xFF059669))),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildStatItemDesktop(
                            title: "Trips Done",
                            value: "$completedTrips",
                            icon: Icons.check_circle_outline,
                            color: Colors.white,
                            startColor: const Color(0xFFF59E0B),
                            endColor: const Color(0xFFD97706))),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildStatItemDesktop(
                            title: "Active Trips",
                            value: "$activeTrips",
                            icon: Icons.local_shipping_outlined,
                            color: const Color(0xFF1E293B),
                            startColor: Colors.white,
                            endColor: Colors.white,
                            isPlain: true)),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildStatItemDesktop(
                            title: "Rating",
                            value: rating.toString(),
                            icon: Icons.star_border,
                            color: const Color(0xFF1E293B),
                            startColor: Colors.white,
                            endColor: Colors.white,
                            isPlain: true)),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Monthly Trend
              const Text("Monthly Order Trend",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              Container(
                height: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _buildMonthlyOrdersChart(data['monthly_orders'] ?? []),
              ),

              // Earnings Chart
              if (earningsGraph.isNotEmpty) ...[
                const Text("Weekly Earnings",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _buildEarningsChart(data['earningsGraph'] ?? []),
                ),
                const SizedBox(height: 40),
              ],

              // Active Order Section
              if (activeOrder != null) ...[
                const Text("Active Order",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildActiveOrderCard(activeOrder),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  "https://mt.google.com/vt/lyrs=m&x=1325&y=3143&z=13"),
                              fit: BoxFit.cover,
                              opacity: 0.1,
                            )),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined,
                                  size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text("Live Tracking",
                                  style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],

              // Rider's Picked Orders
              _buildRiderOrdersSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiderOrdersSection() {
    return FutureBuilder<List<dynamic>>(
      future: _riderOrdersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text('Error loading orders: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadRiderOrders,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return const Center(
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No picked orders',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                SizedBox(height: 8),
                Text('Pick orders from the available orders screen',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("My Picked Orders",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                Text("${orders.length} orders",
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 16),
            ...orders.map((order) => _buildRiderOrderCard(order)),
          ],
        );
      },
    );
  }

  Widget _buildRiderOrderCard(Map<String, dynamic> order) {
    final orderCode = (order['order_id'] ?? order['id'] ?? 'N/A').toString();
    final amount =
        double.tryParse((order['total_amount'] ?? '0').toString()) ?? 0.0;
    final status = (order['status'] ?? 'Pending').toString();
    final customerName = (order['customer_name'] ?? 'Unknown').toString();
    final customerAddress =
        (order['customer_address'] ?? 'No address').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              Text(
                'Order #$orderCode',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(customerName, style: TextStyle(color: Colors.grey.shade700)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(customerAddress,
                    style: TextStyle(color: Colors.grey.shade700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to order details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderDetailScreen(orderId: order['id'].toString()),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
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

  Widget _buildEarningsChart(List<dynamic> data) {
    final spots = data.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final amount =
          double.tryParse((entry.value['amount'] ?? '0').toString()) ?? 0.0;
      return FlSpot(index, amount);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()]['day'] ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: const Color(0xFF10B981),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.3),
                  const Color(0xFF10B981).withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(Map<String, dynamic> order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: Color(0xFF3B82F6)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order #${order['order_id'] ?? order['id'] ?? 'N/A'}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Total: \$${order['total_amount'] ?? '0.00'}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(order['status'] ?? 'Pending',
                      style: const TextStyle(
                          color: Color(0xFF166534),
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 48),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DELIVERY ADDRESS",
                    style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
                const SizedBox(height: 8),
                Text(
                    order['customer_address'] ??
                        order['delivery_address'] ??
                        'No address provided',
                    style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16)),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {},
                    child: const Text("Details",
                        style: TextStyle(color: Colors.grey))),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(
                            orderId: (order['id'] ?? '').toString()),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text("View & Update"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchDashboardStats() async {
    try {
      final response =
          await ApiClient.instance.dio.get(ApiEndpoints.dashboardStats);
      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(response.data['message'] ?? 'Failed to load stats');
    } catch (e) {
      AppLogger.debug('Error fetching dashboard stats: $e');
      rethrow;
    }
  }

  Future<void> _logout() async {
    // Clear tokens and navigate to login
    await TokenStorage.clearToken();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildStatItemDesktop({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color startColor,
    required Color endColor,
    bool isPlain = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isPlain
            ? null
            : LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
        color: isPlain ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isPlain)
            BoxShadow(
                color: startColor.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 8)),
          if (isPlain)
            BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4)),
        ],
        border: isPlain ? Border.all(color: Colors.grey.shade200) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(
                      color: isPlain
                          ? Colors.grey.shade500
                          : Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              Icon(icon,
                  color: isPlain
                      ? Colors.grey.shade400
                      : Colors.white.withValues(alpha: 0.8),
                  size: 20),
            ],
          ),
          Text(value,
              style: TextStyle(
                  color: isPlain ? const Color(0xFF1E293B) : Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, String title, IconData icon) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  right: BorderSide(color: Color(0xFF1E3A8A), width: 3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[400],
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF1E40AF),
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_rounded), label: 'Orders'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: 'History'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const RiderOrdersScreen();
      case 2:
        return const RiderHistoryScreen();
      case 3:
        return const RiderProfileScreen();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildProfileAlert() {
    if (_userProfile == null) return const SizedBox.shrink();

    final missingFields = <String>[];
    if (_userProfile!['cnic'] == null ||
        _userProfile!['cnic'].toString().isEmpty) {
      missingFields.add('CNIC');
    }
    if (_userProfile!['bike_model'] == null ||
        _userProfile!['bike_model'].toString().isEmpty) {
      missingFields.add('Bike Model');
    }
    if (_userProfile!['bike_plate'] == null ||
        _userProfile!['bike_plate'].toString().isEmpty) {
      missingFields.add('Bike Number');
    }

    if (missingFields.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Incomplete',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  'Please fill your ${missingFields.join(", ")} in the profile section.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 3; // Profile tab
              });
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyOrdersChart(List<dynamic> monthlyData) {
    if (monthlyData.isEmpty) {
      return const Center(child: Text('No monthly data available'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: monthlyData
                .map((e) => (e['orders'] as int).toDouble())
                .reduce((a, b) => a > b ? a : b) +
            2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                int index = value.toInt();
                if (index >= 0 && index < monthlyData.length) {
                  return Text(monthlyData[index]['month'] ?? '',
                      style: const TextStyle(fontSize: 10));
                }
                return const Text('');
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: monthlyData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: (entry.value['orders'] as int).toDouble(),
                color: const Color(0xFF3B82F6),
                width: 16,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHomeTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchDashboardStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ));
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 60, left: 24, right: 24, bottom: 30),
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoadingProfile
                                  ? 'Loading...'
                                  : (_userProfile != null
                                      ? _userProfile!['name'] ?? 'User'
                                      : 'User'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RiderNotificationsScreen()),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RiderChatScreen()),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.logout,
                                    color: Colors.white),
                                onPressed: _logout,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildStatusToggle(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileAlert(),
                    _buildStatsGrid(data),
                    const SizedBox(height: 30),
                    const Text(
                      "Monthly Order Trend",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildMonthlyOrdersChart(
                          data['monthly_orders'] ?? []),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Earnings Overview",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildEarningsChart(data['earningsGraph'] ?? []),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Ongoing Task",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 16),
                    _buildActiveTaskCard(data['active_order']),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isOnline ? const Color(0xFF34D399) : Colors.redAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      (_isOnline ? const Color(0xFF34D399) : Colors.redAccent)
                          .withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _isOnline ? "You are Online" : "You are Offline",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(width: 12),
          Switch(
            value: _isOnline,
            onChanged: (value) {
              setState(() {
                _isOnline = value;
              });
            },
            activeThumbColor: const Color(0xFF34D399),
            inactiveThumbColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> data) {
    final earnings =
        double.tryParse((data['today_earnings'] ?? 0).toString()) ?? 0.0;
    final trips = data['total_orders'] ?? 0;
    final activeTrips = data['active_orders'] ?? 0;
    final rating = double.tryParse((data['avg_rating'] ?? 0).toString()) ?? 0.0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Earnings', '\$${earnings.toStringAsFixed(2)}',
            Icons.attach_money, Colors.green),
        _buildStatCard(
            'Trips Done', trips.toString(), Icons.check_circle, Colors.blue),
        _buildStatCard('Active', activeTrips.toString(), Icons.local_shipping,
            Colors.orange),
        _buildStatCard('Rating', rating.toString(), Icons.star, Colors.amber),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTaskCard(Map<String, dynamic>? order) {
    if (order == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No active tasks",
                style: TextStyle(
                    color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Pick an order from the available orders screen",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              Text(
                'Order #${order['order_id'] ?? order['id'] ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order['status'] ?? 'Pending',
                  style: TextStyle(
                    color: Colors.green.shade700,
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
              Icon(Icons.store, color: Colors.blue.shade400, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order['pickup_address'] ?? 'No pickup address',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.red.shade400, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order['customer_address'] ??
                      order['delivery_address'] ??
                      'No delivery address',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(
                        orderId: (order['id'] ?? '').toString()),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('View & Update Status'),
            ),
          ),
        ],
      ),
    );
  }
}
