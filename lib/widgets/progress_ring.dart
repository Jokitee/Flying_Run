import 'dart:math';
import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double strokeWidth;
  final double size;
  final List<Color> gradientColors;
  final Color backgroundColor;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    this.strokeWidth = 10.0,
    required this.size,
    required this.gradientColors,
    required this.backgroundColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              gradientColors: gradientColors,
              backgroundColor: backgroundColor,
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0.0) return;

    // Active progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    // Create gradient
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: gradientColors.length == 1 
          ? [gradientColors[0], gradientColors[0]] 
          : gradientColors,
      tileMode: TileMode.clamp,
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);

    // Glowing dot at the end of the progress arc (only if progress is significant)
    if (progress > 0.02) {
      final endAngle = startAngle + sweepAngle;
      final dotX = center.dx + radius * cos(endAngle);
      final dotY = center.dy + radius * sin(endAngle);

      final glowPaint = Paint()
        ..color = gradientColors.last
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 + 3, glowPaint);

      final corePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 4, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.gradientColors != gradientColors;
  }
}
