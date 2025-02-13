import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';

class NavigationControlPage extends StatefulWidget {
  final BluetoothConnection? connection;

  const NavigationControlPage({super.key, this.connection});

  @override
  State<NavigationControlPage> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<NavigationControlPage> {
  bool _isConnected = false;
  StreamSubscription<Uint8List>? _subscription;
  Timer? _timer;

  void _stopAction() {
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    _setupConnection();
    _waitForConnection();
  }

  Future<void> _waitForConnection() async {
    await Future.delayed(const Duration(seconds: 2));
    if (widget.connection!.isConnected) {
      if (kDebugMode) print("Connection is stable, ready to send data.");
    } else {
      if (kDebugMode) print("Connection failed.");
    }
  }

  void _setupConnection() {
    if (widget.connection!.isConnected) {
      setState(() => _isConnected = true);

      // Add a listener to handle incoming data
      _subscription = widget.connection!.input?.listen((Uint8List data) {
        String receivedData = String.fromCharCodes(data);
        if (kDebugMode) print("Received Data: $receivedData");
      }, onError: (error) {
        if (kDebugMode) print("Error receiving data: $error");
        _handleDisconnect();
      });
    } else {
      if (kDebugMode) print("Device not connected.");
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (mounted) {
      setState(() {
        _isConnected = false;
      });
    }
    widget.connection!.dispose();
  }

  Future<void> _sendData(String data) async {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) async {
      if (widget.connection!.isConnected) {
        try {
          final Uint8List bytes = Uint8List.fromList(data.codeUnits);
          widget.connection!.output.add(bytes);
          await widget.connection!.output.allSent;
          if (kDebugMode) print("Data sent: $data");
        } catch (e) {
          if (kDebugMode) print("Error sending data: $e");
        }
      } else {
        if (kDebugMode) print("Device is not connected.");
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.connection!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Control Page")),
      body: Center(
        child: _isConnected
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Connected to device"),
                    ElevatedButton(
                      onPressed: _handleDisconnect,
                      child: const Text("Disconnect"),
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onLongPressDown: (_) => _sendData('f'),
                          onLongPressUp: _stopAction,
                          onLongPressCancel: _stopAction,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            color: Colors.blue,
                            child: Text(
                              "Forward",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onLongPressDown: (_) => _sendData('l'),
                              onLongPressUp: _stopAction,
                              onLongPressCancel: _stopAction,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                color: Colors.blue,
                                child: Text(
                                  "Left",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onLongPressDown: (_) => _sendData('r'),
                              onLongPressUp: _stopAction,
                              onLongPressCancel: _stopAction,
                              child: Container(
                                padding: EdgeInsets.all(16),
                                color: Colors.blue,
                                child: Text(
                                  "Right",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onLongPressDown: (_) => _sendData('b'),
                          onLongPressUp: _stopAction,
                          onLongPressCancel: _stopAction,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            color: Colors.blue,
                            child: Text(
                              "Backward",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : const Text("Disconnected"),
      ),
    );
  }
}
