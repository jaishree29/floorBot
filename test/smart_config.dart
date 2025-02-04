// import 'dart:io';

// import 'package:esp_smartconfig/esp_smartconfig.dart';
// import 'package:loggerx/loggerx.dart';

// void main() async {
//   logging.level = LogLevel.debug;

//   final provisioner = Provisioner.espTouch();

//   provisioner.listen((response) {
//     log.info("\n"
//         "\n------------------------------------------------------------------------\n"
//         "Device ($response) is connected to WiFi!"
//         "\n------------------------------------------------------------------------\n");
//   });

//   try {
//     await provisioner.start(ProvisioningRequest.fromStrings(
//       ssid: "Renault 1.9D",
//       bssid: "f8:d1:11:bf:28:5c", // optional
//       password: "renault19",
//     ));

//     await Future.delayed(Duration(seconds: 10));
//   } catch (e, s) {
//     print('$e, $s');
//   }

//   provisioner.stop();
//   exit(0);
// }

// import 'dart:math';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:wifi_iot/wifi_iot.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:logger/logger.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ESP WiFi Communication',
//       home: WiFiESPPage(),
//     );
//   }
// }

// class WiFiESPPage extends StatefulWidget {
//   @override
//   _WiFiESPPageState createState() => _WiFiESPPageState();
// }

// class _WiFiESPPageState extends State<WiFiESPPage> {
//   final String ssid = "ESP32"; // Replace with ESP SSID
//   final String password = "12345678"; // Replace with ESP Password
//   final String espIP = "192.168.4.1"; // ESP IP Address in SoftAP Mode
//   final int port = 8080; // Port the ESP is listening on

//   IO.Socket? socket;
//   final Logger logger = Logger();

//   @override
//   void initState() {
//     super.initState();
//     connectToESP();
//   }

//   Future<void> connectToESP() async {
//     logger.i("Connecting to ESP WiFi...");

//     bool isConnected = await WiFiForIoTPlugin.connect(
//       ssid,
//       password: password,
//       joinOnce: true,
//       security: NetworkSecurity.WPA,
//     );

//     if (isConnected) {
//       logger.i("Connected to ESP WiFi ✅");
//       connectToESPServer();
//     } else {
//       logger.e("Failed to connect to ESP ❌");
//     }
//   }

//   void connectToESPServer() {
//     logger.i("Connecting to ESP Server at $espIP:$port...");

//     socket = IO.io(
//       'http://$espIP:$port',
//       IO.OptionBuilder()
//           .setTransports(['websocket']).setReconnectionAttempts(3)
//           .setTimeout(5000)
//           .build(),
//     );

//     socket!.onConnect((_) {
//       logger.i("Connected to ESP Server ✅");
//       sendRandomData();
//     });

//     socket!.onDisconnect((_) => logger.e("Disconnected from ESP ❌"));

//     socket!.onError((error) => logger.e("Error: $error"));
//   }

//   void sendRandomData() {
//     Random random = Random();
//     String randomData = jsonEncode({"value": random.nextInt(100)});

//     logger.i("Sending data: $randomData");
//     socket!.emit('data', randomData);
//   }

//   @override
//   void dispose() {
//     socket?.disconnect();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("ESP WiFi Communication")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: sendRandomData,
//           child: Text("Send Random Data"),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Logger logger = Logger();
  String? localIP;

  @override
  void initState() {
    super.initState();
    getIPAddress();
  }

  Future<void> getIPAddress() async {
    final info = NetworkInfo();
    String? ip = await info.getWifiIP();
    logger.i("Device IP Address: $ip");

    setState(() {
      localIP = ip;
    });
  }

  Future<void> sendCommand() async {
    final url = Uri.parse(
      'http://192.168.4.1/L',
    ); // Replace with your ESP32 server URL

    try {
      logger.i("Sending API request to: $url");

      // Make the API request
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      logger.i("Response status code: ${response.statusCode}");
      logger.i("Response body: ${response.body}");

      if (response.statusCode == 200) {
        logger.i("API call successful ✅");
        print("Response: ${response.body}");
      } else {
        logger.e("API call failed ❌. Status code: ${response.statusCode}");
        throw Exception(
            "Failed to call API. Status code: ${response.statusCode}");
      }
    } catch (e, s) {
      logger.e("Error during API call: $e");
      logger.e("Stack trace: $s");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Fetch Device IP")),
        body: Column(
          children: [
            Center(
              child: Text(
                localIP != null ? "IP Address: $localIP" : "Fetching IP...",
                style: TextStyle(fontSize: 20),
              ),
            ),
            ElevatedButton(
              onPressed: sendCommand,
              child: Text('Send command'),
            ),
          ],
        ),
      ),
    );
  }
}
