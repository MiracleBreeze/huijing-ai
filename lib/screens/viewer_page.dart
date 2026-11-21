import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../services/media.dart';
import '../theme.dart';
import '../widgets/hj_icons.dart';
import '../widgets/ui.dart';

class ViewerPage extends StatefulWidget {
  final Work work;
  final int start;
  final VoidCallback? onEdit;
  final VoidCallback? onAgain;

  const ViewerPage({
    super.key,
    required this.work,
    this.start = 0,
    this.onEdit,
    this.onAgain,
  });

  @override
  State<ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {
  late int index;
  late PageController ctrl;

  @override
  void initState() {
    super.initState();
    index = widget.start.clamp(0, widget.work.imgs.length - 1);
    ctrl = PageController(initialPage: index);
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void _toast(String s) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(s, style: t(12.5, FontWeight.w400, C.on)),
        backgroundColor: C.s3,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.work;
    final img = w.imgs[index];
    return Scaffold(
      backgroundColor: const Color(0xFF05050A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景：同图模糊压暗
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Transform.scale(
              scale: 1.14,
              child: srcImage(img, fit: BoxFit.cover),
            ),
          ),
          Container(color: const Color(0x99050509)),
          PageView.builder(
            controller: ctrl,
            itemCount: w.imgs.length,
            onPageChanged: (i) => setState(() => index = i),
            itemBuilder: (c, i) => Center(
              child: srcImage(w.imgs[i], fit: BoxFit.contain),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 8,
                  child: IconBtn(
                    HjGlyph.back,
                    bg: const Color(0x9914141A),
                    onTap: () => Navigator.of(context).pop(),
                    size: 38,
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 60,
                  right: 60,
                  child: Text(
                    '${index + 1} / ${w.imgs.length}',
                    textAlign: TextAlign.center,
                    style: t(12.5, FontWeight.w400, const Color(0xFFB7B7C2)),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 126,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RailBtn(
                        glyph: HjGlyph.share,
                        label: '分享',
                        onTap: () => Media.shareImage(img, w.prompt),
                      ),
                      const SizedBox(height: 18),
                      _RailBtn(
                        glyph: HjGlyph.edit,
                        label: '重新编辑',
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onEdit?.call();
                        },
                      ),
                      const SizedBox(height: 18),
                      _RailBtn(
                        glyph: HjGlyph.spark,
                        label: '再次生成',
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onAgain?.call();
                        },
                      ),
                      const SizedBox(height: 18),
                      _RailBtn(
                        glyph: HjGlyph.download,
                        label: '保存',
                        onTap: () async {
                          _toast(await Media.saveImage(img));
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: w.prompt));
                      _toast('提示词已复制');
                    },
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: const Color(0xA8121218),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        w.prompt,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t(12, FontWeight.w400, const Color(0xFFA9A9B4)),
                      ),
                    ),
                  ),
                ),
                if (w.imgs.length > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 76,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < w.imgs.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == index ? 14 : 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: i == index
                                  ? C.p
                                  : Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RailBtn extends StatelessWidget {
  final HjGlyph glyph;
  final String label;
  final VoidCallback onTap;
  const _RailBtn({required this.glyph, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 64,
        child: Column(
          children: [
            Material(
              color: const Color(0x9E14141A),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: HjIcon(glyph, size: 20, color: C.on),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: t(10, FontWeight.w400, C.on)),
          ],
        ),
      );
}
