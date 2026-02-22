import 'package:flutter/material.dart';
import 'dart:math' as math;

class RippleBackground extends StatefulWidget {
  final Widget child;
  const RippleBackground({super.key, required this.child});

  @override
  State<RippleBackground> createState() => _RippleBackgroundState();
}

class _RippleBackgroundState extends State<RippleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient - Darker colors for better contrast
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6B4BA6), Color(0xFF2E7EB3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Ripples
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(painter: RipplePainter(_controller.value));
            },
          ),
        ),
        // Content
        widget.child,
      ],
    );
  }
}

class RipplePainter extends CustomPainter {
  final double animationValue;

  RipplePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = math.max(size.width, size.height);

    // Draw multiple ripples
    for (int i = 0; i < 3; i++) {
      final alphaValue = 0.05 + (0.05 * (1 - (animationValue + i * 0.33) % 1));
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alphaValue)
        ..style = PaintingStyle.fill;

      double radius = maxRadius * ((animationValue + i * 0.33) % 1);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
