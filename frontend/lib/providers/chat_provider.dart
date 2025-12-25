import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/api_config.dart';

class ChatProvider with ChangeNotifier {
  io.Socket? _socket;
  final List<Map<String, dynamic>> _messages = [];
  bool _isConnected = false;

  List<Map<String, dynamic>> get messages => _messages;
  bool get isConnected => _isConnected;

  void initSocket(String token) {
    // Use ApiConfig to get the correct base URL for APK
    final baseUrl = ApiConfig.baseUrlWithoutApi;
    _socket = io.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'Authorization': 'Bearer $token'}
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      notifyListeners();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      notifyListeners();
    });

    _socket!.on('receive_message', (data) {
      _messages.add(data);
      notifyListeners();
    });
  }

  void joinChat(String chatId) {
    _socket?.emit('join_chat', chatId);
  }

  void sendMessage(String chatId, Map<String, dynamic> messageData) {
    _socket?.emit('send_message', {
      'chatId': chatId,
      ...messageData,
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    _messages.clear();
    notifyListeners();
  }
}