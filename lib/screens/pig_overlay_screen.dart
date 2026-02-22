import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PigOverlayScreen extends StatefulWidget {
  final VoidCallback onFeed;
  final VoidCallback onSkip;

  const PigOverlayScreen({
    super.key,
    required this.onFeed,
    required this.onSkip,
  });

  @override
  State<PigOverlayScreen> createState() => _PigOverlayScreenState();
}

class _PigOverlayScreenState extends State<PigOverlayScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _wiggleController;
  late AnimationController _fadeController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _wiggleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    // Bounce animation for pig
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Wiggle animation for ears
    _wiggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _wiggleAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _wiggleController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _bounceController.repeat(reverse: true);
    _wiggleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _wiggleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Pig
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _bounceAnimation,
                        _wiggleAnimation,
                      ]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            sin(_bounceAnimation.value * pi * 2) * 10,
                          ),
                          child: _buildPig(),
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Message
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.pink.shade300.withValues(alpha: 0.9),
                            Colors.pink.shade400.withValues(alpha: 0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Bạn ơi! 🐷',
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Hôm nay Heo con\nchưa được cho ăn!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Skip button
                        _buildButton(
                          onTap: widget.onSkip,
                          text: 'Bỏ qua',
                          backgroundColor: Colors.grey.shade700,
                          icon: Icons.close,
                        ),
                        const SizedBox(width: 20),
                        // Feed button
                        _buildButton(
                          onTap: widget.onFeed,
                          text: 'Cho ăn',
                          backgroundColor: Colors.green.shade600,
                          icon: Icons.favorite,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPig() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Body shadow
          Positioned(
            bottom: 10,
            child: Container(
              width: 140,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          // Body
          Container(
            width: 160,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.pink.shade200, Colors.pink.shade300],
              ),
              borderRadius: BorderRadius.circular(70),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.shade100.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          // Left ear
          Positioned(
            top: 5,
            left: 25,
            child: AnimatedBuilder(
              animation: _wiggleAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _wiggleAnimation.value - 0.3,
                  child: _buildEar(),
                );
              },
            ),
          ),
          // Right ear
          Positioned(
            top: 5,
            right: 25,
            child: AnimatedBuilder(
              animation: _wiggleAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -_wiggleAnimation.value + 0.3,
                  child: _buildEar(),
                );
              },
            ),
          ),
          // Face
          Positioned(top: 45, child: _buildFace()),
          // Nose
          Positioned(top: 85, child: _buildNose()),
          // Blush left
          Positioned(top: 75, left: 30, child: _buildBlush()),
          // Blush right
          Positioned(top: 75, right: 30, child: _buildBlush()),
        ],
      ),
    );
  }

  Widget _buildEar() {
    return Container(
      width: 40,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.pink.shade300, Colors.pink.shade200],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildFace() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left eye
        _buildEye(),
        const SizedBox(width: 40),
        // Right eye
        _buildEye(),
      ],
    );
  }

  Widget _buildEye() {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5),
        ],
      ),
      child: Center(
        child: Container(
          width: 15,
          height: 15,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
          child: Align(
            alignment: const Alignment(0.3, -0.3),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNose() {
    return Container(
      width: 55,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.pink.shade400, Colors.pink.shade500],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.shade300.withValues(alpha: 0.5),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.pink.shade700,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 12,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.pink.shade700,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlush() {
    return Container(
      width: 25,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.pink.shade100.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onTap,
    required String text,
    required Color backgroundColor,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isPrimary ? 30 : 20,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
