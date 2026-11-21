import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 绘境 AI 图标系统
/// 24 网格 · 20 可视区 · 1.75 描边 · 圆头圆角 · 两档圆角（2 / 5.2）
/// 所有图标与品牌标记共用同一套几何，避免不同来源图标混用。
enum HjGlyph {
  spark,
  chat,
  grid,
  check,
  chevronRight,
  chevronDown,
  close,
  download,
  share,
  edit,
  trash,
  back,
  key,
  copy,
  up,
  arrowRight,
  plus,
  image,
  sliders,
  gear,
}

class HjIcon extends StatelessWidget {
  final HjGlyph glyph;
  final double size;
  final Color? color;

  const HjIcon(this.glyph, {super.key, this.size = 22, this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _GlyphPainter(
            glyph,
            color ?? DefaultTextStyle.of(context).style.color ?? Colors.white,
          ),
        ),
      );
}

class _Line {
  final Offset a, b;
  const _Line(this.a, this.b);
}

class _Circ {
  final Offset c;
  final double r;
  const _Circ(this.c, this.r);
}

class _Rect {
  final Rect r;
  final double rad;
  const _Rect(this.r, this.rad);
}

class _Gear {
  final Offset c;
  final double outer, inner;
  const _Gear(this.c, this.outer, this.inner);
}

class _Poly {
  final List<Offset> pts;
  final bool closed;
  const _Poly(this.pts, {this.closed = false});
}

List<Object> _geometry(HjGlyph g) {
  switch (g) {
    case HjGlyph.spark:
      return const [
        _Poly([
          Offset(12, 3.4),
          Offset(14.3, 9.7),
          Offset(20.6, 12),
          Offset(14.3, 14.3),
          Offset(12, 20.6),
          Offset(9.7, 14.3),
          Offset(3.4, 12),
          Offset(9.7, 9.7),
        ], closed: true),
      ];
    case HjGlyph.chat:
      return const [
        _Rect(Rect.fromLTRB(4, 5, 20, 17), 5.2),
        _Poly([Offset(9.2, 17), Offset(7, 20.4), Offset(12.2, 17)]),
      ];
    case HjGlyph.grid:
      return const [
        _Rect(Rect.fromLTRB(4, 4, 11, 11), 2),
        _Rect(Rect.fromLTRB(13, 4, 20, 11), 2),
        _Rect(Rect.fromLTRB(4, 13, 11, 20), 2),
        _Rect(Rect.fromLTRB(13, 13, 20, 20), 2),
      ];
    case HjGlyph.check:
      return const [
        _Poly([Offset(5, 12.4), Offset(9.6, 17), Offset(19, 7.4)]),
      ];
    case HjGlyph.chevronRight:
      return const [
        _Poly([Offset(9.4, 6.4), Offset(15, 12), Offset(9.4, 17.6)]),
      ];
    case HjGlyph.chevronDown:
      return const [
        _Poly([Offset(6.4, 9.4), Offset(12, 15), Offset(17.6, 9.4)]),
      ];
    case HjGlyph.close:
      return const [
        _Line(Offset(7.2, 7.2), Offset(16.8, 16.8)),
        _Line(Offset(16.8, 7.2), Offset(7.2, 16.8)),
      ];
    case HjGlyph.download:
      return const [
        _Line(Offset(12, 4.4), Offset(12, 14.6)),
        _Poly([Offset(8, 10.8), Offset(12, 14.8), Offset(16, 10.8)]),
        _Line(Offset(5, 19), Offset(19, 19)),
      ];
    case HjGlyph.share:
      return const [
        _Line(Offset(12, 14.6), Offset(12, 4.2)),
        _Poly([Offset(8.2, 8), Offset(12, 4.2), Offset(15.8, 8)]),
        _Poly([
          Offset(6.4, 11.4),
          Offset(6.4, 19),
          Offset(17.6, 19),
          Offset(17.6, 11.4),
        ]),
      ];
    case HjGlyph.edit:
      return const [
        _Poly([
          Offset(4.8, 19.2),
          Offset(5.8, 15),
          Offset(15.6, 5.2),
          Offset(18.8, 8.4),
          Offset(9, 18.2),
        ], closed: true),
        _Line(Offset(13.6, 7.4), Offset(16.8, 10.6)),
      ];
    case HjGlyph.trash:
      return const [
        _Line(Offset(4.8, 7.2), Offset(19.2, 7.2)),
        _Poly([
          Offset(9.4, 7.2),
          Offset(9.4, 4.8),
          Offset(14.6, 4.8),
          Offset(14.6, 7.2),
        ]),
        _Poly([
          Offset(7, 7.2),
          Offset(7.8, 19.2),
          Offset(16.2, 19.2),
          Offset(17, 7.2),
        ]),
        _Line(Offset(10, 10.4), Offset(10, 16)),
        _Line(Offset(14, 10.4), Offset(14, 16)),
      ];
    case HjGlyph.back:
      return const [
        _Poly([Offset(14.2, 5.6), Offset(7.8, 12), Offset(14.2, 18.4)]),
      ];
    case HjGlyph.key:
      return const [
        _Circ(Offset(8.8, 9.2), 3.2),
        _Line(Offset(11, 11.4), Offset(19, 19.4)),
        _Line(Offset(15.5, 15.9), Offset(17.6, 13.8)),
      ];
    case HjGlyph.copy:
      return const [
        _Rect(Rect.fromLTRB(8.6, 8.6, 19.4, 19.4), 2.2),
        _Poly([
          Offset(15.4, 8.6),
          Offset(15.4, 6.4),
          Offset(13.2, 4.2),
          Offset(6.4, 4.2),
          Offset(4.2, 6.4),
          Offset(4.2, 13.2),
          Offset(6.4, 15.4),
          Offset(8.6, 15.4),
        ]),
      ];
    case HjGlyph.up:
      return const [
        _Line(Offset(12, 19.4), Offset(12, 5.6)),
        _Poly([Offset(6.6, 11), Offset(12, 5.6), Offset(17.4, 11)]),
      ];
    case HjGlyph.arrowRight:
      return const [
        _Line(Offset(4.8, 12), Offset(19.2, 12)),
        _Poly([Offset(13.6, 6.4), Offset(19.2, 12), Offset(13.6, 17.6)]),
      ];
    case HjGlyph.plus:
      return const [
        _Line(Offset(12, 5), Offset(12, 19)),
        _Line(Offset(5, 12), Offset(19, 12)),
      ];
    case HjGlyph.image:
      return const [
        _Rect(Rect.fromLTRB(3.6, 5, 20.4, 19), 2.4),
        _Circ(Offset(8.8, 9.8), 1.7),
        _Poly([
          Offset(4.6, 16.6),
          Offset(9.4, 12.2),
          Offset(12.6, 15.2),
          Offset(15.2, 12.8),
          Offset(19.4, 17),
        ]),
      ];
    case HjGlyph.gear:
      return const [
        _Gear(Offset(12, 12), 7.4, 5.5),
        _Circ(Offset(12, 12), 2.6),
      ];
    case HjGlyph.sliders:
      return const [
        _Line(Offset(3.6, 8), Offset(20.4, 8)),
        _Line(Offset(3.6, 16), Offset(20.4, 16)),
        _Circ(Offset(15.2, 8), 2.3),
        _Circ(Offset(9.2, 16), 2.3),
      ];
  }
}

