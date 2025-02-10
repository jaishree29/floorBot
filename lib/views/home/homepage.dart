import 'package:floorbot/controllers/ble_controller.dart';
import 'package:floorbot/utils/colors.dart';
import 'package:floorbot/views/home/app_drawer.dart';
import 'package:floorbot/views/notifications/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final BluetoothController controller = Get.put(BluetoothController());

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

  @override
  void dispose() {
    _controller.dispose();
    _yController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final videoHeight = screenHeight * 0.25;
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
                // Other content can go here
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
                  onPressed: () async {
                    if (await Permission.bluetoothScan.isGranted &&
                        await Permission.bluetoothConnect.isGranted &&
                        await Permission.locationWhenInUse.isGranted) {
                      controller.scanDevices();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Permissions not granted'),
                          backgroundColor: Colors.red,
                        ),
                      );
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
                      'Scan for devices',
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
                _buildList(context),
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

  Widget _buildList(BuildContext context) {
    return GetBuilder<BluetoothController>(
      builder: (controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<List<ScanResult>>(
                stream: controller.scanResult,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Card(
                      color: FColors.primary.withOpacity(0.2),
                      elevation: 0,
                      // margin: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Center(
                          child: Text(
                            'No devices found',
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap:
                        true, // Add this to make the ListView scrollable inside a Column
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index];
                      ScanResult r = snapshot.data!.last;
                      print(
                          '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
                      return Card(
                        color: FColors.primary.withOpacity(0.1),
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          title: Text(
                            data.device.platformName.isNotEmpty
                                ? data.device.platformName
                                : "Unknown Device",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(data.device.remoteId.str),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("RSSI: ${data.rssi}"),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  await controller.connectToDevice(data.device);
                                  if (controller.isConnected.value) {
                                    // Send text to the connected device
                                    await controller
                                        .sendTextToDevice("Hello, Device!");
                                  }
                                },
                                child: const Text('Connect'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
