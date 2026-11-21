import 'package:flutter/material.dart';

/// 绘境 AI · ShadSlate 中立深色体系
class C {
  static const s = Color(0xFF0A0A0C);
  static const s1 = Color(0xFF121216);
  static const s2 = Color(0xFF17171C);
  static const s3 = Color(0xFF1E1E24);
  static const s4 = Color(0xFF2A2A32);
  static const on = Color(0xFFECECEF);
  static const onv = Color(0xFFA0A0AB);
  static const out = Color(0xFF6E6E7A);
  static const outv = Color(0xFF2A2A33);
  static const p = Color(0xFFEDEDF0);
  static const onP = Color(0xFF0A0A0C);
  static const accent = Color(0xFFA78BFA);
  static const err = Color(0xFFFF6B81);
}

class R {
  static const s = 6.0;
  static const m = 8.0;
  static const l = 12.0;
  static const xl = 16.0;
  static const xxl = 20.0;
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final scheme = ColorScheme.fromSeed(
    seedColor: C.accent,
    brightness: Brightness.dark,
  ).copyWith(
    primary: C.accent,
    surface: C.s1,
    onSurface: C.on,
    surfaceTint: Colors.transparent,
  );
  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: C.s,
    canvasColor: C.s,
    splashFactory: InkSparkle.splashFactory,
    textTheme: base.textTheme.apply(
      bodyColor: C.on,
      displayColor: C.on,
    ),
    iconTheme: const IconThemeData(color: C.onv, size: 20),
    dividerColor: Colors.transparent,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.s1,
      hintStyle: const TextStyle(color: C.out, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.l),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

TextStyle t(num size, [FontWeight w = FontWeight.w400, Color color = C.on]) =>
    TextStyle(fontSize: size.toDouble(), fontWeight: w, color: color, height: 1.35);
