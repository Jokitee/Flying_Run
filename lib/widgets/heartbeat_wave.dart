import 'dart:math';
import 'package:flutter/material.dart';

class HeartbeatWave extends StatefulWidget {
  final int heartRate;
  final Color color;
  final double height;

  const HeartbeatWave({
    super.key,
    required this.heartRate,
    this.color = const Color(0xFF00E6FF),
    this.height = 80.0,
  });

  @override
  State<HeartbeatWave> createState() => _HeartbeatWaveState();
}

class _HeartbeatWaveState extends State<HeartbeatWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation controller to drive the wave scrolling
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant HeartbeatWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heartRate != widget.heartRate) {
      // Dynamically adjust animation speed based on heart rate
      // Higher heart rate = faster heartbeat wave scroll
      double beatsPerSecond = widget.heartRate / 60.0;
      // We adjust duration so 60bpm = 3s loop, 120bpm = 1.5s loop, etc.
      double newDurationSec = 3.0 / (beatsPerSecond > 0 ? beatsPerSecond : 1.0);
      newDurationSec = newDurationSec.clamp(0.8, 4.0);

      _controller.duration = Duration(milliseconds: (newDurationSec * 1000).round());
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _HeartbeatPainter(
            heartRate: widget.heartRate,
            phase: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

class _HeartbeatPainter extends CustomPainter {
  final int heartRate;
  final double phase;
  final Color color;

  _HeartbeatPainter({
    required this.heartRate,
    required this.phase,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final midY = height / 2;

    // Step optimized from 2.0 to 4.0 to reduce segment calculations by 50%
    double step = 4.0;
    bool isFirst = true;

    for (double x = 0; x <= width; x += step) {
      // Scale x into the wave period
      // Let's make 150 pixels be one heartbeat cycle
      double cycleLength = 160.0;
      // Offset by the animated phase
      double targetX = x - (phase * cycleLength);
      double localX = targetX % cycleLength;

      double y = midY;

      // Define standard ECG shape within a 0..160 interval
      if (localX >= 20 && localX < 35) {
        // P-wave
        double pPhase = (localX - 20) / 15 * pi;
        y -= sin(pPhase) * (height * 0.08);
      } else if (localX >= 45 && localX < 48) {
        // Q-dip
        double qPhase = (localX - 45) / 3 * pi;
        y += sin(qPhase) * (height * 0.06);
      } else if (localX >= 48 && localX < 54) {
        // R-spike
        double rPhase = (localX - 48) / 6 * pi;
        y -= sin(rPhase) * (height * 0.45);
      } else if (localX >= 54 && localX < 59) {
        // S-dip
        double sPhase = (localX - 54) / 5 * pi;
        y += sin(sPhase) * (height * 0.18);
      } else if (localX >= 75 && localX < 98) {
        // T-wave
        double tPhase = (localX - 75) / 23 * pi;
        y -= sin(tPhase) * (height * 0.14);
      }

      // Add noise if heart rate is high
      if (heartRate > 120) {
        y += (sin(x * 0.5) * 0.8);
      }

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw glowing shadow first
    canvas.drawPath(path, glowPaint);
    // Draw sharp core line
    canvas.drawPath(path, paint);

    // Draw scanning grid background (simplified to 40px intervals to reduce draw calls)
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    for (double y = 0; y < height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }
    // Vertical grid lines
    for (double x = 0; x < width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartbeatPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.heartRate != heartRate ||
        oldDelegate.color != color;
  }
}
