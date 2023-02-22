import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  online,
  offline,
  connecting,
}

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  ServerStatus get serverStatus => _serverStatus;

  late IO.Socket _socket;
  IO.Socket get socket => _socket;

  //*Constructor
  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    //!Dart client
    // http://192.168.1.8:3000
    _socket = IO.io('https://flutter-socket-server-m6t2.onrender.com', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.on('connect', (_) {
      _serverStatus = ServerStatus.online;
      notifyListeners();
    });

    _socket.on('disconnect', (_) {
      _serverStatus = ServerStatus.offline;
      notifyListeners();
    });

    // socket.on('nuevo-mensaje', (payload) {
    //   print('nuevo-mensaje: $payload');
    //   print('nombre: ${payload['nombre']}');
    // });
  }
}
