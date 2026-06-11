import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class GlowingCard extends StatelessWidget {
  final Widget child;
  final List<Color> borderGradientColors;
  final Color backgroundColor;
  final double borderRadius;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final double blurSigma;

  const GlowingCard({
    super.key,
    required this.child,
    this.borderGradientColors = const [
      Colors.white10,
      Colors.white10,
    ],
    this.backgroundColor = const Color(0x0Fffffff), // 6% white opacity placeholder
    this.borderRadius = 20.0,
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.blurSigma = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.select<AppState, bool>((state) => state.isDarkMode);

    final actualBgColor = backgroundColor != const Color(0x0Fffffff) 
        ? backgroundColor 
        : (isDark ? Colors.black.withValues(alpha: 0.65) : Colors.white.withValues(alpha: 0.88));

    final actualBorderColors = borderGradientColors.length == 2 && borderGradientColors[0] == Colors.white10
        ? [
            isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
            isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
          ]
        : borderGradientColors;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: CustomPaint(
          painter: _GlowingBorderPainter(
            borderRadius: borderRadius,
            borderWidth: borderWidth,
            gradientColors: actualBorderColors,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: actualBgColor,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5],
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _GlowingBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth;
  final List<Color> gradientColors;

  _GlowingBorderPainter({
    required this.borderRadius,
    required this.borderWidth,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final paint = Paint()
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    if (gradientColors.length == 1) {
      paint.color = gradientColors[0];
    } else {
      // Linear gradient from top-left to bottom-right
      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ).createShader(rect);
    }

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowingBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.gradientColors != gradientColors;
  }
}
