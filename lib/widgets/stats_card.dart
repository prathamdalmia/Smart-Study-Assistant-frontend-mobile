import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'animated_card.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final int delay;
  double get font_size {
    if (value.length < 2) {
      return 32;
    } else if (value.length < 3) {
      return 23;
    } else {
      return 22;
    }
  }

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.backgroundColor,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      delay: delay,
      color: backgroundColor ?? Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      iconColor.withOpacity(0.15),
                      iconColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: font_size,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
