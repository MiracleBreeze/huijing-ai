import 'package:flutter/material.dart';

import '../app.dart';
import '../theme.dart';
import '../widgets/logo.dart';
import '../widgets/sheets.dart';
import 'create_page.dart';
import 'gallery_page.dart';
import 'settings_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;

  @override
  void initState() {
    super.initState();
    app.addListener(_refresh);
  }

  @override
  void dispose() {
    app.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  PreferredSizeWidget _appBar() {
    if (tab == 2) {
      return AppBar(
        toolbarHeight: 60,
        titleSpacing: 16,
        title: Text('设置', style: t(20, FontWeight.w600)),
      );
    }
    if (tab == 1) {
      return AppBar(
        toolbarHeight: 60,
        titleSpacing: 16,
        title: Text('作品', style: t(20, FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${app.works.length} 件',
                  style: t(11.5, FontWeight.w400, C.out)),
            ),
          ),
        ],
      );
    }
    final s = app.settings;
    return AppBar(
      toolbarHeight: 64,
      leadingWidth: 56,
      leading: const Padding(
        padding: EdgeInsets.only(left: 16),
        child: Center(child: LogoMark(size: 28)),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('绘境 AI', style: t(16, FontWeight.w600)),
          Text(
            '${s.provider.name} · ${s.model().isEmpty ? '未选择模型' : s.model()}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t(10.5, FontWeight.w400, C.out),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: s.mode == 'chat' ? '切到沉浸模式' : '切到对话模式',
          onPressed: () =>
              app.setMode(s.mode == 'chat' ? 'immersive' : 'chat'),
          icon: Icon(s.mode == 'chat'
              ? Icons.auto_awesome_mosaic_outlined
              : Icons.chat_bubble_outline_rounded),
        ),
        IconButton(
          tooltip: '生成参数',
          onPressed: () => showParamsSheet(context),
          icon: const Icon(Icons.tune_rounded),
        ),
        IconButton(
          tooltip: '设置',
          onPressed: () => setState(() => tab = 2),
          icon: const Icon(Icons.image_outlined),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.s,
      appBar: _appBar(),
      body: Stack(
        children: [
          IndexedStack(
            index: tab,
            children: const [CreatePage(), GalleryPage(), SettingsPage()],
          ),
          if (app.busy) const _Loading(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: '创作'),
          NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: '作品'),
          NavigationDestination(
              icon: Icon(Icons.tune_outlined),
              selectedIcon: Icon(Icons.tune_rounded),
              label: '设置'),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final p = app.settings.provider;
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0x8C000000),
        child: Center(
          child: Container(
            width: 232,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: C.s1,
              borderRadius: BorderRadius.circular(R.xl),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 40,
                    offset: Offset(0, 16)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: C.accent),
                ),
                const SizedBox(height: 14),
                Text(app.stage,
                    textAlign: TextAlign.center,
                    style: t(13.5, FontWeight.w500, C.on)),
                const SizedBox(height: 4),
                Text(
                  '${p.name} · ${app.settings.model()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t(11, FontWeight.w400, C.out),
                ),
                const SizedBox(height: 10),
                Text('已用 ${app.elapsed}s',
                    style: t(11, FontWeight.w400, C.out)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
