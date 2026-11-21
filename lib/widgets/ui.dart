import 'package:flutter/material.dart';

import '../models.dart';
import '../services/media.dart';
import '../theme.dart';
import 'hj_icons.dart';

Widget srcImage(String src,
    {BoxFit fit = BoxFit.cover, double? width, double? height}) {
  if (isRemote(src)) {
    return Image.network(
      src,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => _placeholder(width, height),
      loadingBuilder: (c, child, p) =>
          p == null ? child : _placeholder(width, height),
    );
  }
  try {
    return Image.memory(
      Media.bytesOfDataUri(src),
      fit: fit,
      width: width,
      height: height,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => _placeholder(width, height),
    );
  } catch (_) {
    return _placeholder(width, height);
  }
}

Widget _placeholder(double? w, double? h) => Container(
      width: w,
      height: h,
      color: C.s2,
      alignment: Alignment.center,
      child: const Icon(Icons.photo_library_outlined, color: C.out),
    );

class Grab extends StatelessWidget {
  const Grab({super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 34,
          height: 3,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF3A3A46),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      );
}

/// 通用底部面板：可上下拖动（DraggableScrollableSheet）
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required List<Widget> children,
  double initial = 0.62,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x99000000),
    builder: (c) => DraggableScrollableSheet(
      initialChildSize: initial,
      minChildSize: 0.35,
      maxChildSize: 0.96,
      snap: true,
      expand: false,
      builder: (c, ctrl) => Container(
        decoration: const BoxDecoration(
          color: C.s1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.xxl)),
          boxShadow: [
            BoxShadow(color: Color(0x80000000), blurRadius: 44, offset: Offset(0, -16)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: ListView(
          controller: ctrl,
          padding: EdgeInsets.fromLTRB(
              18, 10, 18, 20 + MediaQuery.of(c).padding.bottom),
          children: [const Grab(), ...children],
        ),
      ),
    ),
  );
}

class IconBtn extends StatelessWidget {
  final HjGlyph glyph;
  final VoidCallback? onTap;
  final double size;
  final Color color;
  final Color? bg;

  const IconBtn(
    this.glyph, {
    super.key,
    this.onTap,
    this.size = 36,
    this.color = C.onv,
    this.bg = C.s1,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: bg ?? Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: HjIcon(glyph, size: size * 0.52, color: color),
          ),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text, style: t(12, FontWeight.w500, C.out)),
      );
}

Widget fieldLabel(String s) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(s, style: t(12.5, FontWeight.w500, C.onv)),
    );
