// import 'package:floorbot/controllers/auth_controller.dart';
// import 'package:floorbot/utils/colors.dart';
// import 'package:floorbot/views/about/about_page.dart';
// import 'package:floorbot/views/auth/sign_up.dart';
// import 'package:floorbot/views/home/homepage.dart';
// import 'package:floorbot/views/map/map_page.dart';
// import 'package:floorbot/views/navigation/navigation_control_page.dart';
// import 'package:floorbot/views/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NavigationPage extends StatefulWidget {
//   const NavigationPage({super.key});

//   @override
//   State<NavigationPage> createState() => _NavigationPageState();
// }

// class _NavigationPageState extends State<NavigationPage> {
//   int myCurrentIndex = 0;
//   late List<Widget> navigationPages;
//   late List<BottomNavigationBarItem> navigationItems;

//   @override
//   void initState() {
//     super.initState();
//     initializeNavigation();
//   }

//   void initializeNavigation() {
//     navigationItems = userNavigationItems;
//     navigationPages = userNavigation;
//   }

//   final List<Widget> userNavigation = [
//     const HomePage(),
//     const NavigationControlPage(),
//     const MapPage(),
//     const AboutPage(),
//   ];

//   List<BottomNavigationBarItem> get userNavigationItems {
//     return [
//       BottomNavigationBarItem(
//         icon: Icon(Icons.home),
//         activeIcon: Icon(Icons.shop),
//         label: 'Home',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.shop),
//         activeIcon: Icon(Icons.shop),
//         label: 'Bag',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.shop),
//         activeIcon: Icon(Icons.shop),
//         label: 'Bag',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.shop),
//         activeIcon: Icon(Icons.shop),
//         label: 'Bag',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.home),
//         activeIcon: Icon(Icons.home),
//         label: 'Profile',
//       ),
//     ];
//   }

//   //User Log out
//   void _userLogOut() async {
//     final AuthController authController = AuthController();
//     await authController.signOutFromGoogle();

//     var sharedPref = await SharedPreferences.getInstance();
//     sharedPref.setBool(SplashScreenState.KEYLOGIN, false);

//     if (!mounted) return;

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const SignUpScreen()),
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Successfully logged out!')));
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (navigationItems.isEmpty || navigationPages.isEmpty) {
//       initializeNavigation();
//     }
//     return Stack(
//       children: [
//         Scaffold(
//           body: navigationPages[myCurrentIndex],
//           bottomNavigationBar: Container(
//             padding: const EdgeInsets.symmetric(vertical: 3),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   spreadRadius: 5,
//                   blurRadius: 10,
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               child: BottomNavigationBar(
//                 selectedLabelStyle: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500),
//                 unselectedLabelStyle: TextStyle(
//                   fontSize: 18,
//                 ),
//                 selectedItemColor: FColors.primary,
//                 unselectedItemColor: Colors.black,
//                 type: BottomNavigationBarType.fixed,
//                 backgroundColor: Colors.white,
//                 currentIndex: myCurrentIndex,
//                 onTap: (index) {
//                   setState(() {
//                     myCurrentIndex = index;
//                   });
//                 },
//                 items: navigationItems,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:floorbot/utils/colors.dart';
import 'package:floorbot/views/about/about_page.dart';
import 'package:floorbot/views/home/homepage.dart';
import 'package:floorbot/views/map/map_page.dart';
import 'package:floorbot/views/navigation/navigation_control_page.dart';
import 'package:floorbot/views/schedule/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int screenIndex = 0;
  @override
  Widget build(BuildContext context) {
    List screenList = [
      const HomePage(),
      const NavigationControlPage(),
      const MapPage(),
      const AboutPage(),
      const SchedulePage(),
    ];
    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        height: 65,
        backgroundColor: FColors.primary,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.map_rounded, title: 'Maps'),
          TabItem(icon: Icons.gamepad, title: 'Control'),
          TabItem(icon: Icons.schedule, title: 'Schedule'),
          TabItem(icon: Icons.info_rounded, title: 'About'),
        ],
        onTap: (int i) {
          setState(() {
            screenIndex = i;
          });
        },
      ),
      body: screenList[screenIndex],
    );
  }
}
