import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets? padding;
  final int delay;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: child,
      )
          .animate()
          .fadeIn(
            duration: const Duration(milliseconds: 500),
            delay: Duration(milliseconds: delay),
            curve: Curves.easeOut,
          )
          .slideY(
            begin: 0.15,
            end: 0,
            duration: const Duration(milliseconds: 500),
            delay: Duration(milliseconds: delay),
            curve: Curves.easeOutCubic,
          )
          .scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1, 1),
            duration: const Duration(milliseconds: 500),
            delay: Duration(milliseconds: delay),
            curve: Curves.easeOutCubic,
          ),
    );
  }
}
