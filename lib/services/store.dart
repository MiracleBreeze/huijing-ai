import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import '../services/api.dart';

class AppState extends ChangeNotifier {
  static const _kSettings = 'hj.settings.v1';
  static const _kWorks = 'hj.works.v1';
  static const _kChat = 'hj.chat.v1';

  AppSettings settings = AppSettings();
  List<Work> works = [];
  List<ChatMsg> chat = [];
  List<String> refs = [];
  Work? current;

  bool busy = false;
  String stage = '正在理解提示词…';
  int elapsed = 0;
  String? lastError;

  Timer? _tick;
  bool _cancel = false;

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kSettings);
    if (s != null) {
      try {
        settings = AppSettings.fromJson(jsonDecode(s) as Map<String, dynamic>);
      } catch (_) {}
    }
    final w = sp.getString(_kWorks);
    if (w != null) {
      try {
        works = (jsonDecode(w) as List)
            .map((e) => Work.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      } catch (_) {}
    }
    final c = sp.getString(_kChat);
    if (c != null) {
      try {
        chat = (jsonDecode(c) as List)
            .map((e) => ChatMsg.fromJson((e as Map).cast<String, dynamic>()))
            .toList();
      } catch (_) {}
    }
    current = works.isNotEmpty ? works.first : null;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kSettings, jsonEncode(settings.toJson()));
  }

  Future<void> _saveWorks() async {
    final sp = await SharedPreferences.getInstance();
    final trimmed = works.take(30).toList();
    await sp.setString(
        _kWorks, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
  }

  Future<void> _saveChat() async {
    final sp = await SharedPreferences.getInstance();
    final trimmed = chat.length > 60 ? chat.sublist(chat.length - 60) : chat;
    await sp.setString(
        _kChat, jsonEncode(trimmed.map((e) => e.toJson()).toList()));
  }

  void setSettings(AppSettings s) {
    settings = s;
    _saveSettings();
    notifyListeners();
  }

  void setMode(String m) {
    settings.mode = m;
    _saveSettings();
    notifyListeners();
  }

  void setRatio(String r) {
    settings.ratio = r;
    _saveSettings();
    notifyListeners();
  }

  void setResolution(String r) {
    settings.resolution = r;
    _saveSettings();
    notifyListeners();
  }

  void setCount(int n) {
    settings.count = n.clamp(1, 10);
    _saveSettings();
    notifyListeners();
  }

  void toggleGrid() {
    settings.grid = !settings.grid;
    _saveSettings();
    notifyListeners();
  }

  void toggleWatermark() {
    settings.watermark = !settings.watermark;
    _saveSettings();
    notifyListeners();
  }

  void setProvider(String id) {
    settings.providerId = id;
    _saveSettings();
    notifyListeners();
  }

  void setBase(String v) {
    settings.bases[settings.providerId] = v;
    _saveSettings();
    notifyListeners();
  }

  void setKey(String v) {
    settings.keys[settings.providerId] = v;
    _saveSettings();
    notifyListeners();
  }

  void setModel(String v) {
    settings.picked[settings.providerId] = v;
    _saveSettings();
    notifyListeners();
  }

  void setModelList(List<String> list) {
    settings.models[settings.providerId] = list;
    notifyListeners();
  }

  void setPolishTier(String t) {
    settings.polishTier = t;
    _saveSettings();
    notifyListeners();
  }

  void addRef(String dataUri) {
    if (refs.length >= 4) return;
    refs = [...refs, dataUri];
    notifyListeners();
  }

  void removeRef(int i) {
    refs = [...refs]..removeAt(i);
    notifyListeners();
  }

  void useWork(Work w) {
    current = w;
    notifyListeners();
  }

  Future<List<String>> fetchModels() async {
    final list = await Api.fetchModels(settings);
    setModelList(list);
    return list;
  }

  Future<Work?> generate({String? promptOverride}) async {
    final prompt = (promptOverride ?? '').trim();
    if (prompt.isEmpty) {
      lastError = '先写一句想画什么';
      notifyListeners();
      return null;
    }
    if (settings.provider.needsKey && settings.key().trim().isEmpty) {
      lastError = '这个服务商要先填 API Key';
      notifyListeners();
      return null;
    }
    if (settings.model().isEmpty) {
      lastError = '先选一个模型';
      notifyListeners();
      return null;
    }

    _cancel = false;
    busy = true;
    elapsed = 0;
    stage = '正在理解提示词…';
    lastError = null;
    notifyListeners();
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed += 1;
      if (elapsed == 3) stage = '正在构图…';
      if (elapsed == 8) stage = '正在细化细节…';
      notifyListeners();
    });

    try {
      final imgs = await Api.generate(
        settings: settings,
        prompt: prompt,
        refs: refs,
      );
      final w = Work(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        prompt: prompt,
        imgs: imgs,
        ratio: settings.ratio,
        provider: settings.providerId,
        model: settings.model(),
        createdAt: DateTime.now(),
        refs: [...refs],
      );
      if (_cancel) {
        busy = false;
        _tick?.cancel();
        notifyListeners();
        return null;
      }
      works.insert(0, w);
      current = w;
      busy = false;
      _tick?.cancel();
      await _saveWorks();
      notifyListeners();
      return w;
    } catch (e) {
      busy = false;
      _tick?.cancel();
      lastError = '$e'.replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// 对话模式：一轮回复
  Future<void> chatSend(String text) async {
    final prompt = text.trim();
    if (prompt.isEmpty) return;
    chat = [...chat, ChatMsg(role: Role.user, text: prompt)];
    chat = [...chat, ChatMsg(role: Role.typing)];
    notifyListeners();
    await _saveChat();

    final w = await generate(promptOverride: prompt);
    final rest = [...chat]..removeLast();
    if (w == null) {
      chat = [...rest, ChatMsg(role: Role.ai, error: lastError ?? '生成失败')];
    } else {
      chat = [...rest, ChatMsg(role: Role.ai, work: w)];
    }
    notifyListeners();
    await _saveChat();
  }

  Future<void> regenFrom(Work w) async {
    settings.ratio = w.ratio;
    settings.providerId = w.provider;
    settings.picked[w.provider] = w.model;
    _saveSettings();
    await generate(promptOverride: w.prompt);
  }

  void cancelGenerate() {
    _cancel = true;
    busy = false;
    _tick?.cancel();
    notifyListeners();
  }

  Future<void> deleteCurrent() async {
    if (current == null) return;
    works.removeWhere((e) => e.id == current!.id);
    current = works.isNotEmpty ? works.first : null;
    await _saveWorks();
    notifyListeners();
  }

  void clearAll() {
    works = [];
    chat = [];
    current = null;
    _saveWorks();
    _saveChat();
    notifyListeners();
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }
}

