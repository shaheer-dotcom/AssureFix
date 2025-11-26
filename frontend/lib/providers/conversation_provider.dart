import 'package:flutter/material.dart';

class ConversationProvider with ChangeNotifier {
  static final ConversationProvider _instance = ConversationProvider._internal();
  factory ConversationProvider() => _instance;
  ConversationProvider._internal();

  final List<Map<String, dynamic>> _conversations = [];
  final Map<String, List<Map<String, dynamic>>> _messages = {};

  List<Map<String, dynamic>> get conversations => _conversations;

  void addConversation(String userId, String userName, String userAvatar) {
    // Check if conversation already exists
    final existingIndex = _conversations.indexWhere((conv) => conv['id'] == userId);
    
    if (existingIndex == -1) {
      _conversations.insert(0, {
        'id': userId,
        'name': userName,
        'lastMessage': 'Started conversation',
        'time': _formatTime(DateTime.now()),
        'unreadCount': 0,
        'avatar': userAvatar,
        'isOnline': true,
      });
      
      // Initialize messages for this conversation
      _messages[userId] = [];
      
      notifyListeners();
    }
  }

  void addMessage(String conversationId, String message, bool isMe) {
    // Add message to conversation
    if (!_messages.containsKey(conversationId)) {
      _messages[conversationId] = [];
    }
    
    _messages[conversationId]!.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': message,
      'isMe': isMe,
      'time': _formatTime(DateTime.now()),
      'type': 'text',
    });

    // Update conversation last message
    final conversationIndex = _conversations.indexWhere((conv) => conv['id'] == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex]['lastMessage'] = message;
      _conversations[conversationIndex]['time'] = _formatTime(DateTime.now());
      
      if (!isMe) {
        _conversations[conversationIndex]['unreadCount'] = 
            (_conversations[conversationIndex]['unreadCount'] ?? 0) + 1;
      }
      
      // Move conversation to top
      final conversation = _conversations.removeAt(conversationIndex);
      _conversations.insert(0, conversation);
    }

    notifyListeners();
  }

  void addVoiceMessage(String conversationId, String voiceNotePath, bool isMe, int duration) {
    if (!_messages.containsKey(conversationId)) {
      _messages[conversationId] = [];
    }
    
    _messages[conversationId]!.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'voicePath': voiceNotePath,
      'duration': duration,
      'isMe': isMe,
      'time': _formatTime(DateTime.now()),
      'type': 'voice',
    });

    // Update conversation last message
    final conversationIndex = _conversations.indexWhere((conv) => conv['id'] == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex]['lastMessage'] = '🎵 Voice message';
      _conversations[conversationIndex]['time'] = _formatTime(DateTime.now());
      
      if (!isMe) {
        _conversations[conversationIndex]['unreadCount'] = 
            (_conversations[conversationIndex]['unreadCount'] ?? 0) + 1;
      }
      
      // Move conversation to top
      final conversation = _conversations.removeAt(conversationIndex);
      _conversations.insert(0, conversation);
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  void markAsRead(String conversationId) {
    final conversationIndex = _conversations.indexWhere((conv) => conv['id'] == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex]['unreadCount'] = 0;
      notifyListeners();
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  // Initialize with some demo conversations
  void initializeDemoConversations() {
    if (_conversations.isEmpty) {
      _conversations.addAll([
        {
          'id': 'demo1',
          'name': 'Anjiya Baaji',
          'lastMessage': 'how are you?',
          'time': '20 hours ago',
          'unreadCount': 3,
          'avatar': 'A',
          'isOnline': false,
          'role': 'electrician',
        },
        {
          'id': 'demo2',
          'name': 'Sarah Wilson',
          'lastMessage': 'When can you start the work?',
          'time': '1 hour ago',
          'unreadCount': 0,
          'avatar': 'S',
          'isOnline': false,
        },
        {
          'id': 'demo3',
          'name': 'Mike Johnson',
          'lastMessage': 'I need plumbing service urgently',
          'time': '3 hours ago',
          'unreadCount': 1,
          'avatar': 'M',
          'isOnline': true,
        },
      ]);

      // Initialize demo messages
      _messages['demo1'] = [
        {
          'id': '1',
          'text': 'Hi, I need electrical work done',
          'isMe': true,
          'time': 'Yesterday',
          'type': 'text',
        },
        {
          'id': '2',
          'text': 'Sure! I can help you with that',
          'isMe': false,
          'time': 'Yesterday',
          'type': 'text',
        },
        {
          'id': '3',
          'text': 'how are you?',
          'isMe': false,
          'time': '20 hours ago',
          'type': 'text',
        },
      ];

      _messages['demo2'] = [
        {
          'id': '1',
          'text': 'Hello, I saw your plumbing service',
          'isMe': false,
          'time': '2:00 PM',
          'type': 'text',
        },
        {
          'id': '2',
          'text': 'Yes, I provide plumbing services. How can I help?',
          'isMe': true,
          'time': '2:05 PM',
          'type': 'text',
        },
        {
          'id': '3',
          'text': 'When can you start the work?',
          'isMe': false,
          'time': '1 hour ago',
          'type': 'text',
        },
      ];

      _messages['demo3'] = [
        {
          'id': '1',
          'text': 'I need plumbing service urgently',
          'isMe': false,
          'time': '3 hours ago',
          'type': 'text',
        },
      ];
    }
  }
}