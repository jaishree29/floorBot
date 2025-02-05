import 'package:floorbot/controllers/auth_controller.dart';
import 'package:floorbot/views/auth/sign_up.dart';
import 'package:floorbot/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FAppDrawer extends StatefulWidget {
  const FAppDrawer({super.key});

  @override
  State<FAppDrawer> createState() => _FAppDrawerState();
}

class _FAppDrawerState extends State<FAppDrawer> {
  // User log out
  void _userLogOut() async {
    final AuthController authController = AuthController();
    await authController.signOutFromGoogle();

    var sharedPref = await SharedPreferences.getInstance();
    sharedPref.setBool(SplashScreenState.KEYLOGIN, false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully logged out!')));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      shadowColor: Colors.grey,
      elevation: 5.0,
      shape: const Border(right: BorderSide.none),
      backgroundColor: Colors.white,
      child: ListView(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Account'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {},
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ElevatedButton(
                  onPressed: _userLogOut,
                  child: Text('Log Out'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
