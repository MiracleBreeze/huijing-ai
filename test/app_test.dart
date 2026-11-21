import 'package:flutter/material.dart';

import 'package:huijing_ai/widgets/hj_icons.dart';
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

  testWidgets('设置页四个服务商都能点选', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: const Home()));
    await tester.pump();
    await tester.tap(find.text('设置').last);
    await tester.pumpAndSettle();
    for (final name in ['OpenAI 官方', '兼容网关', '免费测试', '火山方舟']) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(find.byType(HjIcon), findsWidgets);
    }
  });

  testWidgets('数量用下拉竖列，选完即生效', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: const Home()));
    await tester.pump();
    await tester.tap(find.byTooltip('生成参数').first);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    expect(find.byType(DropdownMenu<int>), findsOneWidget);
    await tester.tap(find.byType(DropdownMenu<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3 张').last);
    await tester.pumpAndSettle();
    expect(app.settings.count, 3);
    expect(find.byType(DropdownMenu<int>), findsOneWidget);
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

// provider 切换回归
