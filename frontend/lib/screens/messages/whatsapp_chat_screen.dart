import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/api_config.dart';
import '../../services/voice_call_service.dart';
import '../../services/media_picker_service.dart';
import '../../services/location_service.dart';
import '../../services/voice_recording_service.dart';
import '../profile/user_profile_view_screen.dart';
import '../calls/voice_call_screen.dart';

class WhatsAppChatScreen extends StatefulWidget {
  final String conversationId;
  final String userName;
  final String userAvatar;
  final String? otherUserId; // ID of the other user in the conversation
  final VoidCallback?
      onMessagesRead; // Callback when messages are marked as read
  final VoidCallback? onNewMessage; // Callback when new message arrives

  const WhatsAppChatScreen({
    super.key,
    required this.conversationId,
    required this.userName,
    required this.userAvatar,
    this.otherUserId,
    this.onMessagesRead,
    this.onNewMessage,
  });

  @override
  State<WhatsAppChatScreen> createState() => _WhatsAppChatScreenState();
}

class _WhatsAppChatScreenState extends State<WhatsAppChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isRecording = false;
  bool _isSendingImage = false;
  bool _isSendingLocation = false;
  bool _isSendingVoice = false;
  String? _currentUserId;
  String? _playingVoiceId;
  String? _receiverProfilePicture;
  bool _isLoadingProfile = true;
  int _recordingElapsedSeconds = 0;
  Duration? _playbackPosition;
  Duration? _playbackDuration;
  bool _isChatActive = true;
  String? _chatClosedReason;
  bool _isCheckingChatStatus = false;

  // Pagination variables
  int _currentPage = 1;
  final int _messagesPerPage = 50;
  bool _hasMoreMessages = true;
  bool _isLoadingMore = false;

  // Real-time polling
  Timer? _messagePollingTimer;

  String get _baseUrl {
    return ApiConfig.baseUrlWithoutApi;
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadReceiverProfile();
    _checkChatStatus();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Start polling for new messages every 2 seconds
    _startMessagePolling();

    // Listen to playback completion
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _playingVoiceId = null;
        _playbackPosition = null;
        _playbackDuration = null;
      });
    });

    // Listen to playback position changes
    _audioPlayer.onPositionChanged.listen((position) {
      if (_playingVoiceId != null) {
        setState(() {
          _playbackPosition = position;
        });
      }
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      if (_playingVoiceId != null) {
        setState(() {
          _playbackDuration = duration;
        });
      }
    });
  }

  void _onScroll() {
    // Load more messages when scrolled to bottom (since ListView is reversed, bottom = older messages)
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // When reversed, scrolling down (positive direction) loads older messages
      if (currentScroll >= maxScroll - 100 &&
          !_isLoadingMore &&
          _hasMoreMessages &&
          !_isLoading) {
        _loadMoreMessages();
      }
    }
  }

  Future<void> _loadReceiverProfile() async {
    if (widget.otherUserId == null) {
      setState(() {
        _isLoadingProfile = false;
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('$_baseUrl/api/users/profile/${widget.otherUserId}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _receiverProfilePicture = data['profile']?['profilePicture'];
            _isLoadingProfile = false;
          });
        } else {
          setState(() {
            _isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      print('Error loading receiver profile: $e');
      setState(() {
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _checkChatStatus() async {
    setState(() {
      _isCheckingChatStatus = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http.get(
          Uri.parse('$_baseUrl/api/chat/${widget.conversationId}/status'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final chatStatus = data['chatStatus'];
          final closedReason = data['closedReason'];

          setState(() {
            _isChatActive = chatStatus != 'closed';
            _chatClosedReason = closedReason;
            _isCheckingChatStatus = false;
          });
        } else {
          setState(() {
            _isCheckingChatStatus = false;
          });
        }
      }
    } catch (e) {
      print('Error checking chat status: $e');
      setState(() {
        _isCheckingChatStatus = false;
      });
    }
  }

  Future<void> _loadMessages({bool isInitialLoad = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        // Get current user ID from token
        final tokenParts = token.split('.');
        if (tokenParts.length == 3) {
          final payload = json.decode(
            utf8.decode(base64Url.decode(base64Url.normalize(tokenParts[1]))),
          );
          _currentUserId = payload['userId'];
        }

        // Build URL with pagination parameters
        final uri =
            Uri.parse('$_baseUrl/api/chat/${widget.conversationId}').replace(
          queryParameters: {
            'page': _currentPage.toString(),
            'limit': _messagesPerPage.toString(),
          },
        );

        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final newMessages =
              List<Map<String, dynamic>>.from(data['messages'] ?? []);

          setState(() {
            if (isInitialLoad) {
              _messages = newMessages;
            } else {
              // For pagination, prepend older messages
              _messages = [...newMessages, ..._messages];
            }
            _hasMoreMessages = newMessages.length >= _messagesPerPage;
            _isLoading = false;
          });

          if (isInitialLoad) {
            // With reverse: true, ListView automatically starts at bottom
            // No need to scroll
            // Mark messages as delivered first, then as read
            await _markAsDelivered(token);
            await _markAsRead(token);
          }
        }
      }
    } catch (e) {
      print('Error loading messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        // Save current scroll position
        final currentScrollPosition = _scrollController.position.pixels;
        final currentMaxScrollExtent =
            _scrollController.position.maxScrollExtent;

        // Increment page and load
        _currentPage++;

        // Build URL with pagination parameters
        final uri =
            Uri.parse('$_baseUrl/api/chat/${widget.conversationId}').replace(
          queryParameters: {
            'page': _currentPage.toString(),
            'limit': _messagesPerPage.toString(),
          },
        );

        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final newMessages =
              List<Map<String, dynamic>>.from(data['messages'] ?? []);

          setState(() {
            // Prepend older messages
            _messages = [...newMessages, ..._messages];
            _hasMoreMessages = newMessages.length >= _messagesPerPage;
            _isLoadingMore = false;
          });

          // Restore scroll position after new messages are added
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final newMaxScrollExtent =
                  _scrollController.position.maxScrollExtent;
              final scrollDelta = newMaxScrollExtent - currentMaxScrollExtent;
              _scrollController.jumpTo(currentScrollPosition + scrollDelta);
            }
          });
        } else {
          setState(() {
            _isLoadingMore = false;
          });
        }
      }
    } catch (e) {
      print('Error loading more messages: $e');
      setState(() {
        _isLoadingMore = false;
        _currentPage--; // Revert page increment on error
      });
    }
  }

  Future<void> _markAsDelivered(String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/chat/${widget.conversationId}/delivered'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Update delivery status locally WITHOUT setState to prevent blinking
        // The status will be updated on next natural refresh (when new message arrives)
        for (var message in _messages) {
          if (message['senderId'] != _currentUserId) {
            message['deliveredAt'] = DateTime.now().toIso8601String();
          }
        }
      }
    } catch (e) {
      print('Error marking as delivered: $e');
    }
  }

  Future<void> _markAsRead(String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/chat/${widget.conversationId}/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Update read status locally
        for (var message in _messages) {
          final senderId = message['senderId'] is String
              ? message['senderId']
              : message['senderId']?['_id'];
          if (senderId != _currentUserId) {
            message['readAt'] = DateTime.now().toIso8601String();
            message['isRead'] = true;
          }
        }

        // Notify parent to refresh conversations list immediately
        if (widget.onMessagesRead != null) {
          widget.onMessagesRead!();
        }
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    // Check if chat is active before sending
    if (!_isChatActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_chatClosedReason == 'completed'
              ? 'Cannot send messages. The booking has been completed.'
              : 'Cannot send messages. The booking has been cancelled.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http
            .post(
          Uri.parse('$_baseUrl/api/chat/${widget.conversationId}/messages'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'messageType': 'text',
            'content': {'text': messageText},
          }),
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception(
                'Network timeout. Please check your internet connection.');
          },
        );

        if (response.statusCode == 200) {
          await _loadMessages();

          // Notify parent about new message sent
          if (widget.onNewMessage != null) {
            widget.onNewMessage!();
          }
        } else if (response.statusCode == 400) {
          // Handle chat closed error from backend
          final data = json.decode(response.body);
          if (data['chatStatus'] == 'closed') {
            setState(() {
              _isChatActive = false;
              _chatClosedReason = data['closedReason'];
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data['message'] ?? 'Chat is closed'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        } else if (response.statusCode == 403) {
          // Handle block status
          final data = json.decode(response.body);
          if (data['blocked'] == true) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(data['message'] ?? 'Cannot send messages'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          } else {
            throw Exception('Access denied');
          }
        } else {
          throw Exception('Failed to send message. Please try again.');
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        _showNetworkErrorDialog(
          message: e.toString(),
          pendingMessage: messageText,
          onRetry: () {
            _messageController.text = messageText;
            _sendMessage();
          },
        );
      }
    }
  }

  void _scrollToBottom() {
    // With reverse: true, position 0 is at bottom, so we scroll to 0
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0, // Scroll to position 0 (bottom in reversed list)
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Initiate an outgoing voice call to the other user
  ///
  /// Incoming calls are handled by CallNotificationService which is initialized
  /// in MainNavigation. When a push notification for an incoming call is received,
  /// CallNotificationService.handleIncomingCall() will navigate to VoiceCallScreen
  /// with isIncoming=true.
  Future<void> _initiateVoiceCall() async {
    if (widget.otherUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot initiate call: User ID not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Initiate call through backend
      final callData = await VoiceCallService.initiateCall(
        receiverId: widget.otherUserId!,
        conversationId: widget.conversationId,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Navigate to voice call screen
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceCallScreen(
              callId: callData['callId'],
              receiverId: widget.otherUserId!,
              receiverName: widget.userName,
              receiverProfilePicture: null, // Will be enhanced in future tasks
              isIncoming: false,
              channelName: callData['channelName'],
              token: callData['token'],
              uid: callData['uid'],
            ),
          ),
        );

        // Handle call result
        if (result != null && mounted) {
          if (result['status'] == 'ended') {
            final duration = result['duration'] ?? 0;
            final message = result['message'];
            if (message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (duration > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Call ended (${duration}s)'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
          // Error dialog is already shown by VoiceCallScreen for failed calls
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {
          // Dialog might already be closed
        }
      }

      if (mounted) {
        _showCallErrorDialog(
          message: e.toString(),
          onRetry: _initiateVoiceCall,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: InkWell(
          onTap: () {
            if (widget.otherUserId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileViewScreen(
                    userId: widget.otherUserId!,
                    userName: widget.userName,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('User ID not available'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          child: Row(
            children: [
              _isLoadingProfile
                  ? const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF2E7D32),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : _receiverProfilePicture != null &&
                          _receiverProfilePicture!.isNotEmpty
                      ? CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF2E7D32),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl:
                                  '${ApiConfig.baseUrlWithoutApi}$_receiverProfilePicture',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              // Cache profile pictures efficiently
                              memCacheWidth: 72, // 2x for retina displays
                              memCacheHeight: 72,
                              maxWidthDiskCache: 100,
                              maxHeightDiskCache: 100,
                              placeholder: (context, url) => const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (context, url, error) => Text(
                                widget.userAvatar.isNotEmpty
                                    ? widget.userAvatar[0].toUpperCase()
                                    : widget.userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF2E7D32),
                          child: Text(
                            widget.userAvatar.isNotEmpty
                                ? widget.userAvatar[0].toUpperCase()
                                : widget.userName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Tap for more info',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (widget.otherUserId != null) ...[
            IconButton(
              icon: const Icon(Icons.call),
              tooltip: 'Voice Call',
              onPressed: _initiateVoiceCall,
            ),
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'View Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileViewScreen(
                      userId: widget.otherUserId!,
                      userName: widget.userName,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Display closed chat banner if chat is not active
          if (!_isChatActive && !_isCheckingChatStatus)
            _buildClosedChatBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start the conversation',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        reverse: true, // Show newest messages at bottom
                        itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Show loading indicator at the bottom (since reversed)
                          if (index == 0 && _isLoadingMore) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF1565C0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Loading older messages...',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // Adjust index if loading indicator is shown
                          final messageIndex =
                              _isLoadingMore ? index - 1 : index;
                          // Reverse index since ListView is reversed
                          final reversedIndex =
                              _messages.length - 1 - messageIndex;
                          return _buildMessageBubble(_messages[reversedIndex]);
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Handle senderId as both string and object (populated)
    final senderId = message['senderId'] is String
        ? message['senderId']
        : message['senderId']?['_id'] ?? message['senderId'];
    final isMe = senderId?.toString() == _currentUserId?.toString();
    final messageType = message['messageType'] ?? 'text';
    final messageText = message['content']?['text'] ?? '';
    final timestamp = message['timestamp'] != null
        ? DateTime.parse(message['timestamp'])
        : DateTime.now();
    final timeString = DateFormat('HH:mm').format(timestamp);
    final messageId = message['_id'] ??
        message['id'] ??
        DateTime.now().millisecondsSinceEpoch.toString();

    return Align(
      key: Key('message_$messageId'),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMe ? 50 : 8, // More margin on left for sent messages
          right: isMe ? 8 : 50, // More margin on right for received messages
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? (isDark
                  ? const Color(0xFF005C4B)
                  : const Color(0xFFDCF8C6)) // Dark green in dark mode
              : (isDark
                  ? const Color(0xFF2C2C2C)
                  : Colors.white), // Dark gray in dark mode
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message['senderId']?['profile']?['name'] ?? widget.userName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
            // Message content based on type
            if (messageType == 'image') _buildLazyImageMessage(message),
            if (messageType == 'location')
              GestureDetector(
                onTap: () async {
                  print('Location message tapped');
                  final lat = message['content']?['latitude'];
                  final lng = message['content']?['longitude'];
                  print('Location coordinates: lat=$lat, lng=$lng');

                  if (lat != null && lng != null) {
                    try {
                      print('Opening location in maps...');
                      await LocationService.openInMaps(
                        lat is double ? lat : double.parse(lat.toString()),
                        lng is double ? lng : double.parse(lng.toString()),
                      );
                      print('Successfully opened maps');
                    } catch (e) {
                      print('Error opening maps: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Failed to open maps: ${e.toString().replaceAll('Exception: ', '')}'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  } else {
                    print('No coordinates found in message');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isMe ? const Color(0xFFE3F2FD) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isMe
                          ? const Color(0xFF1565C0).withOpacity(0.3)
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 24,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(minWidth: 200),
                        child: Text(
                          message['content']?['address'] ?? 'View on map',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map,
                            size: 14,
                            color: const Color(0xFF1565C0),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Tap to open in maps',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (messageType == 'voice') _buildVoiceMessageBubble(message, isMe),
            if (messageType != 'image' &&
                messageType != 'location' &&
                messageType != 'voice')
              Text(
                messageText,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _buildMessageStatusIcon(message),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLazyImageMessage(Map<String, dynamic> message) {
    final imageUrl = message['content']?['imageUrl'];

    return GestureDetector(
      onTap: () {
        // Show full image
        if (imageUrl != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => _FullScreenImageView(
                imageUrl: '${ApiConfig.baseUrlWithoutApi}$imageUrl',
              ),
            ),
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: '${ApiConfig.baseUrlWithoutApi}$imageUrl',
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          // Use memory cache and disk cache for better performance
          memCacheWidth: 400, // Cache at 2x resolution for quality
          memCacheHeight: 400,
          maxWidthDiskCache: 600,
          maxHeightDiskCache: 600,
          placeholder: (context, url) => Container(
            width: 200,
            height: 200,
            color: Colors.grey.shade200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: 200,
            height: 200,
            color: Colors.grey.shade300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 50,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageStatusIcon(Map<String, dynamic> message) {
    final readAt = message['readAt'];
    final deliveredAt = message['deliveredAt'];

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

  Future<void> _pickAndSendImage() async {
    try {
      setState(() => _isSendingImage = true);

      // Use MediaPickerService to pick, compress, and upload image
      final imagePath = await MediaPickerService.pickImageFromGallery();

      if (imagePath != null) {
        // Send message with image
        await _sendMessageWithContent('image', {'imageUrl': imagePath});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image sent successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      setState(() => _isSendingImage = false);
    } catch (e) {
      setState(() => _isSendingImage = false);
      if (mounted) {
        _showMediaErrorDialog(
          title: 'Image Upload Failed',
          message: e.toString(),
          onRetry: _pickAndSendImage,
        );
      }
    }
  }

  Future<void> _takeAndSendPhoto() async {
    try {
      setState(() => _isSendingImage = true);

      // Use MediaPickerService to capture, compress, and upload image
      final imagePath = await MediaPickerService.captureImageFromCamera();

      if (imagePath != null) {
        // Send message with image
        await _sendMessageWithContent('image', {'imageUrl': imagePath});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo sent successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      setState(() => _isSendingImage = false);
    } catch (e) {
      setState(() => _isSendingImage = false);
      if (mounted) {
        _showMediaErrorDialog(
          title: 'Photo Capture Failed',
          message: e.toString(),
          onRetry: _takeAndSendPhoto,
        );
      }
    }
  }

  Future<void> _sendLocation() async {
    try {
      setState(() => _isSendingLocation = true);

      // Use LocationService to get current location (handles permissions internally)
      final position = await LocationService.getCurrentLocation();

      // Get address from coordinates using LocationService
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Send message with location
      await _sendMessageWithContent('location', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
      });

      setState(() => _isSendingLocation = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location shared successfully'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSendingLocation = false);
      if (mounted) {
        _showLocationErrorDialog(
          message: e.toString(),
          onRetry: _sendLocation,
        );
      }
    }
  }

  Future<void> _sendMessageWithContent(
      String messageType, Map<String, dynamic> content) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('$_baseUrl/api/chat/${widget.conversationId}/messages'),
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
          await _loadMessages();
        }
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _showAttachmentOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF1565C0)),
              title: Text('Camera',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87)),
              subtitle: Text('Take a photo',
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600)),
              onTap: () {
                Navigator.pop(context);
                _takeAndSendPhoto();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFF1565C0)),
              title: Text('Gallery',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87)),
              subtitle: Text('Choose from gallery',
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600)),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF1565C0)),
              title: Text('Location',
                  style:
                      TextStyle(color: isDark ? Colors.white : Colors.black87)),
              subtitle: Text('Share your location',
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600)),
              onTap: () {
                Navigator.pop(context);
                _sendLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    print('_startRecording called, _isRecording: $_isRecording');

    if (_isRecording) {
      print('Already recording, ignoring start request');
      return;
    }

    try {
      print('Starting voice recording...');
      final started = await VoiceRecordingService.startRecording();
      print('VoiceRecordingService.startRecording returned: $started');

      if (started) {
        setState(() {
          _isRecording = true;
          _recordingElapsedSeconds = 0;
        });
        print('Recording state updated, starting timer');

        // Start timer to update elapsed time
        _startRecordingTimer();
      }
    } catch (e) {
      print('Error starting recording: $e');
      if (mounted) {
        _showVoiceNoteErrorDialog(
          message: e.toString(),
          onRetry: _startRecording,
        );
      }
    }
  }

  void _startRecordingTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording && mounted) {
        setState(() {
          _recordingElapsedSeconds =
              VoiceRecordingService.getRecordingElapsedTime();
        });

        // Auto-stop recording if max duration (2 minutes) is reached
        if (VoiceRecordingService.hasExceededMaxDuration()) {
          _stopRecording();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum recording duration (2 minutes) reached'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          _startRecordingTimer();
        }
      }
    });
  }

  Future<void> _stopRecording() async {
    print('_stopRecording called, _isRecording: $_isRecording');

    if (!_isRecording) {
      print('Not recording, ignoring stop request');
      return;
    }

    try {
      print('Stopping voice recording...');
      final path = await VoiceRecordingService.stopRecording();
      print('VoiceRecordingService.stopRecording returned path: $path');

      setState(() {
        _isRecording = false;
        _recordingElapsedSeconds = 0;
      });

      print('Recording stopped and state updated');
      return; // Just stop, don't send
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
        _recordingElapsedSeconds = 0;
      });
    }
  }

  Future<void> _stopAndSendRecording() async {
    print('_stopAndSendRecording called, _isRecording: $_isRecording');

    if (!_isRecording) {
      print('Not recording, ignoring stop and send request');
      return;
    }

    try {
      print('Stopping and sending voice recording...');
      setState(() {
        _isSendingVoice = true;
      });

      final path = await VoiceRecordingService.stopRecording();
      print('VoiceRecordingService.stopRecording returned path: $path');

      setState(() {
        _isRecording = false;
        _recordingElapsedSeconds = 0;
      });

      if (path != null && path.isNotEmpty) {
        print('Uploading voice note...');
        // Upload voice note - backend creates the message automatically
        await VoiceRecordingService.uploadVoiceNote(
            path, widget.conversationId);
        print('Voice note uploaded successfully');

        // Reload messages to show the new voice message
        // Small delay to ensure backend has processed the message
        await Future.delayed(const Duration(milliseconds: 500));
        await _loadMessages();

        // Delete temp file
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          print('Error deleting temp file: $e');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voice note sent successfully'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('No recording path returned');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save recording'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      setState(() {
        _isSendingVoice = false;
      });
      print('Recording sent and state updated');
    } catch (e) {
      print('Error stopping and sending recording: $e');
      setState(() {
        _isRecording = false;
        _isSendingVoice = false;
        _recordingElapsedSeconds = 0;
      });
      if (mounted) {
        _showVoiceNoteErrorDialog(
          message: e.toString(),
          onRetry: () async {
            // Retry by starting a new recording
            await _startRecording();
          },
        );
      }
    }
  }

  Future<void> _cancelRecording() async {
    print('_cancelRecording called, _isRecording: $_isRecording');

    if (!_isRecording) {
      print('Not recording, ignoring cancel request');
      return;
    }

    try {
      print('Cancelling voice recording...');
      await VoiceRecordingService.cancelRecording();
      setState(() {
        _isRecording = false;
        _recordingElapsedSeconds = 0;
      });
      print('Recording cancelled and state updated');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording cancelled'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error cancelling recording: $e');
      setState(() {
        _isRecording = false;
        _recordingElapsedSeconds = 0;
      });
    }
  }

  Future<void> _playVoiceMessage(String voiceUrl, String messageId) async {
    try {
      if (_playingVoiceId == messageId) {
        // Pause/stop playing
        await _audioPlayer.stop();
        setState(() {
          _playingVoiceId = null;
          _playbackPosition = null;
          _playbackDuration = null;
        });
      } else {
        // Start playing
        await _audioPlayer.stop();
        setState(() {
          _playingVoiceId = messageId;
          _playbackPosition = Duration.zero;
          _playbackDuration = null;
        });

        await _audioPlayer
            .play(UrlSource('${ApiConfig.baseUrlWithoutApi}$voiceUrl'));
      }
    } catch (e) {
      setState(() {
        _playingVoiceId = null;
        _playbackPosition = null;
        _playbackDuration = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play voice message: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatRecordingTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildClosedChatBanner() {
    final reason = _chatClosedReason == 'completed'
        ? 'This conversation has been closed because the booking was completed.'
        : 'This conversation has been closed because the booking was cancelled.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(
            color: Colors.orange.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat Closed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessageBubble(Map<String, dynamic> message, bool isMe) {
    final voiceUrl = message['content']?['voiceUrl'];
    final messageId = message['_id'] ?? message['id'];
    final isPlaying = _playingVoiceId == messageId;
    final duration = message['content']?['duration'] ?? 0;

    // Calculate progress
    double progress = 0.0;
    String timeText = '${duration}s';

    if (isPlaying && _playbackPosition != null && _playbackDuration != null) {
      progress =
          _playbackPosition!.inMilliseconds / _playbackDuration!.inMilliseconds;
      final remainingSeconds =
          (_playbackDuration!.inSeconds - _playbackPosition!.inSeconds);
      timeText = '${remainingSeconds}s';
    }

    return GestureDetector(
      onTap: () {
        if (voiceUrl != null && messageId != null) {
          _playVoiceMessage(voiceUrl, messageId);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFBBDEFB) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 32,
              color: const Color(0xFF1565C0),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                Container(
                  width: 120,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Time display
                Row(
                  children: [
                    Icon(Icons.graphic_eq,
                        size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 4),
                    Text(
                      timeText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final hasText = _messageController.text.trim().isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    _isChatActive ? Colors.grey.shade50 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
                    onPressed: _isChatActive ? _showAttachmentOptions : null,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: _isChatActive,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: _isChatActive ? 'Message' : 'Chat is closed',
                        hintStyle: TextStyle(
                            color:
                                isDark ? Colors.white54 : Colors.grey.shade600),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (text) {
                        setState(() {}); // Rebuild to show/hide send button
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_isSendingImage || _isSendingLocation || _isSendingVoice)
            const CircleAvatar(
              backgroundColor: Color(0xFF1565C0),
              radius: 24,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_isRecording)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fiber_manual_record,
                          color: Colors.red, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        'Recording ${_formatRecordingTime(_recordingElapsedSeconds)}',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.green,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _stopAndSendRecording,
                    tooltip: 'Send Voice Note',
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 22,
                  child: IconButton(
                    icon:
                        const Icon(Icons.delete, color: Colors.white, size: 18),
                    onPressed: _cancelRecording,
                    tooltip: 'Cancel Recording',
                  ),
                ),
              ],
            )
          else
            CircleAvatar(
              backgroundColor: _isChatActive
                  ? const Color(0xFF1565C0)
                  : Colors.grey.shade400,
              radius: 24,
              child: hasText
                  ? IconButton(
                      icon:
                          const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: _isChatActive ? _sendMessage : null,
                    )
                  : IconButton(
                      icon:
                          const Icon(Icons.mic, color: Colors.white, size: 20),
                      onPressed: _isChatActive ? _startRecording : null,
                      tooltip: 'Tap to record voice note',
                    ),
            ),
        ],
      ),
    );
  }

  /// Show error dialog for media upload failures with retry option
  void _showMediaErrorDialog({
    required String title,
    required String message,
    required VoidCallback onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Show error dialog for voice note failures with retry option
  void _showVoiceNoteErrorDialog({
    required String message,
    required VoidCallback onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Voice Note Failed')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 12),
            if (message.contains('permission'))
              const Text(
                'To fix this:\n1. Go to Settings > Apps > AssureFix\n2. Tap Permissions\n3. Enable Microphone access',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (message.contains('permission'))
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Open app settings
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Show error dialog for location service failures with retry option
  void _showLocationErrorDialog({
    required String message,
    required VoidCallback onRetry,
  }) {
    // Check if message indicates permission issue
    final bool isPermissionIssue = message.contains('permission') ||
        message.contains('denied') ||
        message.contains('disabled');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Location Failed')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (isPermissionIssue) ...[
              const SizedBox(height: 16),
              const Text(
                'To enable location access:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1. Open your device Settings'),
              const Text('2. Go to Apps or Applications'),
              const Text('3. Find this app'),
              const Text('4. Tap Permissions'),
              const Text('5. Enable Location access'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (isPermissionIssue)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Show error dialog for voice call failures with retry option
  void _showCallErrorDialog({
    required String message,
    required VoidCallback onRetry,
  }) {
    // Check if message indicates network or availability issue
    final bool isNetworkIssue = message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout');
    final bool isUnavailable = message.contains('unavailable') ||
        message.contains('busy') ||
        message.contains('offline');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.call_end, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Call Failed')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (isNetworkIssue) ...[
              const SizedBox(height: 16),
              const Text(
                'Please check your internet connection and try again.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ] else if (isUnavailable) ...[
              const SizedBox(height: 16),
              const Text(
                'The user may be offline or unavailable. Please try again later.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Show error dialog for network failures with retry option
  void _showNetworkErrorDialog({
    required String message,
    String? pendingMessage,
    required VoidCallback onRetry,
  }) {
    // Check if message indicates network issue
    final bool isNetworkIssue = message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('SocketException');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('Network Error')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNetworkIssue
                  ? 'Unable to connect to the server. Please check your internet connection.'
                  : message.replaceAll('Exception: ', ''),
            ),
            if (pendingMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pending message:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pendingMessage,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your message will be sent when connection is restored.',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onRetry();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _startMessagePolling() {
    // Poll for new messages every 3 seconds (optimized for smooth updates)
    _messagePollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isLoading && !_isLoadingMore) {
        _checkForNewMessages();
      }
    });
  }

  Future<void> _checkForNewMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || _messages.isEmpty) return;

      // Get the latest message ID to check for new messages
      final latestMessage = _messages.last;
      final lastMessageId = latestMessage['_id']?.toString();

      if (lastMessageId == null) return;

      // Load latest messages and check for new ones
      // Use a simple approach: load page 1 and compare with existing messages
      final uri =
          Uri.parse('$_baseUrl/api/chat/${widget.conversationId}').replace(
        queryParameters: {
          'page': '1',
          'limit': '50',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        final newMessages =
            List<Map<String, dynamic>>.from(data['messages'] ?? []);

        if (newMessages.isNotEmpty) {
          // Filter out messages we already have
          final existingIds =
              _messages.map((m) => m['_id']?.toString()).toSet();
          final trulyNewMessages = newMessages
              .where((m) => !existingIds.contains(m['_id']?.toString()))
              .toList();

          if (trulyNewMessages.isNotEmpty && mounted) {
            // Add new messages without causing full rebuild
            _messages.addAll(trulyNewMessages);

            // Notify parent about new messages
            if (widget.onNewMessage != null) {
              widget.onNewMessage!();
            }

            // Only call setState if we need to update the UI
            if (mounted) {
              setState(() {
                // Just trigger a minimal rebuild
              });
            }

            // Auto-scroll to bottom if user is near bottom
            // With reverse: true, position 0 is at bottom
            if (_scrollController.hasClients) {
              final currentScroll = _scrollController.position.pixels;
              // If within 200px of bottom (position 0), auto-scroll
              if (currentScroll < 200) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            }

            // Mark new messages as read silently (without reloading)
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null) {
              // Just call the API, don't reload messages
              http.patch(
                Uri.parse('$_baseUrl/api/chat/${widget.conversationId}/read'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );
            }
          }
        }
      }
    } catch (e) {
      // Silently fail - don't spam errors in production
      // Only log in debug mode
      if (kDebugMode) {
        debugPrint('Error checking for new messages: $e');
      }
    }
  }

  @override
  void dispose() {
    _messagePollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Full-screen image viewer with zoom and pan capabilities
class _FullScreenImageView extends StatefulWidget {
  final String imageUrl;

  const _FullScreenImageView({
    required this.imageUrl,
  });

  @override
  State<_FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<_FullScreenImageView> {
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      // Reset zoom
      _transformationController.value = Matrix4.identity();
    } else {
      // Zoom in to 2x at tap position
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download',
            onPressed: () {
              // Future enhancement: implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download feature coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onDoubleTapDown: _handleDoubleTapDown,
        onDoubleTap: _handleDoubleTap,
        child: Center(
          child: InteractiveViewer(
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 4.0,
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading image...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load image',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}
