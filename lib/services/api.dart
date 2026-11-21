import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models.dart';

class Api {
  static Map<String, String> _headers(AppSettings s) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (s.key().trim().isNotEmpty) {
      h['Authorization'] = 'Bearer ${s.key().trim()}';
    }
    return h;
  }

  static Uri _join(String base, String path) =>
      Uri.parse('${base.replaceAll(RegExp(r'/+$'), '')}$path');

  static Future<List<String>> fetchModels(AppSettings s) async {
    if (s.provider.protocol == 'poll') {
      final r = await http.get(Uri.parse(
          'https://image.pollinations.ai/models'));
      if (r.statusCode >= 400) {
        throw Exception('拉取模型失败 ${r.statusCode}');
      }
      final j = jsonDecode(r.body);
      final list = (j is List ? j : (j['data'] as List? ?? []))
          .map((e) => e is String ? e : (e['id'] ?? e['name']).toString())
          .where((e) => e.isNotEmpty)
          .toList();
      if (list.isEmpty) throw Exception('接口没有返回模型');
      return list;
    }

    final r = await http.get(_join(s.base(), '/models'), headers: _headers(s));
    if (r.statusCode >= 400) {
      throw Exception(r.statusCode == 401
          ? 'Key 无效或没有 /models 权限'
          : '拉取模型失败 ${r.statusCode}');
    }
    final j = jsonDecode(r.body);
    final list = (j['data'] as List? ?? [])
        .map((e) => (e['id'] ?? '').toString())
        .where((e) => e.isNotEmpty)
        .toList();
    if (list.isEmpty) throw Exception('接口没有返回模型');
    return list;
  }

  static Future<List<String>> generate({
    required AppSettings settings,
    required String prompt,
    List<String> refs = const [],
  }) async {
    if (settings.provider.protocol == 'poll') {
      return _poll(settings, prompt);
    }
    final body = <String, dynamic>{
      'model': settings.model(),
      'prompt': prompt,
      'n': settings.count,
      'size': sizeFor(settings.ratio, settings.resolution),
      'response_format': 'b64_json',
    };
    if (settings.provider.protocol == 'ark') {
      body['watermark'] = settings.watermark;
    }
    if (refs.isNotEmpty) {
      body['image'] = refs.take(1).toList();
    }

    final r = await http.post(
      _join(settings.base(), '/images/generations'),
      headers: _headers(settings),
      body: jsonEncode(body),
    );
    if (r.statusCode >= 400) throw Exception(_err(r));

    final j = jsonDecode(utf8.decode(r.bodyBytes));
    final data = (j['data'] as List? ?? []);
    if (data.isEmpty) throw Exception('接口没有返回图片');

    final out = <String>[];
    for (final item in data) {
      final b64 = (item['b64_json'] ?? '') as String;
      if (b64.isNotEmpty) {
        out.add('data:image/png;base64,$b64');
        continue;
      }
      final url = (item['url'] ?? '') as String;
      if (url.isNotEmpty) {
        out.add(await _download(url, settings));
      }
    }
    if (out.isEmpty) throw Exception('接口没有返回可用的图片');
    return out;
  }

  static Future<List<String>> _poll(AppSettings s, String prompt) async {
    final size = sizeFor(s.ratio, s.resolution);
    final parts = size.split('x');
    final model = s.model().isEmpty ? 'sana' : s.model();
    final uri = Uri.parse(
        'https://image.pollinations.ai/prompt/${Uri.encodeComponent(prompt)}')
        .replace(queryParameters: {
      'width': parts.first,
      'height': parts.last,
      'model': model,
      'seed': '${DateTime.now().millisecondsSinceEpoch % 999983}',
      'nologo': 'true',
      'private': 'true',
    });
    final out = <String>[];
    for (var i = 0; i < s.count; i++) {
      final r = await http.get(uri);
      if (r.statusCode >= 400) throw Exception('生成失败 ${r.statusCode}');
      out.add(_toDataUri(r.bodyBytes, r.headers['content-type']));
    }
    return out;
  }

  static Future<String> _download(String url, AppSettings s) async {
    final r = await http.get(Uri.parse(url), headers: {
      if (s.key().trim().isNotEmpty) 'Authorization': 'Bearer ${s.key().trim()}',
    });
    if (r.statusCode >= 400) throw Exception('下载图片失败 ${r.statusCode}');
    return _toDataUri(r.bodyBytes, r.headers['content-type']);
  }

  static String _toDataUri(Uint8List bytes, String? type) {
    final mime = (type ?? 'image/png').split(';').first;
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  static String _err(http.Response r) {
    try {
      final j = jsonDecode(utf8.decode(r.bodyBytes));
      final msg = (j['error']?['message'] ?? j['message'] ?? '').toString();
      if (msg.isNotEmpty) return msg;
    } catch (_) {}
    return '生成失败 ${r.statusCode}';
  }

  /// 助手用的对话接口；失败时由上层回落到本地规则
  static Future<String> chat({
    required AppSettings settings,
    required String system,
    required String user,
    double temperature = 0.7,
  }) async {
    if (settings.provider.protocol == 'poll') {
      throw Exception('免费通道没有对话能力');
    }
    final r = await http.post(
      _join(settings.base(), '/chat/completions'),
      headers: _headers(settings),
      body: jsonEncode({
        'model': settings.model(),
        'messages': [
          {'role': 'system', 'content': system},
          {'role': 'user', 'content': user},
        ],
        'temperature': temperature,
      }),
    );
    if (r.statusCode >= 400) throw Exception(_err(r));
    final j = jsonDecode(utf8.decode(r.bodyBytes));
    final content =
        (j['choices']?[0]?['message']?['content'] ?? '').toString().trim();
    if (content.isEmpty) throw Exception('模型没有返回内容');
    return content;
  }
}
