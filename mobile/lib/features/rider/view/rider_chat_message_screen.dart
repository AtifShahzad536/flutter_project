import 'package:flutter/material.dart';
import 'package:export_trix/core/api/api_client.dart';
import 'package:export_trix/core/api/api_endpoints.dart';
import 'package:intl/intl.dart';

class RiderChatMessageScreen extends StatefulWidget {
  final Map<String, dynamic> chat;

  const RiderChatMessageScreen({super.key, required this.chat});

  @override
  State<RiderChatMessageScreen> createState() => _RiderChatMessageScreenState();
}

class _RiderChatMessageScreenState extends State<RiderChatMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ApiClient _apiClient = ApiClient.instance;
  List<dynamic> _messages = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final String contactId = widget.chat['id'].toString();
      final response =
          await _apiClient.get(ApiEndpoints.chatHistory(contactId));
      if (response['success'] == true) {
        setState(() {
          _messages = response['data'] ?? [];
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final String receiverId = widget.chat['id'].toString();
    _messageController.clear();

    try {
      final response = await _apiClient.post(ApiEndpoints.sendMessage, data: {
        'receiver_id': receiverId,
        'text': text,
      });

      if (response['success'] == true) {
        _fetchHistory();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
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
    final String contactName = widget.chat['name'] ?? 'Chat';
    final String image = widget.chat['image'] ??
        'https://ui-avatars.com/api/?name=$contactName&background=random';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contactName,
                      style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const Text('Online',
                      style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      // Assuming the API returns sender_id and we know our own ID?
                      // For now, let's assume if it's not the contactId, it's Me
                      final bool isMe = message['sender_id'].toString() !=
                          widget.chat['id'].toString();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF1E3A8A)
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                                  bottomRight: Radius.circular(isMe ? 0 : 16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                message['text'] ?? '',
                                style: TextStyle(
                                  color: isMe
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message['created_at'] ?? ''),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _messageController,
                      inputFormatters: const [],
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
