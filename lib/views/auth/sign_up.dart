import 'package:floorbot/controllers/auth_controller.dart';
import 'package:floorbot/utils/colors.dart';
import 'package:floorbot/views/auth/login.dart';
import 'package:floorbot/views/navbar.dart';
import 'package:floorbot/widgets/elevated_button.dart';
import 'package:floorbot/widgets/text_field_input.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = AuthController();

  void _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final user = await _authController.signUpWithEmailPassword(email, password);

    if (!mounted) return;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    if (!mounted) {
      return null;
    }

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User signed up: ${user.email}")),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const NavBar()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User already exists")),
      );
    }
  }

  void _handleGoogleSignUp() async {
    await _authController.signOutFromGoogle();

    final user = await _authController.signUpWithGoogle();

    if (!mounted) return;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User signed up: ${user.email}")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavBar()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User already exists")),
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const SizedBox(height: 100),
                  // Logo
                  // Image.asset(
                  //   'assets/logo.png',
                  //   height: 100,
                  // ),
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
                  // Sign-Up Button

                  FElevatedButton(
                    text: 'Sign Up',
                    onPressed: _handleSignUp,
                    backgroundColor: FColors.primary,
                  ),
                  const SizedBox(height: 20),

                  // Google Sign-Up Button

                  FElevatedButton(
                    text: 'Sign Up with Google',
                    textColor: Colors.black,
                    onPressed: _handleGoogleSignUp,
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Already have an account?',
                    style: TextStyle(fontSize: 17),
                  ),
                  TextButton(
                    onPressed: () => {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      ),
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
