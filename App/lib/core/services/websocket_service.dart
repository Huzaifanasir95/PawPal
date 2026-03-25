import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../config/app_config.dart';
import 'api_client.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  bool _isConnecting = false;
  String? _currentChatId;

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _channel != null;

  Future<void> connect(String chatId) async {
    if (_isConnecting || (_channel != null && _currentChatId == chatId)) {
      return;
    }

    _isConnecting = true;
    _currentChatId = chatId;

    try {
      // Get auth token
      final token = ApiClient.instance.accessToken;
      if (token == null) {
        print('❌ No auth token available for WebSocket');
        _isConnecting = false;
        return;
      }

      // Build WebSocket URL - convert HTTP to WS
      final baseUrl = AppConfig.backendBaseUrl;
      final wsProtocol = baseUrl.startsWith('https') ? 'wss' : 'ws';
      
      // Extract host without protocol
      final hostWithPort = baseUrl
          .replaceFirst('http://', '')
          .replaceFirst('https://', '');
      
      final uri = Uri.parse('$wsProtocol://$hostWithPort/api/v1/ws/chat/$chatId?token=$token');
      
      print('🔌 Connecting to WebSocket: $uri');
      
      _channel = WebSocketChannel.connect(uri);
      
      await _channel!.ready;
      
      print('✅ WebSocket connected');
      _connectionController.add(true);
      _isConnecting = false;

      // Start heartbeat
      _startHeartbeat();

      // Listen to messages
      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data as String) as Map<String, dynamic>;
            print('📨 WebSocket message received: ${message['type']}');
            _messageController.add(message);
          } catch (e) {
            print('❌ Error parsing WebSocket message: $e');
          }
        },
        onError: (error) {
          print('❌ WebSocket error: $error');
          _handleDisconnect();
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _handleDisconnect();
        },
      );
    } catch (e) {
      print('❌ Failed to connect WebSocket: $e');
      _isConnecting = false;
      _handleDisconnect();
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          print('❌ Heartbeat failed: $e');
          _handleDisconnect();
        }
      }
    });
  }

  void _handleDisconnect() {
    _connectionController.add(false);
    _channel = null;
    _heartbeatTimer?.cancel();
    
    // Auto-reconnect after 5 seconds
    if (_currentChatId != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        if (_currentChatId != null) {
          print('🔄 Attempting to reconnect WebSocket...');
          connect(_currentChatId!);
        }
      });
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
        print('📤 Sent WebSocket message: ${message['type']}');
      } catch (e) {
        print('❌ Failed to send WebSocket message: $e');
      }
    } else {
      print('❌ Cannot send message: WebSocket not connected');
    }
  }

  void markMessageAsRead(String messageId) {
    sendMessage({
      'type': 'mark_read',
      'messageId': messageId,
    });
  }

  void sendTypingIndicator(bool isTyping) {
    sendMessage({
      'type': 'typing',
      'isTyping': isTyping,
    });
  }

  void disconnect() {
    print('🔌 Disconnecting WebSocket');
    _currentChatId = null;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close(status.normalClosure);
    _channel = null;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
