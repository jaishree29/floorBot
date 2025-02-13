import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainScreen());
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _flutterBlueClassicPlugin = FlutterBlueClassic();

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription? _adapterStateSubscription;

  final Set<BluetoothDevice> _scanResults = {};
  StreamSubscription? _scanSubscription;

  bool _isScanning = false;
  int? _connectingToIndex;
  StreamSubscription? _scanningStateSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> checkBluetoothState() async {
    BluetoothAdapterState adapterState =
        await _flutterBlueClassicPlugin.adapterStateNow;

    if (adapterState != BluetoothAdapterState.on) {
      _flutterBlueClassicPlugin.turnOn();
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Wait for Bluetooth to turn on
    }
  }

  Future<void> requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.bluetooth.request().isGranted &&
        await Permission.locationWhenInUse.request().isGranted) {
      // Permissions granted, proceed with Bluetooth operations
    } else {
      // Handle permission denial
      if (kDebugMode) print("Bluetooth permissions not granted");
    }
  }

  Future<void> initPlatformState() async {
    await requestPermissions();
    await checkBluetoothState();
    BluetoothAdapterState adapterState = _adapterState;

    try {
      adapterState = await _flutterBlueClassicPlugin.adapterStateNow;
      _adapterStateSubscription =
          _flutterBlueClassicPlugin.adapterState.listen((current) {
        if (mounted) setState(() => _adapterState = current);
      });
      _scanSubscription =
          _flutterBlueClassicPlugin.scanResults.listen((device) {
        if (mounted) setState(() => _scanResults.add(device));
      });
      _scanningStateSubscription =
          _flutterBlueClassicPlugin.isScanning.listen((isScanning) {
        if (mounted) setState(() => _isScanning = isScanning);
      });
    } catch (e) {
      if (kDebugMode) print(e);
    }

    if (!mounted) return;

    setState(() {
      _adapterState = adapterState;
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanningStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDevice> scanResults = _scanResults.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterBlueClassic example app'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Bluetooth Adapter state"),
            subtitle: const Text("Tap to enable"),
            trailing: Text(_adapterState.name),
            leading: const Icon(Icons.settings_bluetooth),
            onTap: () => _flutterBlueClassicPlugin.turnOn(),
          ),
          const Divider(),
          if (scanResults.isEmpty)
            const Center(child: Text("No devices found yet"))
          else
            for (var (index, result) in scanResults.indexed)
              ListTile(
                title: Text("${result.name ?? "???"} (${result.address})"),
                subtitle: Text(
                    "Bondstate: ${result.bondState.name}, Device type: ${result.type.name}"),
                trailing: index == _connectingToIndex
                    ? const CircularProgressIndicator()
                    : Text("${result.rssi} dBm"),
                onTap: () async {
                  BluetoothConnection? connection;
                  setState(() => _connectingToIndex = index);

                  try {
                    if (kDebugMode)
                      print("Attempting to connect to ${result.address}");

                    connection = await _flutterBlueClassicPlugin.connect(
                      result.address,
                    );

                    await connection!.input?.timeout(
                      const Duration(seconds: 10),
                    );

                    if (result.address.isEmpty) {
                      if (kDebugMode) print("Invalid Bluetooth address.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Invalid Bluetooth address.")),
                      );
                      return;
                    }
                    if (result.bondState != BluetoothBondState.bonded) {
                      if (kDebugMode)
                        print("Device is not bonded. Pair the device first.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Pair the device before connecting.")),
                      );
                      return;
                    }

                    if (!mounted) return;

                    if (connection.isConnected) {
                      setState(() => _connectingToIndex = null);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DeviceScreen(connection: connection!),
                        ),
                      );
                    } else {
                      if (kDebugMode) print("Connection failed.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Failed to connect to device.")),
                      );
                    }
                  } catch (e) {
                    setState(() => _connectingToIndex = null);
                    if (kDebugMode) print("Connection error: $e");

                    connection?.dispose(); // Properly dispose of connection

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Error connecting: ${e.toString()}")),
                    );
                  }
                },
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_isScanning) {
            _flutterBlueClassicPlugin.stopScan();
          } else {
            _scanResults.clear();
            _flutterBlueClassicPlugin.startScan();
          }
        },
        label: Text(_isScanning ? "Scanning..." : "Start device scan"),
        icon: Icon(_isScanning ? Icons.bluetooth_searching : Icons.bluetooth),
      ),
    );
  }
}

class DeviceScreen extends StatefulWidget {
  final BluetoothConnection connection;

  const DeviceScreen({super.key, required this.connection});

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _isConnected = false;
  StreamSubscription<Uint8List>? _subscription;

  @override
  void initState() {
    super.initState();
    _setupConnection();
    _waitForConnection();
  }

  Future<void> _waitForConnection() async {
    await Future.delayed(const Duration(seconds: 2));
    if (widget.connection.isConnected) {
      if (kDebugMode) print("Connection is stable, ready to send data.");
    } else {
      if (kDebugMode) print("Connection failed.");
    }
  }

  void _setupConnection() {
    if (widget.connection.isConnected) {
      setState(() => _isConnected = true);

      // Add a listener to handle incoming data
      _subscription = widget.connection.input?.listen((Uint8List data) {
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
    widget.connection.dispose();
  }

  Future<void> _sendData(String data) async {
    if (widget.connection.isConnected) {
      try {
        final Uint8List bytes = Uint8List.fromList(data.codeUnits);
        widget.connection.output.add(bytes);
        await widget.connection.output.allSent;
        if (kDebugMode) print("Data sent: $data");
      } catch (e) {
        if (kDebugMode) print("Error sending data: $e");
      }
    } else {
      if (kDebugMode) print("Device is not connected.");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    widget.connection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Device Screen")),
      body: Center(
        child: _isConnected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Connected to device"),
                  ElevatedButton(
                    onPressed: _handleDisconnect,
                    child: const Text("Disconnect"),
                  ),
                  ElevatedButton(
                    onPressed: () => _sendData("Hello"),
                    child: const Text("Send 'hello'"),
                  ),
                ],
              )
            : const Text("Disconnected"),
      ),
    );
  }
}