/// 本地润色：只修格式与语病，不加内容
String localPolish(String text) {
  var s = text.trim();
  s = s.replaceAll(RegExp(r'[ \t]+'), ' ');
  s = s.replaceAll(RegExp(r'\n{2,}'), '\n');
  s = s.replaceAll(RegExp(r'[，,]\s*[，,]'), '，');
  s = s.replaceAll('。', '。');
  s = s.replaceAll(RegExp(r'([，。！？、])\s+'), r'$1');
  s = s.replaceAll(RegExp(r'([\u4e00-\u9fa5])\s+([\u4e00-\u9fa5])'), r'$1$2');
  // 全角化常用标点
  s = s.replaceAll(',', '，').replaceAll(';', '；').replaceAll(':', '：');
  s = s.replaceAll('!', '！').replaceAll('?', '？');
  s = s.replaceAll('(', '（').replaceAll(')', '）');
  s = s.replaceAll(RegExp(r'\s*([，。！？；：、（）])\s*'), r'$1');
  if (!RegExp(r'[。！？]$').hasMatch(s)) s = '$s。';
  return s;
}

const kIdeaTemplates = [
  '雨夜的旧书店，暖黄窗光，湿漉漉的石板路，中景',
  '清晨的薄雾山谷，一座悬空的木桥，冷青色调，远景',
  '沙漠里的玻璃温室，内部长着发光植物，微距质感',
  '废弃车站的长椅，一束斜射阳光，尘埃可见，逆光',
  '海边的白色灯塔，涨潮的浪拍在礁石上，长曝光',
  '老式理发店的旋转灯柱，霓虹反光，夜间街头',
];

List<String> localIdeas(String seed) {
  final r = Random(seed.hashCode);
  final pool = [...kIdeaTemplates]..shuffle(r);
  return pool.take(3).toList();
}
