import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Message {
  final String id;
  final String senderId;
  final String messageType;
  final Map<String, dynamic> content;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.messageType,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      senderId: json['senderId'] ?? '',
      messageType: json['messageType'] ?? 'text',
      content: json['content'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
    );
  }
}

class Conversation {
  final String id;
  final List<String> participants;
  final String serviceId;
  final String serviceName;
  final List<Message> messages;
  final String status;
  final DateTime lastMessage;
  final Map<String, dynamic>? otherParticipant;

  Conversation({
    required this.id,
    required this.participants,
    required this.serviceId,
    required this.serviceName,
    required this.messages,
    required this.status,
    required this.lastMessage,
    this.otherParticipant,
  });

  factory Conversation.fromJson(Map<String, dynamic> json, String currentUserId) {
    final participantsList = (json['participants'] as List)
        .map((p) => p is String ? p : p['_id'] as String)
        .toList();

    // Find the other participant
    Map<String, dynamic>? otherParticipant;
    if (json['participants'] is List) {
      for (var participant in json['participants']) {
        if (participant is Map && participant['_id'] != currentUserId) {
          otherParticipant = Map<String, dynamic>.from(participant);
          break;
        }
      }
    }

    return Conversation(
      id: json['_id'],
      participants: participantsList,
      serviceId: json['serviceId'] is String 
          ? json['serviceId'] 
          : (json['serviceId'] != null && json['serviceId'] is Map ? json['serviceId']['_id'] : '') ?? '',
      serviceName: json['serviceId'] is Map 
          ? (json['serviceId']['serviceName'] ?? 'Service')
          : 'Service',
      messages: (json['messages'] as List?)
              ?.map((m) => Message.fromJson(m))
              .toList() ??
          [],
      status: json['status'] ?? 'pending',
      lastMessage: DateTime.parse(json['lastMessage'] ?? json['createdAt']),
      otherParticipant: otherParticipant,
    );
  }

  String getLastMessageText() {
    if (messages.isEmpty) return 'No messages yet';
    final lastMsg = messages.last;
    if (lastMsg.messageType == 'text') {
      return lastMsg.content['text'] ?? '';
    } else if (lastMsg.messageType == 'voice') {
      return '🎤 Voice message';
    } else if (lastMsg.messageType == 'location') {
      return '📍 Location';
    }
    return 'Message';
  }

  int getUnreadCount(String currentUserId) {
    return messages.where((m) => m.senderId != currentUserId && !m.isRead).length;
  }
}

class MessagesProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get _baseUrl {
    return kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
  }

  Future<void> fetchConversations(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chat/my-chats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Get current user ID from token
        final tokenParts = token.split('.');
        if (tokenParts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(tokenParts[1]))),
          );
          final currentUserId = payload['userId'];

          _conversations = data
              .map((conv) => Conversation.fromJson(conv, currentUserId))
              .toList();
          _conversations.sort((a, b) => b.lastMessage.compareTo(a.lastMessage));
        }
      } else {
        _error = 'Failed to load conversations';
      }
    } catch (e) {
      _error = 'Error: $e';
      print('Error fetching conversations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Conversation?> getConversation(String token, String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chat/$chatId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Get current user ID from token
        final tokenParts = token.split('.');
        if (tokenParts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(tokenParts[1]))),
          );
          final currentUserId = payload['userId'];
          
          return Conversation.fromJson(data, currentUserId);
        }
      }
    } catch (e) {
      print('Error fetching conversation: $e');
    }
    return null;
  }

  Future<bool> sendMessage(
    String token,
    String chatId,
    String messageType,
    Map<String, dynamic> content,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat/$chatId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'messageType': messageType,
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        // Refresh conversations
        await fetchConversations(token);
        return true;
      }
    } catch (e) {
      print('Error sending message: $e');
    }
    return false;
  }

  Future<bool> markAsRead(String token, String chatId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/chat/$chatId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking as read: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
