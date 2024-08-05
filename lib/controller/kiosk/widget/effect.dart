import 'package:flutter/material.dart';

class RipplePainter extends CustomPainter {
  final List<Offset> tapPositions;

  RipplePainter(this.tapPositions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (var position in tapPositions) {
      canvas.drawCircle(position, 20, paint);
    }
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.tapPositions != tapPositions;
  }
}
