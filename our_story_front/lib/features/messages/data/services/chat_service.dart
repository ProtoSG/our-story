import 'dart:async';
import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_constants.dart';
import '../models/message_model.dart';
import '../models/typing_notification.dart';

class ChatService {
  StompClient? _stompClient;
  bool _isConnected = false;
  bool _isDisposing = false;
  
  // Streams for real-time updates
  final _messageController = StreamController<MessageModel>.broadcast();
  final _typingController = StreamController<TypingNotification>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  
  Stream<MessageModel> get messageStream => _messageController.stream;
  Stream<TypingNotification> get typingStream => _typingController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  
  bool get isConnected => _isConnected;
  
  int? _currentCoupleId;
  String? _authToken;

  /// Initialize WebSocket connection
  Future<void> connect(int coupleId) async {
    if (_isConnected && _currentCoupleId == coupleId) {
      print('⚠️ Already connected to couple $coupleId');
      return; // Already connected to this couple
    }

    _currentCoupleId = coupleId;
    _authToken = await _getToken();

    if (_authToken == null) {
      print('❌ Authentication token not found');
      throw Exception('Authentication token not found');
    }

    final wsUrl = ApiConstants.baseUrl; // SockJS uses http/https, not ws/wss
    print('🔌 Connecting to WebSocket: $wsUrl/api/ws');
    print('👤 Couple ID: $coupleId');
    
    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '$wsUrl/api/ws',
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        stompConnectHeaders: {
          'Authorization': 'Bearer $_authToken',
        },
        webSocketConnectHeaders: {
          'Authorization': 'Bearer $_authToken',
        },
      ),
    );

    print('🚀 Activating STOMP client...');
    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    if (_isDisposing) return;
    
    _isConnected = true;
    if (!_connectionController.isClosed) {
      _connectionController.add(true);
    }
    print('✅ WebSocket connected');

    // Subscribe to messages for this couple
    _stompClient!.subscribe(
      destination: '/topic/couple/$_currentCoupleId',
      callback: (StompFrame frame) {
        if (_isDisposing || frame.body == null) return;
        try {
          final message = MessageModel.fromJson(json.decode(frame.body!));
          if (!_messageController.isClosed) {
            _messageController.add(message);
          }
        } catch (e) {
          print('❌ Error parsing message: $e');
        }
      },
    );

    // Subscribe to typing notifications
    _stompClient!.subscribe(
      destination: '/topic/couple/$_currentCoupleId/typing',
      callback: (StompFrame frame) {
        if (_isDisposing || frame.body == null) return;
        try {
          final notification = TypingNotification.fromJson(json.decode(frame.body!));
          if (!_typingController.isClosed) {
            _typingController.add(notification);
          }
        } catch (e) {
          // Error parsing typing notification
        }
      },
    );

    // Subscribe to read receipts
    _stompClient!.subscribe(
      destination: '/topic/couple/$_currentCoupleId/read',
      callback: (StompFrame frame) {
        if (_isDisposing || frame.body == null) return;
        try {
          final message = MessageModel.fromJson(json.decode(frame.body!));
          if (!_messageController.isClosed) {
            _messageController.add(message);
          }
        } catch (e) {
          // Error parsing read receipt
        }
      },
    );
  }

  void _onDisconnect(StompFrame frame) {
    _isConnected = false;
    if (!_isDisposing && !_connectionController.isClosed) {
      _connectionController.add(false);
    }
    print('❌ WebSocket disconnected');
  }

  void _onStompError(StompFrame frame) {
    if (!_isDisposing && !_connectionController.isClosed) {
      _connectionController.add(false);
    }
    print('❌ STOMP Error: ${frame.body}');
  }

  void _onWebSocketError(dynamic error) {
    if (!_isDisposing && !_connectionController.isClosed) {
      _connectionController.add(false);
    }
    print('❌ WebSocket Error: $error');
  }

  /// Send a message via WebSocket
  void sendMessage(MessageModel message) {
    if (!_isConnected || _stompClient == null) {
      throw Exception('WebSocket not connected');
    }

    _stompClient!.send(
      destination: '/app/chat.sendMessage',
      body: json.encode(message.toCreateRequest()),
    );
  }

  /// Send typing notification
  void sendTypingNotification(int userId, int coupleId, bool isTyping) {
    if (!_isConnected || _stompClient == null) {
      return;
    }

    final notification = TypingNotification(
      userId: userId,
      coupleId: coupleId,
      isTyping: isTyping,
    );

    _stompClient!.send(
      destination: '/app/chat.typing',
      body: json.encode(notification.toJson()),
    );
  }

  /// Mark message as read via WebSocket
  void markAsRead(int messageId) {
    if (!_isConnected || _stompClient == null) {
      return;
    }

    _stompClient!.send(
      destination: '/app/chat.markAsRead',
      body: messageId.toString(),
    );
  }

  /// Disconnect WebSocket
  void disconnect() {
    _stompClient?.deactivate();
    _isConnected = false;
    _currentCoupleId = null;
  }

  /// Dispose resources
  void dispose() {
    // Marcar que estamos en proceso de dispose
    _isDisposing = true;
    _isConnected = false;
    
    // Desconectar WebSocket
    _stompClient?.deactivate();
    _stompClient = null;
    _currentCoupleId = null;
    
    // Cerrar streams de manera segura
    if (!_messageController.isClosed) {
      _messageController.close();
    }
    if (!_typingController.isClosed) {
      _typingController.close();
    }
    if (!_connectionController.isClosed) {
      _connectionController.close();
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
