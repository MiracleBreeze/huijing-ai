import 'package:flutter/material.dart';

import '../theme.dart';

/// 品牌标志：金属环 + 发光光点
/// 与桌面图标、Web 图标同一几何：环 r6.8 / 描边 2.2，光点 r2.7。
/// 大尺寸保留金属渐变、内倒角与光晕；小尺寸收敛为实心描边，保证 20px 仍清晰。
class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _MarkPainter(size)),
      );
}

class _MarkPainter extends CustomPainter {
  final double size;
  const _MarkPainter(this.size);

  static const _metal = [
    Color(0xFFFFFFFF),
    Color(0xFFEFEFF5),
    Color(0xFFD5D5DF),
    Color(0xFFBEBECB),
    Color(0xFFD8D8E2),
    Color(0xFFF7F7FB),
  ];
  static const _metalStops = [0.0, 0.18, 0.42, 0.62, 0.82, 1.0];

  @override
  void paint(Canvas canvas, Size s) {
    final u = s.shortestSide / 24;
    final c = Offset(9.3 * u, 12 * u);
    final bead = Offset(18.6 * u, 12 * u);
    final rich = s.shortestSide >= 26;

    // 光晕：光点向外扩散的紫光
    final haloRect = Rect.fromCircle(center: bead, radius: 6.2 * u);
    final halo = Paint()
      ..shader = const RadialGradient(colors: [
        Color(0x66A78BFA),
        Color(0x218B5CF6),
        Color(0x008B5CF6),
      ], stops: [
        0.0,
        0.6,
        1.0
      ]).createShader(haloRect);
    canvas.drawCircle(bead, 6.2 * u, halo);

    // 环
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (rich ? 2.2 : 2.4) * u
      ..strokeCap = StrokeCap.round;
    if (rich) {
      ring.shader = LinearGradient(
        begin: const Alignment(-0.9, -1),
        end: const Alignment(0.9, 1),
        colors: _metal,
        stops: _metalStops,
      ).createShader(Rect.fromCircle(center: c, radius: 6.8 * u));
    } else {
      ring.color = const Color(0xFFECECF1);
    }
    canvas.drawCircle(c, 6.8 * u, ring);

    // 内倒角高光：让环有厚度
    if (rich) {
      final bevel = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.45 * u
        ..color = const Color(0x47FFFFFF);
      canvas.drawCircle(c, 5.55 * u, bevel);
    }

    // 光点：玻璃珠质感的高光球
    final beadRect = Rect.fromCircle(center: bead, radius: 2.7 * u);
    final beadPaint = Paint();
    if (rich) {
      beadPaint.shader = const RadialGradient(
        center: Alignment(-0.3, -0.38),
        radius: 0.95,
        colors: [
          Color(0xFFF8F5FF),
          Color(0xFFC6B1FD),
          Color(0xFF8A61F7),
          Color(0xFF6B47E8)
        ],
        stops: [0.0, 0.38, 0.78, 1.0],
      ).createShader(beadRect);
    } else {
      beadPaint.color = C.accent;
    }
    canvas.drawCircle(bead, 2.7 * u, beadPaint);

    // 镜面高光点
    final spec = Paint()..color = const Color(0x99FFFFFF);
    canvas.drawCircle(Offset(17.7 * u, 11.1 * u), 0.55 * u, spec);
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) => old.size != size;
}
