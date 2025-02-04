import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IotConnection extends StatefulWidget {
  const IotConnection({super.key});

  @override
  State<IotConnection> createState() => _IotConnectionState();
}

class _IotConnectionState extends State<IotConnection> {
  final String url = 'http://192.168.4.1/H';

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => _launchUrl(),
          child: Text('data'),
        ),
      ),
    );
  }
}
