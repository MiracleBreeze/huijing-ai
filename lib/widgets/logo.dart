import 'package:flutter/material.dart';

import '../theme.dart';

/// 品牌标志：细环 + 光点，无底色无边框
class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 30});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _MarkPainter()),
      );
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.085
      ..color = const Color(0xFFD9D9E0);
    canvas.drawArc(
      Rect.fromCircle(center: c.translate(-r * 0.14, 0), radius: r * 0.62),
      -1.15,
      5.05,
      false,
      ring,
    );
    final dot = Paint()..color = C.accent;
    canvas.drawCircle(c.translate(r * 0.44, 0), r * 0.24, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
