import 'package:floorbot/controllers/auth_controller.dart';
import 'package:floorbot/utils/colors.dart';
import 'package:floorbot/views/auth/sign_up.dart';
import 'package:floorbot/views/navbar.dart';
import 'package:floorbot/views/splash_screen.dart';
import 'package:floorbot/widgets/elevated_button.dart';
import 'package:floorbot/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = AuthController();

  // Sign-In with Email and Password
  void _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    try {
      // Sign in the user with email and password
      final user =
          await _authController.signInWithEmailPassword(email, password);

      if (!mounted) return;

      // If sign-in is successful
      if (user != null) {
        // Store login state in SharedPreferences
        var sharedPref = await SharedPreferences.getInstance();
        sharedPref.setBool(SplashScreenState.KEYLOGIN, true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Welcome back, ${user.email}!")),
        );

        // Navigate to the next page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationPage()),
        );
      } else {
        // If the user is not found, prompt them to sign up
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("User does not exist. Please sign up first.")),
        );
      }
    } catch (e) {
      // Handle any errors during sign-in (like wrong credentials)
      print("Sign-in error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in: ${e.toString()}")),
      );
    }
  }

  // Sign-In with Google
  void _handleGoogleSignIn() async {
    // await _authController.signOutFromGoogle();
    final user = await _authController.signInWithGoogle();

    var sharedPref = await SharedPreferences.getInstance();
    sharedPref.setBool(SplashScreenState.KEYLOGIN, true);

    if (!mounted) {
      return;
    }

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome back, ${user.email}!")),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const NavigationPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User does not exist. Please sign up first.")),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 100),
                const Icon(Icons.mail, size: 70),
                const SizedBox(height: 80),

                // Email TextField
                NTextFieldInput(
                  hintText: 'Email',
                  icon: Icons.email,
                  isPass: false,
                  textController: _emailController,
                ),

                // Password TextField
                NTextFieldInput(
                  hintText: 'Password',
                  icon: Icons.lock,
                  isPass: true,
                  textController: _passwordController,
                ),
              ],
            ),
            const SizedBox(height: 80),
            Column(
              children: [
                // Sign-In Button
                FElevatedButton(
                  text: 'Sign In',
                  onPressed: _handleSignIn,
                  backgroundColor: FColors.primary,
                ),
                const SizedBox(height: 20),

                // Google Sign-In Button
                FElevatedButton(
                  text: 'Sign In with Google',
                  textColor: Colors.black,
                  onPressed: _handleGoogleSignIn,
                  backgroundColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 50),
            Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Don\'t have an account?',
                  style: TextStyle(fontSize: 17),
                ),
                TextButton(
                  onPressed: () => {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    ),
                  },
                  child: const Text('Sign Up', style: TextStyle(fontSize: 17)),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
