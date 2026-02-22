import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavingsTile extends StatefulWidget {
  final int amount;
  final bool isPaid;
  final VoidCallback onTap;
  final String? currencyFormat; // e.g., '$' or 'k'
  final bool isVietnamese;

  const SavingsTile({
    super.key,
    required this.amount,
    required this.isPaid,
    required this.onTap,
    this.currencyFormat,
    this.isVietnamese = false,
  });

  @override
  State<SavingsTile> createState() => _SavingsTileState();
}

class _SavingsTileState extends State<SavingsTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  String _formatAmount() {
    if (widget.isVietnamese) {
      // For Vietnamese, show amount in k (thousands)
      // The amount is stored in actual value (e.g., 10000)
      // Display as "10k" for 10000
      if (widget.amount >= 1000) {
        return '${(widget.amount / 1000).toStringAsFixed(0)}k';
      }
      return '${widget.amount}đ';
    }
    return '\$${widget.amount}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.0,
            ),
          ),
          child: Stack(
            children: [
              // Amount Text
              Center(
                child: Text(
                  _formatAmount(),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: widget.isVietnamese ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Paid State Overlay
              if (widget.isPaid)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CustomPaint(painter: LiquidSlashPainter()),
                  ),
                ),

              // Inner Shadow Simulation (Semi-transparent overlay)
              if (widget.isPaid)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class LiquidSlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Draw a liquid-like slash from top-right to bottom-left
    path.moveTo(size.width * 0.8, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.5,
      size.width * 0.2,
      size.height * 0.8,
    );

    // Add some "liquid" drops or curves
    // Just a simple curved line for now as "liquid" implies organic shape.
    // Let's make it a bit more wavy.
    path.reset();
    path.moveTo(size.width - 10, 10);
    path.cubicTo(
      size.width * 0.6,
      size.height * 0.4,
      size.width * 0.4,
      size.height * 0.6,
      10,
      size.height - 10,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
