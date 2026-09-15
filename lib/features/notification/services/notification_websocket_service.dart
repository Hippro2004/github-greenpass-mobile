import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/features/notification/models/notification_model.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class NotificationWebSocketService {
  NotificationWebSocketService._();
  static final NotificationWebSocketService instance =
      NotificationWebSocketService._();

  StompClient? _stompClient;
  String? _connectedUsername;

  final StreamController<NotificationModel> _notificationStreamController =
      StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get notificationStream =>
      _notificationStreamController.stream;

  bool get isConnected => _stompClient?.connected ?? false;

  void connect({
    required String username,
  }) {
    if (_stompClient != null &&
        _stompClient!.connected &&
        _connectedUsername == username) {
      return;
    }

    disconnect();

    _connectedUsername = username;

    try {
      final baseUri = Uri.parse(DioClient.dio.options.baseUrl);
      final wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
      final contextPath = baseUri.path.endsWith('/')
          ? baseUri.path.substring(0, baseUri.path.length - 1)
          : baseUri.path;
      final wsUrl =
          '$wsScheme://${baseUri.host}:${baseUri.port}$contextPath/ws-greenpass/websocket';

      print('>>> [WebSocket] Attempting to connect: $wsUrl');

      _stompClient = StompClient(
        config: StompConfig(
          url: wsUrl,
          reconnectDelay: const Duration(seconds: 4),
          connectionTimeout: const Duration(seconds: 8),
          heartbeatIncoming: const Duration(seconds: 10),
          heartbeatOutgoing: const Duration(seconds: 10),
          onConnect: _onConnect,
          onWebSocketError: (dynamic error) {
            print('>>> [WebSocket] Connection Error: $error');
          },
          onDisconnect: (StompFrame frame) {
            print('>>> [WebSocket] Disconnected');
          },
          onStompError: (StompFrame frame) {
            print('>>> [WebSocket] STOMP Error: ${frame.body}');
          },
        ),
      );

      _stompClient!.activate();
    } catch (e) {
      print('>>> [WebSocket] Failed to initialize: $e');
    }
  }

  void _onConnect(StompFrame frame) {
    if (_connectedUsername == null || _stompClient == null) return;

    final topic = '/topic/user/$_connectedUsername/notifications';
    print('>>> [WebSocket] CONNECTED SUCCESSFULLY! Subscribing to: $topic');

    _stompClient!.subscribe(
      destination: topic,
      callback: (StompFrame frame) {
        if (frame.body == null || frame.body!.isEmpty) return;

        try {
          debugPrint('>>> [WebSocket] Raw message body received: ${frame.body}');
          final dynamic decoded = json.decode(frame.body!);
          if (decoded is Map) {
            final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);
            final notification = NotificationModel.fromMap(data);
            debugPrint('>>> [WebSocket] Parsed Notification: ${notification.title}');
            _notificationStreamController.add(notification);
          }
        } catch (e, stack) {
          debugPrint('>>> [WebSocket] Error parsing notification: $e\n$stack');
        }
      },
    );
  }

  void disconnect() {
    try {
      _stompClient?.deactivate();
    } catch (_) {}
    _stompClient = null;
    _connectedUsername = null;
  }
}
