import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CompassPainter extends CustomPainter {
  final double heading;
  CompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Draw Outer Ring
    final ringPaint = Paint()
      ..color = const Color(0xFF02569B).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    // 2. Draw Active Arc (Secondary Color)
    final arcPaint = Paint()
      ..color = const Color(0xFF13B9FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      (heading * math.pi / 180),
      false,
      arcPaint,
    );

    // 3. Draw Tick Marks and Labels
    for (int i = 0; i < 360; i += 10) {
      final angle = (i - 90) * math.pi / 180;
      final isMajor = i % 90 == 0;
      final tickLength = isMajor ? 12.0 : 6.0;

      final p1 = Offset(
        center.dx + (radius - 5) * math.cos(angle),
        center.dy + (radius - 5) * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - 5 - tickLength) * math.cos(angle),
        center.dy + (radius - 5 - tickLength) * math.sin(angle),
      );

      final tickPaint = Paint()
        ..color = isMajor ? const Color(0xFF13B9FD) : Colors.white24
        ..strokeWidth = isMajor ? 2 : 1;

      canvas.drawLine(p1, p2, tickPaint);

      // Draw N, E, S, W labels
      if (isMajor) {
        final label = _getDirection(i);
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: GoogleFonts.inter(
              color: const Color(0xFF13B9FD),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final textOffset = Offset(
          center.dx + (radius - 35) * math.cos(angle) - (textPainter.width / 2),
          center.dy +
              (radius - 35) * math.sin(angle) -
              (textPainter.height / 2),
        );
        textPainter.paint(canvas, textOffset);
      }
    }

    // 4. Draw Needle
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(heading * math.pi / 180);

    final needlePath = Path()
      ..moveTo(0, -radius + 40) // Tip
      ..lineTo(10, 0)
      ..lineTo(0, 20)
      ..lineTo(-10, 0)
      ..close();

    final needlePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF13B9FD), Color(0xFF02569B)],
      ).createShader(Rect.fromLTWH(-10, -radius + 40, 20, radius));

    canvas.drawPath(needlePath, needlePaint);
    canvas.restore();
  }

  String _getDirection(int angle) {
    if (angle == 0) return 'N';
    if (angle == 90) return 'E';
    if (angle == 180) return 'S';
    if (angle == 270) return 'W';
    return '';
  }

  @override
  bool shouldRepaint(covariant CompassPainter oldDelegate) =>
      oldDelegate.heading != heading;
}
