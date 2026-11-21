import 'package:flutter/material.dart';

import '../app.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'viewer_page.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final works = app.works;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Text('作品', style: t(22, FontWeight.w600)),
              const Spacer(),
              Text('${works.length} 件', style: t(11.5, FontWeight.w400, C.out)),
            ],
          ),
        ),
        Expanded(
          child: works.isEmpty
              ? Center(
                  child: Text('还没有作品，去创作页生成一张',
                      style: t(12.5, FontWeight.w400, C.out)),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: works.length,
                  itemBuilder: (c, i) {
                    final w = works[i];
                    return GestureDetector(
                      onTap: () => _open(context, w),
                      onLongPress: () => _delete(context, w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(R.l),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            srcImage(w.imgs.first, fit: BoxFit.cover),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Color(0xCC0A0A0C)],
                                  ),
                                ),
                                child: Text(
                                  w.prompt,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: t(11, FontWeight.w400, C.onv),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _open(BuildContext context, Work w) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ViewerPage(
        work: w,
        onAgain: () => app.regenFrom(w),
      ),
    ));
  }

  void _delete(BuildContext context, Work w) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: C.s2,
        title: Text('删除这件作品？', style: t(16, FontWeight.w600)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: Text('取消', style: t(12.5, FontWeight.w400, C.onv))),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text('删除', style: t(12.5, FontWeight.w500, C.err))),
        ],
      ),
    );
    if (ok == true) {
      app.works.removeWhere((e) => e.id == w.id);
      await app.deleteCurrent();
    }
  }
}