class _GlyphPainter extends CustomPainter {
  final HjGlyph glyph;
  final Color color;

  _GlyphPainter(this.glyph, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final u = s / 24;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, 1.75 * u)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;

    for (final item in _geometry(glyph)) {
      if (item is _Line) {
        canvas.drawLine(item.a * u, item.b * u, paint);
      } else if (item is _Circ) {
        canvas.drawCircle(item.c * u, item.r * u, paint);
      } else if (item is _Rect) {
        final r = item.r;
        final rr = RRect.fromRectAndRadius(
          Rect.fromLTRB(r.left * u, r.top * u, r.right * u, r.bottom * u),
          Radius.circular(item.rad * u),
        );
        canvas.drawRRect(rr, paint);
      } else if (item is _Gear) {
        const teeth = 6;
        final pts = <Offset>[];
        for (var i = 0; i < teeth; i++) {
          final base = i * 2 * math.pi / teeth - math.pi / 2;
          const half = 0.24;
          const gap = 0.30;
          pts.add(item.c + Offset(math.cos(base - half), math.sin(base - half)) * item.outer);
          pts.add(item.c + Offset(math.cos(base + half), math.sin(base + half)) * item.outer);
          pts.add(item.c + Offset(math.cos(base + half + gap), math.sin(base + half + gap)) * item.inner);
          pts.add(item.c + Offset(math.cos(base + math.pi / teeth - gap - half),
              math.sin(base + math.pi / teeth - gap - half)) * item.inner);
        }
        final path = Path();
        path.addPolygon(pts.map((p) => p * u).toList(), true);
        canvas.drawPath(path, paint);
      } else if (item is _Poly) {
        final path = Path();
        final pts = item.pts;
        path.moveTo(pts.first.dx * u, pts.first.dy * u);
        for (var i = 1; i < pts.length; i++) {
          path.lineTo(pts[i].dx * u, pts[i].dy * u);
        }
        if (item.closed) path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}
