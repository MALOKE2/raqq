import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// ينسخ ملف PDF من أصول التطبيق إلى مجلد مستندات الجهاز لعرضه عبر flutter_pdfview.
class PdfAssetHelper {
  static Future<File> copyAssetToFile(String assetName) async {
    final ByteData data = await rootBundle.load(assetName);
    final List<int> bytes = data.buffer.asUint8List();
    final dir = await getApplicationDocumentsDirectory();
    final fileName = assetName.split('/').last;
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
