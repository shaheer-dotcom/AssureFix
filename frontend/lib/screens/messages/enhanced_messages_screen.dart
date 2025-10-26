import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'new_message_screen.dart';
import 'chat_screen.dart';

class EnhancedMessagesScreen extends StatefulWidget {
  const EnhancedMessagesScreen({super.key});

  @override
  State<EnhancedMessagesScreen> createState() => _EnhancedMessagesScreenState();
}

class _EnhancedMessagesScreenState extends State<EnhancedMessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isProvider = user?.profile?.userType == 'service_provider';
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Messages'),
            automaticallyImplyLeading: false,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  icon: const Icon(Icons.person),
                  text: isProvider ? 'From Customers' : 'From Providers',
                ),
                Tab(
                  icon: const Icon(Icons.business),
                  text: isProvider ? 'From Providers' : 'From Customers',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // First Tab - Messages from Customers (for providers) / Messages from Providers (for customers)
              _buildMessagesList(
                title: isProvider ? 'Messages from Customers' : 'Messages from Service Providers',
                emptyMessage: isProvider 
                    ? 'No customer messages yet\nCustomers will message you when they book your services'
                    : 'No provider messages yet\nMessages from service providers will appear here',
                icon: isProvider ? Icons.person : Icons.business,
              ),
              
              // Second Tab - Messages from Providers (for providers) / Messages from Customers (for customers)
              _buildMessagesList(
                title: isProvider ? 'Messages from Service Providers' : 'Messages from Customers',
                emptyMessage: isProvider 
                    ? 'No provider messages yet\nMessages from other service providers will appear here'
                    : 'No customer messages yet\nMessages from other customers will appear here',
                icon: isProvider ? Icons.business : Icons.person,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewMessageScreen(),
                ),
              );
            },
            backgroundColor: const Color(0xFF1565C0),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildMessagesList({
    required String title,
    required String emptyMessage,
    required IconData icon,
  }) {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              Icon(icon, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Messages List
        Expanded(
          child: _buildEmptyState(emptyMessage, icon),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Messages Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewMessageScreen(),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Start Conversation'),
          ),
        ],
      ),
    );
  }
}