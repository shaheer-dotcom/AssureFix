import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/auth_provider.dart';
import '../../providers/messages_provider.dart';
import 'chat_screen.dart';
import 'new_message_screen.dart';

class EnhancedMessagesScreen extends StatefulWidget {
  const EnhancedMessagesScreen({super.key});

  @override
  State<EnhancedMessagesScreen> createState() => _EnhancedMessagesScreenState();
}

class _EnhancedMessagesScreenState extends State<EnhancedMessagesScreen> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
    
    if (authProvider.token != null) {
      await messagesProvider.fetchConversations(authProvider.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, MessagesProvider>(
      builder: (context, authProvider, messagesProvider, child) {
        final user = authProvider.user;
        final currentUserId = user?.id ?? '';
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Messages'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadConversations,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _loadConversations,
            child: messagesProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : messagesProvider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(messagesProvider.error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadConversations,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : messagesProvider.conversations.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: messagesProvider.conversations.length,
                            itemBuilder: (context, index) {
                              final conversation = messagesProvider.conversations[index];
                              return _buildConversationTile(
                                conversation,
                                currentUserId,
                                authProvider.token!,
                              );
                            },
                          ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NewMessageScreen(),
                ),
              ).then((_) => _loadConversations());
            },
            backgroundColor: const Color(0xFF1565C0),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildConversationTile(Conversation conversation, String currentUserId, String token) {
    final otherParticipant = conversation.otherParticipant;
    final participantName = otherParticipant?['profile']?['name'] ?? 'User';
    final unreadCount = conversation.getUnreadCount(currentUserId);
    final lastMessageText = conversation.getLastMessageText();
    final isLastMessageFromMe = conversation.messages.isNotEmpty && 
        conversation.messages.last.senderId == currentUserId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF2E7D32),
        child: Text(
          participantName[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              participantName,
              style: TextStyle(
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            conversation.serviceName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isLastMessageFromMe)
                const Icon(Icons.done_all, size: 14, color: Colors.blue),
              if (isLastMessageFromMe) const SizedBox(width: 4),
              Expanded(
                child: Text(
                  lastMessageText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Text(
        timeago.format(conversation.lastMessage),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: conversation.id,
              otherUserName: participantName,
              serviceName: conversation.serviceName,
            ),
          ),
        ).then((_) => _loadConversations());
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Conversations Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Start a conversation by booking a service or messaging a provider',
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
              ).then((_) => _loadConversations());
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Start Conversation'),
          ),
        ],
      ),
    );
  }
}