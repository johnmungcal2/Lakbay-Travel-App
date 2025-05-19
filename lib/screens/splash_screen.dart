import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'lib/assets/images/lakbay-logo.png',
          width: 150,
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
