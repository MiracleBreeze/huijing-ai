import 'dart:convert';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class Media {
  static Uint8List bytesOfDataUri(String src) {
    final comma = src.indexOf(',');
    final pure = src.startsWith('data:') && comma > 0
        ? src.substring(comma + 1)
        : src;
    return base64Decode(pure);
  }

  static Future<String?> pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (x == null) return null;
    final bytes = await x.readAsBytes();
    return 'data:image/jpeg;base64,${base64Encode(bytes)}';
  }

  /// 保存到系统相册，返回提示语
  static Future<String> saveImage(String dataUri, {String? name}) async {
    try {
      final bytes = bytesOfDataUri(dataUri);
      await Gal.putImageBytes(
        bytes,
        album: '绘境AI',
        name: name ?? 'huijing_${DateTime.now().millisecondsSinceEpoch}',
      );
      return '已保存到相册「绘境AI」';
    } catch (e) {
      return '保存失败：$e';
    }
  }

  static Future<void> shareImage(String dataUri, String text) async {
    final bytes = bytesOfDataUri(dataUri);
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: [
          XFile.fromData(
            bytes,
            name: 'huijing_${DateTime.now().millisecondsSinceEpoch}.png',
            mimeType: 'image/png',
          ),
        ],
      ),
    );
  }

  static Future<void> shareText(String text, {String? name}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: name));
  }
}
