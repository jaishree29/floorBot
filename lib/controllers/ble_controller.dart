import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController {
  var scanResults = <ScanResult>[].obs;

  Stream<List<ScanResult>> get scanResult => FlutterBluePlus.scanResults;

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
}
