
import 'data/providers.dart';

class Work {
  final String id;
  final String prompt;
  final List<String> imgs;
  final String ratio;
  final String provider;
  final String model;
  final DateTime createdAt;
  final List<String> refs;

  Work({
    required this.id,
    required this.prompt,
    required this.imgs,
    required this.ratio,
    required this.provider,
    required this.model,
    required this.createdAt,
    this.refs = const [],
  });

  Work copyWith({String? prompt, List<String>? imgs}) => Work(
        id: id,
        prompt: prompt ?? this.prompt,
        imgs: imgs ?? this.imgs,
        ratio: ratio,
        provider: provider,
        model: model,
        createdAt: createdAt,
        refs: refs,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'imgs': imgs,
        'ratio': ratio,
        'provider': provider,
        'model': model,
        'createdAt': createdAt.toIso8601String(),
        'refs': refs,
      };

  static Work fromJson(Map<String, dynamic> j) => Work(
        id: j['id'] as String? ?? '',
        prompt: j['prompt'] as String? ?? '',
        imgs: (j['imgs'] as List?)?.cast<String>() ?? const [],
        ratio: j['ratio'] as String? ?? '1:1',
        provider: j['provider'] as String? ?? 'ark',
        model: j['model'] as String? ?? '',
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
        refs: (j['refs'] as List?)?.cast<String>() ?? const [],
      );
}

enum Role { user, ai, typing }

class ChatMsg {
  final Role role;
  final String text;
  final Work? work;
  final String? error;

  ChatMsg({required this.role, this.text = '', this.work, this.error});

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'text': text,
        'work': work?.toJson(),
        'error': error,
      };

  static ChatMsg fromJson(Map<String, dynamic> j) => ChatMsg(
        role: Role.values.firstWhere(
          (r) => r.name == (j['role'] as String? ?? 'ai'),
          orElse: () => Role.ai,
        ),
        text: j['text'] as String? ?? '',
        work: j['work'] == null
            ? null
            : Work.fromJson((j['work'] as Map).cast<String, dynamic>()),
        error: j['error'] as String?,
      );
}

class AppSettings {
  String mode; // immersive | chat
  String providerId;
  Map<String, String> bases;
  Map<String, String> keys;
  Map<String, List<String>> models;
  Map<String, String> picked;
  String ratio;
  String resolution;
  int count;
  bool watermark;
  bool grid;
  String polishTier;

  AppSettings({
    this.mode = 'immersive',
    this.providerId = 'ark',
    Map<String, String>? bases,
    Map<String, String>? keys,
    Map<String, List<String>>? models,
    Map<String, String>? picked,
    this.ratio = '1:1',
    this.resolution = '2K',
    this.count = 1,
    this.watermark = true,
    this.grid = true,
    this.polishTier = 'fix',
  })  : bases = bases ?? {for (final p in kProviders) p.id: p.base},
        keys = keys ?? {for (final p in kProviders) p.id: ''},
        models = models ?? {for (final p in kProviders) p.id: const []},
        picked = picked ?? {for (final p in kProviders) p.id: ''};

  ProviderSpec get provider => providerById(providerId);

  String base() => bases[providerId] ?? provider.base;
  String key() => keys[providerId] ?? '';
  List<String> liveModels() => models[providerId] ?? const [];
  String model() => picked[providerId] ?? '';

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'providerId': providerId,
        'bases': bases,
        'keys': keys,
        'models': models,
        'picked': picked,
        'ratio': ratio,
        'resolution': resolution,
        'count': count,
        'watermark': watermark,
        'grid': grid,
        'polishTier': polishTier,
      };

  static AppSettings fromJson(Map<String, dynamic> j) {
    Map<String, String> m(String k) =>
        (j[k] as Map?)?.map((a, b) => MapEntry(a.toString(), b.toString())) ??
        {};
    return AppSettings(
      mode: j['mode'] as String? ?? 'immersive',
      providerId: j['providerId'] as String? ?? 'ark',
      bases: m('bases'),
      keys: m('keys'),
      picked: m('picked'),
      models: (j['models'] as Map?)?.map(
            (a, b) => MapEntry(a.toString(), (b as List).cast<String>()),
          ) ??
          {},
      ratio: j['ratio'] as String? ?? '1:1',
      resolution: j['resolution'] as String? ?? '2K',
      count: (j['count'] as num?)?.toInt() ?? 1,
      watermark: j['watermark'] as bool? ?? true,
      grid: j['grid'] as bool? ?? true,
      polishTier: j['polishTier'] as String? ?? 'fix',
    );
  }
}

class RatioSpec {
  final String label;
  final String name;
  final double w;
  final double h;
  const RatioSpec(this.label, this.name, this.w, this.h);
}

const kRatios = [
  RatioSpec('1:1', '方形', 1, 1),
  RatioSpec('4:3', '横向', 4, 3),
  RatioSpec('3:4', '纵向', 3, 4),
  RatioSpec('16:9', '宽屏', 16, 9),
  RatioSpec('9:16', '竖屏', 9, 16),
  RatioSpec('3:2', '摄影', 3, 2),
  RatioSpec('2:3', '海报', 2, 3),
  RatioSpec('21:9', '宽银幕', 21, 9),
];

const kResolutions = ['1K', '2K', '4K'];

String sizeFor(String ratio, String resolution) {
  final spec = kRatios.firstWhere((r) => r.label == ratio,
      orElse: () => kRatios.first);
  final long = switch (resolution) { '1K' => 1024, '4K' => 2048, _ => 1536 };
  final landscape = spec.w >= spec.h;
  final w = landscape ? long : (long * spec.w / spec.h).round();
  final h = landscape ? (long * spec.h / spec.w).round() : long;
  return '${(w ~/ 8) * 8}x${(h ~/ 8) * 8}';
}

String ratioFromSize(String size) {
  final parts = size.split('x');
  if (parts.length != 2) return '1:1';
  final w = int.tryParse(parts[0]) ?? 1;
  final h = int.tryParse(parts[1]) ?? 1;
  RatioSpec best = kRatios.first;
  var delta = 1e9;
  for (final r in kRatios) {
    final d = (r.w / r.h - w / h).abs();
    if (d < delta) {
      delta = d;
      best = r;
    }
  }
  return best.label;
}

/// 图片统一用 data URI（data:image/...;base64,...）或 http(s) 地址
bool isRemote(String src) => src.startsWith('http');

bool isData(String src) => src.startsWith('data:');
