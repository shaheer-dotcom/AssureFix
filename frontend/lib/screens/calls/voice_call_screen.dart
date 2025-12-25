import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:async';

class VoiceCallScreen extends StatefulWidget {
  final String callId;
  final String receiverId;
  final String receiverName;
  final String? receiverProfilePicture;
  final bool isIncoming;
  final String channelName;
  final String token;
  final int uid;

  const VoiceCallScreen({
    super.key,
    required this.callId,
    required this.receiverId,
    required this.receiverName,
    this.receiverProfilePicture,
    required this.isIncoming,
    required this.channelName,
    required this.token,
    required this.uid,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  RtcEngine? _engine;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  Duration _callDuration = Duration.zero;
  Timer? _timer;
  Timer? _connectionTimer;
  CallStatus _status = CallStatus.connecting;
  static const int _connectionTimeoutSeconds = 30;

  @override
  void initState() {
    super.initState();
    _initializeAgora();
    _startConnectionTimeout();
  }

  Future<void> _initializeAgora() async {
    try {
      // Create Agora engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: 'YOUR_AGORA_APP_ID', // This should come from config
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _connectionTimer?.cancel();
            setState(() {
              _status = CallStatus.connected;
            });
            _startTimer();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            _connectionTimer?.cancel();
            setState(() {
              _status = CallStatus.connected;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            String message = 'Call ended';
            if (reason == UserOfflineReasonType.userOfflineDropped) {
              message = 'Connection lost';
            } else if (reason == UserOfflineReasonType.userOfflineQuit) {
              message = 'User left the call';
            }
            _endCallWithMessage(message);
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            // Channel left successfully
          },
          onConnectionLost: (RtcConnection connection) {
            _showErrorAndExit('Connection lost. Please check your internet connection.');
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint('Agora error: $err - $msg');
            if (err == ErrorCodeType.errConnectionInterrupted) {
              _showErrorAndExit('Connection interrupted. Please try again.');
            } else if (err == ErrorCodeType.errConnectionLost) {
              _showErrorAndExit('Connection lost. Please check your internet connection.');
            } else {
              _showErrorAndExit('Call failed. Please try again.');
            }
          },
        ),
      );

      // Enable audio
      await _engine!.enableAudio();
      
      // Join channel
      await _engine!.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: widget.uid,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing Agora: $e');
      String errorMessage = 'Failed to connect call';
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Microphone permission denied. Please enable microphone access.';
      }
      _showErrorAndExit(errorMessage);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
      });
    });
  }

  void _startConnectionTimeout() {
    _connectionTimer = Timer(const Duration(seconds: _connectionTimeoutSeconds), () {
      if (_status == CallStatus.connecting && mounted) {
        _showErrorAndExit('Connection timeout. The user may be unavailable or offline.');
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _engine?.muteLocalAudioStream(_isMuted);
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
    _engine?.setEnableSpeakerphone(_isSpeakerOn);
  }

  Future<void> _endCall() async {
    _timer?.cancel();
    _connectionTimer?.cancel();
    
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (e) {
      debugPrint('Error ending call: $e');
    }

    if (mounted) {
      Navigator.of(context).pop({
        'duration': _callDuration.inSeconds,
        'status': 'ended',
      });
    }
  }

  Future<void> _endCallWithMessage(String message) async {
    _timer?.cancel();
    _connectionTimer?.cancel();
    
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (e) {
      debugPrint('Error ending call: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop({
        'duration': _callDuration.inSeconds,
        'status': 'ended',
        'message': message,
      });
    }
  }

  void _showErrorAndExit(String message) {
    _timer?.cancel();
    _connectionTimer?.cancel();
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Expanded(child: Text('Call Failed')),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop({ // Return to chat screen
                  'status': 'failed',
                  'error': message,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String _getStatusText() {
    switch (_status) {
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.connected:
        return _formatDuration(_callDuration);
      case CallStatus.ended:
        return 'Call Ended';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectionTimer?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _endCall,
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Profile picture and name
            Column(
              children: [
                // Profile picture
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[800],
                  ),
                  child: widget.receiverProfilePicture != null
                      ? ClipOval(
                          child: Image.network(
                            widget.receiverProfilePicture!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildInitialsAvatar();
                            },
                          ),
                        )
                      : _buildInitialsAvatar(),
                ),
                
                const SizedBox(height: 24),
                
                // Receiver name
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Call status/duration
                Text(
                  _getStatusText(),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                
                // Connection indicator
                if (_status == CallStatus.connecting)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey[400]!,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            const Spacer(),
            
            // Call controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    onPressed: _toggleMute,
                    backgroundColor: _isMuted ? Colors.white : Colors.grey[800]!,
                    iconColor: _isMuted ? Colors.black : Colors.white,
                  ),
                  
                  // End call button
                  _buildControlButton(
                    icon: Icons.call_end,
                    label: 'End',
                    onPressed: _endCall,
                    backgroundColor: Colors.red,
                    iconColor: Colors.white,
                    size: 64,
                  ),
                  
                  // Speaker button
                  _buildControlButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    label: _isSpeakerOn ? 'Speaker' : 'Earpiece',
                    onPressed: _toggleSpeaker,
                    backgroundColor: _isSpeakerOn ? Colors.white : Colors.grey[800]!,
                    iconColor: _isSpeakerOn ? Colors.black : Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    String initials = widget.receiverName.isNotEmpty
        ? widget.receiverName.substring(0, 1).toUpperCase()
        : '?';
    
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
    double size = 56,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: iconColor,
                size: size * 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

enum CallStatus {
  connecting,
  connected,
  ended,
}
