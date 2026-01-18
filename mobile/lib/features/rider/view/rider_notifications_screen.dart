import 'package:flutter/material.dart';
import 'package:export_trix/core/api/api_client.dart';
import 'package:export_trix/core/api/api_endpoints.dart';
import 'package:intl/intl.dart';

class RiderNotificationsScreen extends StatefulWidget {
  const RiderNotificationsScreen({super.key});

  @override
  State<RiderNotificationsScreen> createState() =>
      _RiderNotificationsScreenState();
}

class _RiderNotificationsScreenState extends State<RiderNotificationsScreen> {
  final ApiClient _apiClient = ApiClient.instance;
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.notifications);
      if (response['success'] == true) {
        setState(() {
          _notifications = response['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _apiClient
          .post(ApiEndpoints.markNotificationRead, data: {'id': id});
      _fetchNotifications(); // Refresh list
    } catch (e) {
      // SILENT error or log
    }
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Icons.local_shipping;
      case 'earnings':
        return Icons.account_balance_wallet;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return Colors.blue;
      case 'earnings':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _formatTime(String timestamp) {
    try {
      final DateTime dt = DateTime.parse(timestamp);
      return DateFormat.jm().format(dt);
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(
                color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No notifications yet',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final bool isRead = notification['is_read'] == 1;
                      final type = notification['type'] ?? 'system';

                      return InkWell(
                        onTap: () {
                          if (!isRead) {
                            _markAsRead(notification['id']);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: isRead
                                    ? Colors.grey.shade100
                                    : Colors.blue.shade100,
                                width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getColor(type).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(_getIcon(type),
                                  color: _getColor(type), size: 24),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification['title'] ?? '',
                                    style: TextStyle(
                                      fontWeight: isRead
                                          ? FontWeight.w600
                                          : FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  _formatTime(notification['created_at'] ?? ''),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                notification['body'] ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
