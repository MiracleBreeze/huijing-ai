import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'screens/home.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await app.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: C.s,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const HuiJingApp());
}

class HuiJingApp extends StatelessWidget {
  const HuiJingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '绘境 AI',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const Home(),
    );
  }
}
