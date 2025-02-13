import 'dart:async';
import 'package:floorbot/utils/colors.dart';
import 'package:floorbot/views/home/app_drawer.dart';
import 'package:floorbot/views/navigation/navigation_control_page.dart';
import 'package:floorbot/views/notifications/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _flutterBlueClassicPlugin = FlutterBlueClassic();

  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  StreamSubscription? _adapterStateSubscription;

  final Set<BluetoothDevice> _scanResults = {};
  StreamSubscription? _scanSubscription;

  bool _isScanning = false;
  int? _connectingToIndex;
  StreamSubscription? _scanningStateSubscription;

  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool _isDrawerOpen = false;

  final YoutubePlayerController _yController = YoutubePlayerController(
    initialVideoId: 'Yf8MuJUGLlI',
    flags: YoutubePlayerFlags(
      loop: true,
      autoPlay: true,
      mute: false,
    ),
  );

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initBluetooth();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0.0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> _initBluetooth() async {
    await _requestPermissions();
    await _checkBluetoothState();

    try {
      _adapterState = await _flutterBlueClassicPlugin.adapterStateNow;
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
      print("Bluetooth initialization error: $e");
    }
  }

  Future<void> _checkBluetoothState() async {
    BluetoothAdapterState adapterState =
        await _flutterBlueClassicPlugin.adapterStateNow;

    if (adapterState != BluetoothAdapterState.on) {
      _flutterBlueClassicPlugin.turnOn();
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void _toggleDrawer() {
    if (_isDrawerOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  void dispose() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanningStateSubscription?.cancel();
    _controller.dispose();
    _yController.dispose();
    _adapterState;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final videoHeight = screenHeight * 0.25;
    List<BluetoothDevice> scanResults = _scanResults.toList();

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white24,
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        leading: InkWell(
          splashColor: Colors.transparent,
          onTap: _toggleDrawer,
          child: const Padding(
            padding: EdgeInsets.only(left: 12.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://img.freepik.com/free-vector/cute-cool-boy-dabbing-pose-cartoon-vector-icon-illustration-people-fashion-icon-concept-isolated_138676-5680.jpg?t=st=1733131305~exp=1733134905~hmac=a1b05ebdf1385da653bf6ec4e40b0bf395afbc7af28f13c8c9a70a47d7074292&w=740',
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'How are you today?',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: FColors.primary),
                ),
              ],
            ),
            InkWell(
              splashColor: FColors.primary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Notifications(),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: FColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 25,
                    color: FColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              children: [
                // YouTube Video Player
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: videoHeight,
                    width: double.infinity,
                    child: YoutubePlayer(
                      controller: _yController,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.amber,
                      progressColors: const ProgressBarColors(
                        playedColor: Colors.amber,
                        handleColor: Colors.amberAccent,
                      ),
                      onReady: () {
                        _yController.addListener(() {});
                      },
                    ),
                  ),
                ),
                // Other content
                const SizedBox(height: 20),
                Text(
                  'Welcome to FloorBot',
                  style: TextStyle(
                    color: FColors.primary,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  child: Text(
                    'FloorBot is a smart cleaning device which can help you in your daily life!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: FColors.primary,
                      fontSize: 18,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 8.0),
                  child: Text(
                    '*Turn on your bluetooth to connect with nearby devices.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: FColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_isScanning) {
                      _flutterBlueClassicPlugin.stopScan();
                    } else {
                      _scanResults.clear();
                      _flutterBlueClassicPlugin.startScan();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60.0, vertical: 10),
                    child: Text(
                      _isScanning ? 'Scanning...' : 'Scan for devices',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Available devices:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: FColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                _buildDeviceList(scanResults),
                const SizedBox(height: 30),
              ],
            ),
            Visibility(
              visible: _isDrawerOpen,
              child: SizedBox(
                height: screenHeight * 0.5,
                child: SlideTransition(
                  position: _animation,
                  child: const FAppDrawer(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(List<BluetoothDevice> scanResults) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (scanResults.isEmpty)
            const Center(child: Text("No devices found yet"))
          else
            for (var (index, result) in scanResults.indexed)
              Card(
                color: FColors.primary.withOpacity(0.1),
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    "${result.name ?? "???"} (${result.address})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      "Bondstate: ${result.bondState.name}, Device type: ${result.type.name}"),
                  trailing: index == _connectingToIndex
                      ? const CircularProgressIndicator()
                      : Text("${result.rssi} dBm"),
                  onTap: () async {
                    setState(() => _connectingToIndex = index);
                    try {
                      final connection =
                          await _flutterBlueClassicPlugin.connect(
                        result.address,
                      );
                      if (connection!.isConnected) {
                        setState(() => _connectingToIndex = null);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NavigationControlPage(connection: connection),
                          ),
                        );
                      }
                    } catch (e) {
                      setState(() => _connectingToIndex = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error connecting: $e")),
                      );
                    }
                  },
                ),
              ),
        ],
      ),
    );
  }
}
