import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart_model.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progressValue = 0.0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<CartModel>(
        context,
        listen: false,
      ).loadCart();
    });

    _startLoading();
  }

  void _startLoading() {
    const totalDuration = Duration(seconds: 6);

    const step = Duration(milliseconds: 50);

    double increment =
        step.inMilliseconds / totalDuration.inMilliseconds;

    _timer = Timer.periodic(step, (timer) {
      if (mounted) {
        setState(() {
          if (_progressValue < 1.0) {
            _progressValue += increment;
          } else {
            _timer?.cancel();

            _navigateToLogin();
          }
        });
      }
    });
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) =>
            LoginScreen(),

        transitionDuration: const Duration(
          milliseconds: 800,
        ),

        transitionsBuilder:
            (context, anim1, anim2, child) {
          return FadeTransition(
            opacity: anim1,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,

            colors: [
              Color(0xFFFF5F6D),
              Color(0xFFFFC371),
            ],
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Spacer(flex: 4),

            const Text(
              "URBANVIBE",
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "PREMIUM FASHION HUB",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
              ),
            ),

            const Spacer(flex: 3),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 80,
              ),

              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),

                    child: LinearProgressIndicator(
                      value: _progressValue > 1.0
                          ? 1.0
                          : _progressValue,

                      backgroundColor:
                          Colors.white.withOpacity(0.15),

                      color: Colors.white,
                      minHeight: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "${(_progressValue.clamp(0.0, 1.0) * 100).toInt()}%",

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}