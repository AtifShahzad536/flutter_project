import 'package:flutter/material.dart';
import 'package:export_trix/core/api/api_client.dart';
import 'package:export_trix/core/api/api_endpoints.dart';
import 'package:export_trix/features/rider/view/rider_chat_message_screen.dart';
import 'package:export_trix/features/rider/view/rider_new_chat_screen.dart';
import 'package:intl/intl.dart';

class RiderChatScreen extends StatefulWidget {
  const RiderChatScreen({super.key});

  @override
  State<RiderChatScreen> createState() => _RiderChatScreenState();
}

class _RiderChatScreenState extends State<RiderChatScreen> {
  final ApiClient _apiClient = ApiClient.instance;
  List<dynamic> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.chats);
      if (response['success'] == true) {
        setState(() {
          _conversations = response['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final DateTime dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return DateFormat.jm().format(dt);
      }
      return DateFormat.MMMd().format(dt);
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Messages',
            style: TextStyle(
                color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchConversations,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search messages...',
                        border: InputBorder.none,
                        icon: Icon(Icons.search, size: 20, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _conversations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('No messages yet',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchConversations,
                          child: ListView.builder(
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final chat = _conversations[index];
                              final contactId = chat['contact_id'].toString();

                              return InkWell(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          RiderChatMessageScreen(
                                        chat: {
                                          'id': contactId,
                                          'name': chat['contact_name'],
                                          'image':
                                              'https://ui-avatars.com/api/?name=${chat['contact_name']}&background=random',
                                          'isOnline': false,
                                        },
                                      ),
                                    ),
                                  );
                                  _fetchConversations();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundImage: NetworkImage(
                                            'https://ui-avatars.com/api/?name=${chat['contact_name']}&background=random'),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  chat['contact_name'] ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                                Text(
                                                  _formatTime(chat[
                                                      'last_message_time']),
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              chat['last_message'] ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
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
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RiderNewChatScreen()),
          );
          _fetchConversations();
        },
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }
}
