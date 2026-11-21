import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/providers.dart';
import '../models.dart';
import '../services/media.dart';
import '../theme.dart';
import '../widgets/sheets.dart';
import '../widgets/hj_icons.dart';
import '../widgets/ui.dart';
import 'viewer_page.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final promptCtrl = TextEditingController();
  final focus = FocusNode();

  @override
  void initState() {
    super.initState();
    app.addListener(_refresh);
    promptCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    app.removeListener(_refresh);
    promptCtrl.dispose();
    focus.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _send() async {
    final text = promptCtrl.text.trim();
    if (text.isEmpty) return;
    focus.unfocus();
    if (app.settings.mode == 'chat') {
      promptCtrl.clear();
      await app.chatSend(text);
    } else {
      final w = await app.generate();
      if (w != null && mounted) {
        promptCtrl.clear();
      }
    }
  }

  void _openViewer(Work w, int i) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ViewerPage(
        work: w,
        start: i,
        onEdit: () {
          promptCtrl.text = w.prompt;
          app.useWork(w);
          setState(() {});
        },
        onAgain: () {
          app.regenFrom(w);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = app.settings;
    final chat = s.mode == 'chat';
    return Column(
      children: [
        Expanded(
          child: chat ? _chatBody() : _immersiveBody(),
        ),
        if (app.refs.isNotEmpty) _refsBar(),
        _inputBar(chat),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _empty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: CustomPaint(painter: _MarkPainter(big: true)),
            ),
            const SizedBox(height: 18),
            Text('今天想画点什么？', style: t(13, FontWeight.w400, C.out)),
          ],
        ),
      );

  Widget _immersiveBody() {
    final w = app.current;
    if (w == null || w.imgs.isEmpty) return _empty();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: PageView.builder(
        itemCount: w.imgs.length,
        itemBuilder: (c, i) => Center(
          child: GestureDetector(
            onTap: () => _openViewer(w, i),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(R.xl),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x66000000), blurRadius: 32, offset: Offset(0, 12)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: srcImage(w.imgs[i], fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chatBody() {
    if (app.chat.isEmpty) return _empty();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      itemCount: app.chat.length,
      itemBuilder: (c, i) {
        final m = app.chat[i];
        if (m.role == Role.user) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.only(top: 12, left: 40),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: C.p,
                borderRadius: BorderRadius.circular(R.l),
              ),
              child: Text(m.text,
                  style: t(13, FontWeight.w500, const Color(0xFF1A1A1E))),
            ),
          );
        }
        if (m.role == Role.typing) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(top: 12, right: 60),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: C.s1,
                borderRadius: BorderRadius.circular(R.l),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: C.accent),
                ),
                const SizedBox(width: 10),
                Text('正在生成…', style: t(12, FontWeight.w400, C.onv)),
              ]),
            ),
          );
        }
        if (m.error != null) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(top: 12, right: 40),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: C.s1,
                borderRadius: BorderRadius.circular(R.l),
              ),
              child: Text(m.error!, style: t(12, FontWeight.w400, C.err)),
            ),
          );
        }
        final w = m.work;
        if (w == null) return const SizedBox.shrink();
        return _aiBubble(w);
      },
    );
  }

  Widget _aiBubble(Work w) {
    final multi = w.imgs.length > 1 && app.settings.grid;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 12, right: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: C.s1,
          borderRadius: BorderRadius.circular(R.l),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (multi)
              SizedBox(
                width: 300,
                child: GridView.count(
                  crossAxisCount: w.imgs.length == 3 || w.imgs.length > 4 ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  children: [
                    for (var i = 0;
                        i < w.imgs.length.clamp(0, 6);
                        i++)
                      GestureDetector(
                        onTap: () => _openViewer(w, i),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(R.m),
                          child: srcImage(w.imgs[i], fit: BoxFit.cover),
                        ),
                      ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: () => _openViewer(w, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(R.m),
                  child: srcImage(w.imgs[0],
                      fit: BoxFit.cover,
                      width: 300,
                      height: 300),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _chatAct(HjGlyph.download, '保存',
                      () async => _toast(await Media.saveImage(w.imgs[0]))),
                  _chatAct(HjGlyph.edit, '重新编辑', () {
                    promptCtrl.text = w.prompt;
                    app.useWork(w);
                    setState(() {});
                  }),
                  _chatAct(HjGlyph.spark, '再次生成',
                      () => app.regenFrom(w)),
                  _chatAct(HjGlyph.share, '分享',
                      () => Media.shareImage(w.imgs[0], w.prompt)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(providerById(w.provider).name,
                      style: t(10.5, FontWeight.w400, C.out)),
                  const SizedBox(width: 8),
                  Text(w.model, style: t(10.5, FontWeight.w400, C.onv)),
                  const SizedBox(width: 8),
                  Text(w.ratio, style: t(10.5, FontWeight.w400, C.out)),
                  const SizedBox(width: 8),
                  Text('${w.imgs.length} 张', style: t(10.5, FontWeight.w400, C.out)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatAct(HjGlyph glyph, String tip, VoidCallback tap) => IconButton(
        onPressed: tap,
        tooltip: tip,
        icon: HjIcon(glyph, size: 18, color: C.onv),
        style: IconButton.styleFrom(
          minimumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: C.onv,
        ),
      );

  void _toast(String s) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(s, style: t(12.5, FontWeight.w400, C.on)),
        backgroundColor: C.s3,
        behavior: SnackBarBehavior.floating,
      ));
  }

  Widget _refsBar() => SizedBox(
        height: 56,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            for (var i = 0; i < app.refs.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(R.m),
                      child: srcImage(app.refs[i], width: 48, height: 48),
                    ),
                    Positioned(
                      right: -2,
                      top: -2,
                      child: GestureDetector(
                        onTap: () => app.removeRef(i),
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                              color: C.s4, shape: BoxShape.circle),
                          child: const HjIcon(HjGlyph.close,
                              size: 12, color: C.onv),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );

  Widget _inputBar(bool chat) {
    final has = promptCtrl.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: C.s1,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: '参考图',
              onPressed: () async {
                final d = await Media.pickImage();
                if (d != null) app.addRef(d);
              },
              style: IconButton.styleFrom(
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: C.out,
              ),
              icon: const HjIcon(HjGlyph.image, size: 20),
            ),
            Expanded(
              child: TextField(
                controller: promptCtrl,
                focusNode: focus,
                minLines: 1,
                maxLines: 4,
                textAlignVertical: TextAlignVertical.center,
                style: t(13),
                decoration: InputDecoration(
                  hintText: '描述画面…',
                  filled: false,
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintStyle: t(13, FontWeight.w400, C.out),
                ),
              ),
            ),
            IconButton(
              tooltip: '生成参数',
              onPressed: () => showParamsSheet(context),
              style: IconButton.styleFrom(
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: C.out,
              ),
              icon: const HjIcon(HjGlyph.sliders, size: 20),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 36,
              height: 36,
              child: FilledButton(
                onPressed: has ? _send : null,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  backgroundColor: has ? C.p : C.s3,
                  foregroundColor: has ? C.onP : C.out,
                  disabledBackgroundColor: C.s3,
                  disabledForegroundColor: C.out,
                  minimumSize: const Size(36, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const HjIcon(HjGlyph.arrowRight, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _MarkPainter extends CustomPainter {
  final bool big;
  _MarkPainter({this.big = false});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = big ? 2 : 2.4
      ..color = const Color(0xFF9A9AA6);
    canvas.drawCircle(c.translate(-r * 0.18, 0), r * 0.62, ring);
    final dot = Paint()..color = C.accent;
    canvas.drawCircle(c.translate(r * 0.3, 0), big ? r * 0.22 : r * 0.26, dot);
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) => old.big != big;
}
