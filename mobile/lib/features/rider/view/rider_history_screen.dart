import 'package:flutter/material.dart';

class RiderHistoryScreen extends StatelessWidget {
  const RiderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for History
    final completedOrders = [
      {
        'id': '#ORD-9921',
        'date': '15 Dec, 10:30 AM',
        'earning': '\$12.50',
        'status': 'Delivered',
        'address': 'Sector F-10, Islamabad'
      },
      {
        'id': '#ORD-9918',
        'date': '14 Dec, 04:15 PM',
        'earning': '\$8.20',
        'status': 'Delivered',
        'address': 'Blue Area, Islamabad'
      },
      {
        'id': '#ORD-8822',
        'date': '14 Dec, 02:00 PM',
        'earning': '\$15.00',
        'status': 'Cancelled',
        'address': 'G-9 Markaz'
      },
      {
        'id': '#ORD-7721',
        'date': '13 Dec, 01:15 PM',
        'earning': '\$22.00',
        'status': 'Delivered',
        'address': 'DHA Phase 2'
      },
      {
        'id': '#ORD-6611',
        'date': '12 Dec, 11:00 AM',
        'earning': '\$9.50',
        'status': 'Delivered',
        'address': 'Bahria Town'
      },
      {
        'id': '#ORD-1123',
        'date': '11 Dec, 09:30 AM',
        'earning': '\$18.40',
        'status': 'Delivered',
        'address': 'E-11/2'
      },
      {
        'id': '#ORD-3321',
        'date': '10 Dec, 06:00 PM',
        'earning': '\$14.20',
        'status': 'Delivered',
        'address': 'F-7 Markaz'
      },
      {
        'id': '#ORD-4411',
        'date': '10 Dec, 01:20 PM',
        'earning': '\$7.50',
        'status': 'Cancelled',
        'address': 'I-8/3'
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return _buildDesktopLayout(completedOrders);
        } else {
          return _buildMobileLayout(completedOrders);
        }
      },
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout(List<Map<String, String>> completedOrders) {
    return Column(
      children: [
        // Custom Gradient Header
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)], // Indigo to Blue
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '${completedOrders.length} Completed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List View
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: completedOrders.length,
            itemBuilder: (context, index) {
              return _buildHistoryCard(completedOrders[index]);
            },
          ),
        ),
      ],
    );
  }

  // --- Desktop Layout ---
  Widget _buildDesktopLayout(List<Map<String, String>> completedOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Section (No Gradient, cleaner look)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Delivery History",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(
                    "You completed ${completedOrders.length} orders this month.",
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
            // The Container below cannot be const because Border.all is not a const constructor.
            // The instruction implies adding const, but it would lead to a compilation error.
            // Therefore, keeping it as is to maintain syntactical correctness.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.filter_list, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("Filter Date",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            )
          ],
        ),

        const SizedBox(height: 32),

        // Grid View of Cards
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400, // Responsive card width
              childAspectRatio: 2.2,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: completedOrders.length,
            itemBuilder: (context, index) {
              return _buildHistoryCard(completedOrders[index], isDesktop: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, String> order,
      {bool isDesktop = false}) {
    final isDelivered = order['status'] == 'Delivered';

    return Container(
      margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
        border: isDesktop ? Border.all(color: Colors.grey.shade100) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon Box
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDelivered
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isDelivered ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isDelivered
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    order['id']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order['address']!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    order['date']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),

            // Amount & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  order['earning']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDelivered
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order['status']!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDelivered
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
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
}
