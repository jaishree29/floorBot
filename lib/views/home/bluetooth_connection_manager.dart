import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothConnectionManager {
  static final BluetoothConnectionManager _instance =
      BluetoothConnectionManager._internal();
  factory BluetoothConnectionManager() => _instance;

  BluetoothDevice? _connectedDevice;

  BluetoothConnectionManager._internal();

  BluetoothDevice? get connectedDevice => _connectedDevice;

  void connectDevice(BluetoothDevice device) {
    _connectedDevice = device;
  }

  void disconnectDevice() {
    _connectedDevice = null;
  }
}

class BluetoothScanPage extends StatefulWidget {
  const BluetoothScanPage({super.key});

  @override
  State<BluetoothScanPage> createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  List<BluetoothDevice> scanResults = [];

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    scanResults.clear();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results.map((r) => r.device).toList();
      });
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      BluetoothConnectionManager().connectDevice(device);
      setState(() {}); // Refresh UI to show only the connected device
    } catch (e) {
      print("Connection error: $e");
    }
  }

  void _disconnectDevice() async {
    try {
      BluetoothDevice? device = BluetoothConnectionManager().connectedDevice;
      if (device != null) {
        await device.disconnect();
        BluetoothConnectionManager().disconnectDevice();
        setState(() {}); // Refresh UI to show available devices again
      }
    } catch (e) {
      print("Disconnection error: $e");
    }
  }

  Widget _buildDeviceList() {
    final connectionManager = BluetoothConnectionManager();

    if (connectionManager.connectedDevice != null) {
      BluetoothDevice device = connectionManager.connectedDevice!;
      return ListTile(
        title: Text(device.name),
        subtitle: Text(device.id.toString()),
        trailing: ElevatedButton(
          onPressed: _disconnectDevice,
          child: const Text("Disconnect"),
        ),
      );
    }

    return Column(
      children: scanResults.map((device) {
        return ListTile(
          title: Text(device.name),
          subtitle: Text(device.id.toString()),
          trailing: ElevatedButton(
            onPressed: () => _connectToDevice(device),
            child: const Text("Connect"),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Devices')),
      body: _buildDeviceList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _startScan,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
