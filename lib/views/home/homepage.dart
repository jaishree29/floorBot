import 'package:floorbot/utils/colors.dart';
import 'package:floorbot/views/home/app_drawer.dart';
import 'package:floorbot/views/notifications/notifications.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool _isDrawerOpen = false;
  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _controller.dispose();
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
    return Scaffold(
      appBar: AppBar(
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
             // Drawer
            Visibility(
              visible: _isDrawerOpen,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
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
}
