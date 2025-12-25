import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import '../../utils/constants.dart';
import '../../utils/token_manager.dart';

class EnhancedChatScreen extends StatefulWidget {
  final String conversationId;
  final String otherUserName;
  final bool isActive;

  const EnhancedChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
    required this.isActive,
  });

  @override
  State<EnhancedChatScreen> createState() => _EnhancedChatScreenState();
}

class _EnhancedChatScreenState extends State<EnhancedChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<dynamic> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _getCurrentUserId();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUserId() async {
    final token = await TokenManager.getToken();
    if (token != null) {
      final payload = json.decode(
        utf8.decode(base64.decode(base64.normalize(token.split('.')[1]))),
      );
      setState(() {
        _currentUserId = payload['userId'];
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('${Constants.apiUrl}/messages/${widget.conversationId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages = data['messages'];
          _isLoading = false;
        });
        _scrollToBottom();
        _markMessagesAsRead();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      final token = await TokenManager.getToken();
      // Mark all messages in this conversation as read
      await http.patch(
        Uri.parse('${Constants.apiUrl}/messages/conversations/${widget.conversationId}/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    } catch (e) {
      // Ignore errors
      print('Error marking messages as read: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendTextMessage() async {
    if (_messageController.text.trim().isEmpty || !widget.isActive) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      final token = await TokenManager.getToken();
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'conversationId': widget.conversationId,
          'messageType': 'text',
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        await _loadMessages();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendImage() async {
    if (!widget.isActive) return;

    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isSending = true);

    try {
      final token = await TokenManager.getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.apiUrl}/messages/upload-media'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['conversationId'] = widget.conversationId;
      request.fields['messageType'] = 'image';
      request.files.add(await http.MultipartFile.fromPath('media', image.path));

      final response = await request.send();
      if (response.statusCode == 201) {
        await _loadMessages();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send image: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendLocation() async {
    if (!widget.isActive) return;

    setState(() => _isSending = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition();

      final token = await TokenManager.getToken();
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'conversationId': widget.conversationId,
          'messageType': 'location',
          'location': {
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        }),
      );

      if (response.statusCode == 201) {
        await _loadMessages();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share location: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          if (!widget.isActive)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.orange[100],
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This booking is completed or cancelled. You can view messages but cannot send new ones.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('No messages yet'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isSentByMe = message['senderId']['_id'] == _currentUserId;
                          return _buildMessageBubble(message, isSentByMe);
                        },
                      ),
          ),
          if (widget.isActive) _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isSentByMe) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSentByMe ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageContent(message),
            const SizedBox(height: 4),
            Text(
              _formatTime(message['createdAt']),
              style: TextStyle(
                fontSize: 10,
                color: isSentByMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> message) {
    switch (message['messageType']) {
      case 'text':
        return Text(
          message['content'],
          style: TextStyle(
            color: message['senderId']['_id'] == _currentUserId ? Colors.white : Colors.black87,
          ),
        );
      case 'image':
        return Image.network(
          '${Constants.apiUrl}/${message['content']}',
          width: 200,
          errorBuilder: (context, error, stackTrace) => const Text('Image not available'),
        );
      case 'location':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on, color: Colors.red),
            Text('Location: ${message['location']['latitude']}, ${message['location']['longitude']}'),
          ],
        );
      case 'voice':
        return const Row(
          children: [
            Icon(Icons.mic, size: 20),
            SizedBox(width: 8),
            Text('Voice message'),
          ],
        );
      default:
        return const Text('Unsupported message type');
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _isSending ? null : _sendImage,
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _isSending ? null : _sendLocation,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
              maxLines: null,
              enabled: !_isSending,
            ),
          ),
          IconButton(
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isSending ? null : _sendTextMessage,
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
