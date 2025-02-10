import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController {
  var scanResults = <ScanResult>[].obs;
  var isConnected = false.obs; // Track connection status
  BluetoothDevice? connectedDevice; // Store the connected device
  BluetoothCharacteristic?
      characteristic; // Store the characteristic for data transmission

  Stream<List<ScanResult>> get scanResult => FlutterBluePlus.scanResults;

  @override
  void onInit() {
    super.onInit();
    // Listen for scan results
    FlutterBluePlus.scanResults.listen((results) {
      scanResults.value = results;
    });
  }

  Future<void> scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.locationWhenInUse.request().isGranted) {
      FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
      );
    } else {
      debugPrint("Permissions not granted. Please enable them in settings.");
      openAppSettings(); // Opens device settings for manual permission grant
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      
      // Stop scanning before connecting
      await FlutterBluePlus.stopScan();

      // Connect to the device
      await device.connect(autoConnect: true, mtu: null);
      isConnected.value = true;
      connectedDevice = device;
      

      // Discover services and characteristics
      List<BluetoothService> services = await device.discoverServices();

      // Find the characteristic for data transmission
      for (var service in services) {
        for (var char in service.characteristics) {
          if (char.properties.write) {
            characteristic = char;
            break;
          }
        }
      }

      if (characteristic == null) {
        debugPrint("No writable characteristic found.");
        Get.snackbar(
          "Error",
          "No writable characteristic found.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      Get.snackbar(
        "Connected",
        "Successfully connected to ${device.platformName}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Failed to connect: $e");
      Get.snackbar(
        "Error",
        "Failed to connect to ${device.platformName}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> sendTextToDevice(String text) async {
    if (connectedDevice == null || characteristic == null) {
      debugPrint("No device connected or characteristic not found.");
      Get.snackbar(
        "Error",
        "No device connected or characteristic not found.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Convert the text to bytes
      List<int> bytes = text.codeUnits;

      // Write the data to the characteristic
      await characteristic!.write(bytes);
      debugPrint("Data sent: $text");

      Get.snackbar(
        "Success",
        "Data sent to ${connectedDevice!.platformName}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint("Failed to send data: $e");
      Get.snackbar(
        "Error",
        "Failed to send data to ${connectedDevice!.platformName}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> disconnectDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      isConnected.value = false;
      connectedDevice = null;
      characteristic = null;

      Get.snackbar(
        "Disconnected",
        "Device disconnected",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }
}
