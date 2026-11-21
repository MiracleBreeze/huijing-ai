import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:huijing_ai/app.dart';
import 'package:huijing_ai/models.dart';
import 'package:huijing_ai/screens/home.dart';
import 'package:huijing_ai/screens/viewer_page.dart';
import 'package:huijing_ai/theme.dart';

const _px =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await app.init();
    app.works = [
      Work(
        id: '1',
        prompt: '一只猫坐在窗台',
        imgs: const [_px],
        ratio: '1:1',
        provider: 'ark',
        model: 'm',
        createdAt: DateTime.now(),
      ),
    ];
    app.chat = [];
  });

  testWidgets('首页三栏与输入条', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: const Home()));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('绘境 AI'), findsOneWidget);
    expect(find.text('创作'), findsOneWidget);
    expect(find.text('作品'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('今天想画点什么？'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('看图页：全屏大图 + 右侧四个按钮', (tester) async {
    final w = app.works.first;
    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(),
      home: ViewerPage(work: w),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('1 / 1'), findsOneWidget);
    expect(find.text('分享'), findsOneWidget);
    expect(find.text('重新编辑'), findsOneWidget);
    expect(find.text('再次生成'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('一只猫坐在窗台'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
