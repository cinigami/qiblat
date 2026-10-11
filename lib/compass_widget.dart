import 'dart:math';
import 'package:flutter/material.dart';

class CompassWidget extends StatelessWidget {
  final double compassHeading;
  final double arrowRotation;
  final bool isAligned;
  final double size;

  const CompassWidget({
    super.key,
    required this.compassHeading,
    required this.arrowRotation,
    required this.isAligned,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -compassHeading * (pi / 180),
            child: CustomPaint(
              size: Size(size, size),
              painter: _CompassRosePainter(),
            ),
          ),
          Transform.rotate(
            angle: arrowRotation * (pi / 180),
            child: CustomPaint(
              size: Size(size * 0.55, size * 0.55),
              painter: _QiblaArrowPainter(isAligned: isAligned),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = const Color(0xFF1A1A2E)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Tick marks (36 ticks at 10° each)
    final tickPaint = Paint()..style = PaintingStyle.stroke;
    for (int i = 0; i < 36; i++) {
      final angle = (i * 10 - 90) * (pi / 180);
      final isMajor = i % 9 == 0;
      final innerR = isMajor ? radius - 22 : radius - 14;
      canvas.drawLine(
        Offset(center.dx + innerR * cos(angle), center.dy + innerR * sin(angle)),
        Offset(center.dx + (radius - 4) * cos(angle), center.dy + (radius - 4) * sin(angle)),
        tickPaint
          ..strokeWidth = isMajor ? 2.5 : 1.0
          ..color = isMajor ? Colors.white70 : Colors.white38,
      );
    }

    // Cardinal labels: N (red), E, S, W (white)
    const directions = ['N', 'E', 'S', 'W'];
    final labelRadius = radius - 40;
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * (pi / 180);
      final x = center.dx + labelRadius * cos(angle);
      final y = center.dy + labelRadius * sin(angle);
      final tp = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: directions[i] == 'N' ? const Color(0xFFEF5350) : Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }

    // Center dot
    canvas.drawCircle(center, 5, Paint()..color = Colors.white38);
  }

  @override
  bool shouldRepaint(_CompassRosePainter old) => false;
}

class _QiblaArrowPainter extends CustomPainter {
  final bool isAligned;
  const _QiblaArrowPainter({required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final color = isAligned ? const Color(0xFFFFD700) : const Color(0xFF4CAF50);
    final center = Offset(size.width / 2, size.height / 2);
    final h = size.height;
    final w = size.width;

    // Arrow body pointing up toward Qibla
    final path = Path()
      ..moveTo(center.dx, center.dy - h * 0.42)
      ..lineTo(center.dx + w * 0.14, center.dy - h * 0.04)
      ..lineTo(center.dx + w * 0.08, center.dy - h * 0.04)
      ..lineTo(center.dx + w * 0.08, center.dy + h * 0.42)
      ..lineTo(center.dx - w * 0.08, center.dy + h * 0.42)
      ..lineTo(center.dx - w * 0.08, center.dy - h * 0.04)
      ..lineTo(center.dx - w * 0.14, center.dy - h * 0.04)
      ..close();

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);

    // Small Kaaba square at tip
    final kRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - h * 0.42 + 10),
      width: 10,
      height: 10,
    );
    canvas.drawRect(kRect, Paint()..color = Colors.black..style = PaintingStyle.fill);
    canvas.drawRect(kRect, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_QiblaArrowPainter old) => old.isAligned != isAligned;
}
