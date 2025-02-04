import 'package:flutter/material.dart';

class NTextFieldInput extends StatelessWidget {
  const NTextFieldInput({
    super.key,
    required this.hintText,
    required this.icon,
    required this.isPass,
    required this.textController,
  });

  final TextEditingController textController;
  final bool isPass;
  final String hintText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: TextFormField(
        controller: textController,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 20),
          icon: Icon(icon),
        ),
      ),
    );
  }
}
