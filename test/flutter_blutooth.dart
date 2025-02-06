import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.lightBlue,
      home: BluetoothPermissionScreen(),
    );
  }
}

class BluetoothPermissionScreen extends StatefulWidget {
  @override
  _BluetoothPermissionScreenState createState() =>
      _BluetoothPermissionScreenState();
}

class _BluetoothPermissionScreenState extends State<BluetoothPermissionScreen> {
  bool _isBluetoothGranted = false;

  @override
  void initState() {
    super.initState();
    _requestBluetoothPermissions();
  }

  Future<void> _requestBluetoothPermissions() async {
    var status = await Permission.bluetooth.request();
    if (status.isGranted) {
      setState(() {
        _isBluetoothGranted = true;
      });
    } else {
      // Handle the case when permission is denied
      print("Bluetooth permission denied");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Permission'),
      ),
      body: Center(
        child: _isBluetoothGranted
            ? ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScanScreen()),
                  );
                },
                child: Text('Scan for Devices'),
              )
            : Text('Please grant Bluetooth permissions to continue.'),
      ),
    );
  }
}

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
    });

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _devices = results.map((result) => result.device).toList();
      });
    });

    FlutterBluePlus.startScan();
  }

  void _stopScan() {
    FlutterBluePlus.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan for Devices'),
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_devices[index].name),
            subtitle: Text(_devices[index].id.toString()),
            onTap: () {
              _stopScan();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceScreen(device: _devices[index]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isScanning ? _stopScan : _startScan,
        child: Icon(_isScanning ? Icons.stop : Icons.search),
      ),
    );
  }
}

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device;

  DeviceScreen({required this.device});

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _isConnected = false;
  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  void _connectToDevice() async {
    await widget.device.connect();
    setState(() {
      _isConnected = true;
    });

    _connectionStateSubscription =
        widget.device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.disconnected) {
        setState(() {
          _isConnected = false;
        });
      }
    });
  }

  void _sendCommand() async {
    if (_isConnected) {
      // Replace with your service UUID and characteristic UUID
      var serviceId = Guid("your-service-uuid");
      var characteristicId = Guid("your-characteristic-uuid");

      var characteristics = await widget.device.discoverServices();
      var characteristic = characteristics
          .expand((service) => service.characteristics)
          .firstWhere((c) => c.uuid == characteristicId);

      await characteristic.write([0x01]); // Replace with your command
    }
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
      ),
      body: Center(
        child: _isConnected
            ? ElevatedButton(
                onPressed: _sendCommand,
                child: Text('Send Command'),
              )
            : Text('Connecting...'),
      ),
    );
  }
}
