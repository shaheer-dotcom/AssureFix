import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/auth_provider.dart';
import '../../providers/messages_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../config/api_config.dart';
import 'whatsapp_chat_screen.dart';
import 'new_message_screen.dart';

class EnhancedMessagesScreen extends StatefulWidget {
  const EnhancedMessagesScreen({super.key});

  @override
  State<EnhancedMessagesScreen> createState() => _EnhancedMessagesScreenState();
}

class _EnhancedMessagesScreenState extends State<EnhancedMessagesScreen> {
  Timer? _pollingTimer;
  
  @override
  void initState() {
    super.initState();
    _loadConversations();
    _startPolling();
  }
  
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
  
  void _startPolling() {
    // Poll for new messages every 10 seconds (increased to reduce blinking)
    // Only poll if screen is visible and not already loading
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
        // Only load if not currently loading to prevent overlapping requests
        if (!messagesProvider.isLoading) {
          _loadConversations();
        }
      }
    });
  }

  Future<void> _loadConversations() async {
    final messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token != null) {
        await messagesProvider.fetchConversations(token);
      }
    } catch (e) {
      print('Error loading conversations: $e');
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

  Widget _buildProfileAvatar(String? profilePicture, String name) {
    if (profilePicture != null && profilePicture.isNotEmpty) {
      // Build full URL if it's a relative path
      String imageUrl = profilePicture;
      if (!profilePicture.startsWith('http')) {
        // Use ApiConfig for the base URL
        imageUrl = '${ApiConfig.baseUrlWithoutApi}$profilePicture';
      }

      return CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF2E7D32),
        child: ClipOval(
          child: Image.network(
            imageUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to initial if image fails to load
              return Container(
                width: 48,
                height: 48,
                color: const Color(0xFF2E7D32),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 48,
                height: 48,
                color: const Color(0xFF2E7D32),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // No profile picture - show initial
    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFF2E7D32),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLastMessageStatusIcon(Conversation conversation) {
    if (conversation.messages.isEmpty) {
      return const SizedBox.shrink();
    }

    final lastMessage = conversation.messages.last;
    final readAt = lastMessage.readAt;
    final deliveredAt = lastMessage.deliveredAt;

    // Message has been read - blue double checkmark
    if (readAt != null) {
      return const Icon(
        Icons.done_all,
        size: 16,
        color: Color(0xFF1565C0), // Blue color
      );
    }

    // Message has been delivered but not read - grey double checkmark
    if (deliveredAt != null) {
      return Icon(
        Icons.done_all,
        size: 16,
        color: Colors.grey.shade600,
      );
    }

    // Message sent but not delivered - single grey checkmark
    return Icon(
      Icons.done,
      size: 16,
      color: Colors.grey.shade600,
    );
  }

  Widget _buildConversationTile(Conversation conversation, String currentUserId) {
    final otherParticipant = conversation.otherParticipant;
    final participantName = otherParticipant?['profile']?['name'] ?? 'User';
    final participantId = otherParticipant?['_id'] ?? '';
    final participantAvatar = otherParticipant?['profile']?['profilePicture'] ?? '';
    final unreadCount = conversation.getUnreadCount(currentUserId);
    final lastMessageText = conversation.getLastMessageText();
    final isLastMessageFromMe = conversation.messages.isNotEmpty && 
        conversation.messages.last.senderId == currentUserId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        leading: _buildProfileAvatar(participantAvatar, participantName),
        title: Row(
          children: [
            Expanded(
              child: Text(
                participantName,
                style: TextStyle(
                  fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                  color: isDark ? Colors.white : Colors.black87,
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
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (isLastMessageFromMe) ...[
                  _buildLastMessageStatusIcon(conversation),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    lastMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                      color: isDark ? Colors.white70 : Colors.black87,
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
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WhatsAppChatScreen(
                conversationId: conversation.id,
                userName: participantName,
                userAvatar: participantName[0].toUpperCase(),
                otherUserId: participantId,
                onMessagesRead: () {
                  // Refresh conversations immediately when messages are marked as read
                  _loadConversations();
                },
              ),
            ),
          ).then((_) => _loadConversations());
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget.noMessages();
  }
}