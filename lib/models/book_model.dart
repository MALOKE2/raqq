import 'dart:io';

class BookModel {
  final int? id;
  final String title;
  final String author;
  final String type; // "مؤلفات الراقي" | "كتب أخرى"
  final String description;
  final String keywords;
  final String pdfAsset; // مسار الأصول (مثال: assets/pdf/books/ajra_al_raqi.pdf)
  final String? pdfPath; // مسار الملف على التخزين الداخلي للجهاز (للملفات المصدرة/المستوردة)
  final String? coverPath; // مسار صورة الغلاف على التخزين الداخلي
  final String? coverAsset; // مسار صورة الغلاف المضمّنة في أصول التطبيق

  BookModel({
    this.id,
    required this.title,
    required this.author,
    required this.type,
    required this.description,
    required this.keywords,
    required this.pdfAsset,
    this.pdfPath,
    this.coverPath,
    this.coverAsset,
  });

  /// هل يوجد ملف PDF داخلي فعلي على الجهاز؟
  bool get hasLocalPdf {
    final p = pdfPath;
    if (p == null || p.isEmpty) return false;
    try {
      return File(p).existsSync();
    } catch (_) {
      return false;
    }
  }

  /// هل يوجد ملف PDF مضمّن في أصول التطبيق؟
  bool get hasAssetPdf => pdfAsset.startsWith('assets/');

  /// هل يمكن عرض الكتاب داخل التطبيق؟
  bool get canOpenPdf => hasLocalPdf || hasAssetPdf;

  /// هل يوجد غلاف مضمّن في أصول التطبيق؟
  bool get hasCoverAsset {
    final a = coverAsset;
    return a != null && a.isNotEmpty && a.startsWith('assets/');
  }

  /// هل يوجد غلاف موجود فعلاً على الجهاز؟
  bool get hasCoverFile {
    final p = coverPath;
    if (p == null || p.isEmpty) return false;
    try {
      return File(p).existsSync();
    } catch (_) {
      return false;
    }
  }

  /// هل يوجد غلاف (ملف محلي أو أصل مضمّن)؟
  bool get hasCover => hasCoverFile || hasCoverAsset;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'type': type,
      'description': description,
      'keywords': keywords,
      'pdf_asset': pdfAsset,
      'pdf_path': pdfPath,
      'cover_path': coverPath,
    };
  }

  factory BookModel.fromMap(Map<String, Object?> map) {
    return BookModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      type: map['type'] as String? ?? '',
      description: map['description'] as String? ?? '',
      keywords: map['keywords'] as String? ?? '',
      pdfAsset: map['pdf_asset'] as String? ?? '',
      pdfPath: map['pdf_path'] as String?,
      coverPath: map['cover_path'] as String?,
      coverAsset: map['cover_asset'] as String?,
    );
  }
}
