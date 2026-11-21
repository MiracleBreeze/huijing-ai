import 'package:flutter/material.dart';

import '../app.dart';
import '../theme.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.s,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            IndexedStack(
              index: tab,
              children: [
                CreatePage(onOpenSettings: () => setState(() => tab = 2)),
                const GalleryPage(),
                const SettingsPage(),
              ],
            ),
            if (app.busy) const _Loading(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: C.s,
          padding: const EdgeInsets.only(top: 2, bottom: 4),
          child: Row(
            children: [
              _tab(0, Icons.auto_awesome_outlined, '创作'),
              _tab(1, Icons.grid_view_rounded, '作品'),
              _tab(2, Icons.tune_rounded, '设置'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(int i, IconData icon, String label) {
    final on = tab == i;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => tab = i),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              Icon(icon, size: 22, color: on ? C.on : C.out),
              const SizedBox(height: 4),
              Text(label,
                  style: t(11, on ? FontWeight.w600 : FontWeight.w400,
                      on ? C.on : C.out)),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: on ? 18 : 0,
                height: 2,
                color: C.accent,
              ),
            ],
          ),
        ),
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
                BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 16)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF3A3A46)),
                      ),
                      const Icon(Icons.auto_awesome_rounded,
                          size: 18, color: C.accent),
                    ],
                  ),
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
                Text('已用 ${app.elapsed}s', style: t(11, FontWeight.w400, C.out)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
