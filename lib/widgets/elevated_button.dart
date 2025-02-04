import 'package:floorbot/utils/colors.dart';
import 'package:flutter/material.dart';

class FElevatedButton extends StatelessWidget {
  const FElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = FColors.primary,
    this.foregroundColor = Colors.grey,
    this.textColor = Colors.white,
    this.borderRadius = 5.0,
    this.elevation = 3.0,
    this.padding = const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
  });

  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color textColor;
  final double borderRadius;
  final double elevation;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(300, 60),
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
