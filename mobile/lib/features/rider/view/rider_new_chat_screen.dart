import 'package:flutter/material.dart';
import 'package:export_trix/core/api/api_client.dart';
import 'package:export_trix/core/api/api_endpoints.dart';
import 'package:export_trix/features/rider/view/rider_chat_message_screen.dart';

class RiderNewChatScreen extends StatefulWidget {
  const RiderNewChatScreen({super.key});

  @override
  State<RiderNewChatScreen> createState() => _RiderNewChatScreenState();
}

class _RiderNewChatScreenState extends State<RiderNewChatScreen> {
  final ApiClient _apiClient = ApiClient.instance;
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.users);
      if (response['success'] == true) {
        setState(() {
          _users = response['data'] ?? [];
          _filteredUsers = _users;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = user['name'].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Start New Chat',
            style: TextStyle(
                color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterUsers,
                decoration: const InputDecoration(
                  hintText: 'Search contacts...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, size: 20, color: Colors.grey),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('No users found'))
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final id = user['id'].toString();
                          final name = user['name'] ?? '';
                          final role = user['role'] ?? 'User';

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                  'https://ui-avatars.com/api/?name=$name&background=random'),
                            ),
                            title: Text(
                              name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(role.toUpperCase()),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RiderChatMessageScreen(
                                    chat: {
                                      'id': id,
                                      'name': name,
                                      'image':
                                          'https://ui-avatars.com/api/?name=$name&background=random',
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
