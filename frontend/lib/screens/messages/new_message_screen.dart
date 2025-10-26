import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'chat_screen.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});

  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredUsers = [];
  
  // Sample users - in a real app, this would come from an API
  final List<Map<String, dynamic>> _allUsers = [
    {
      'id': '1',
      'name': 'John Smith',
      'type': 'Service Provider',
      'service': 'Plumbing',
      'avatar': 'J',
      'isOnline': true,
      'rating': 4.8,
    },
    {
      'id': '2',
      'name': 'Sarah Johnson',
      'type': 'Customer',
      'service': null,
      'avatar': 'S',
      'isOnline': false,
      'rating': null,
    },
    {
      'id': '3',
      'name': 'Mike Wilson',
      'type': 'Service Provider',
      'service': 'Electrical',
      'avatar': 'M',
      'isOnline': true,
      'rating': 4.9,
    },
    {
      'id': '4',
      'name': 'Emily Davis',
      'type': 'Customer',
      'service': null,
      'avatar': 'E',
      'isOnline': true,
      'rating': null,
    },
    {
      'id': '5',
      'name': 'David Brown',
      'type': 'Service Provider',
      'service': 'Cleaning',
      'avatar': 'D',
      'isOnline': false,
      'rating': 4.7,
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredUsers = _allUsers;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterUsers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          return user['name'].toLowerCase().contains(query.toLowerCase()) ||
                 (user['service']?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                 user['type'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterUsers,
            ),
          ),

          // Users List
          Expanded(
            child: _filteredUsers.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserTile(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: user['type'] == 'Service Provider' 
                ? const Color(0xFF1565C0) 
                : const Color(0xFF4CAF50),
            child: Text(
              user['avatar'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (user['isOnline'])
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        user['name'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user['type'],
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          if (user['service'] != null) ...[
            const SizedBox(height: 2),
            Text(
              user['service'],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (user['rating'] != null) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 2),
                Text(
                  user['rating'].toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
      onTap: () => _startChat(user),
    );
  }

  void _startChat(Map<String, dynamic> user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          conversationId: user['id'],
          userName: user['name'],
          userAvatar: user['avatar'],
        ),
      ),
    );
  }
}