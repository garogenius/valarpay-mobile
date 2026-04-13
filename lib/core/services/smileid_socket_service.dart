import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:valarpay/core/services/session_service.dart';

class SmileIdSocketService {
  static final SmileIdSocketService _instance = SmileIdSocketService._internal();
  factory SmileIdSocketService() => _instance;
  SmileIdSocketService._internal();

  IO.Socket? _socket;
  bool isConnected = false;

  final _basicKycController = StreamController<Map<String, dynamic>>.broadcast();
  final _biometricKycController = StreamController<Map<String, dynamic>>.broadcast();
  final _smartSelfieController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get basicKycStream => _basicKycController.stream;
  Stream<Map<String, dynamic>> get biometricKycStream => _biometricKycController.stream;
  Stream<Map<String, dynamic>> get smartSelfieStream => _smartSelfieController.stream;

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await SessionService.getAccessToken();
    if (token == null) return;

    _socket = IO.io(
      'https://valarpay.nattycore.com',
      IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setQuery({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      isConnected = true;
      // print('SmileID WebSocket Connected');
    });

    _socket!.onDisconnect((_) {
      isConnected = false;
      // print('SmileID WebSocket Disconnected');
    });

    _socket!.on('connection:success', (data) {
      // print('SmileID connection:success => $data');
    });

    _socket!.on('connection:error', (data) {
      // print('SmileID connection:error => $data');
    });

    _socket!.on('basic:kyc:result', (data) {
      _basicKycController.add(data);
    });

    _socket!.on('biometric:kyc:result', (data) {
      _biometricKycController.add(data);
    });

    _socket!.on('liveness:result', (data) {
      _smartSelfieController.add(data);
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected = false;
  }
}
