import 'package:flutter/material.dart';
import 'dart:math' as math;

class BackgroundDesign extends StatelessWidget {
  final Widget child;

  const BackgroundDesign({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated circles in background
        Positioned(
          top: -100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -80,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Decorative shapes
        Positioned(
          top: 100,
          left: 20,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200,
          right: 30,
          child: Transform.rotate(
            angle: -math.pi / 6,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

