import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Loading", style: TextStyle(fontSize: 20)),
          LottieBuilder.asset(
              "lib/mealApp/assets/animations/Animation - 1701269083410.json"),
        ],
      )),
    );
  }
}
