/// يجعل النص المفكوك من PDF متتابعاً على الشاشة:
/// يحذف فواصل الأسطر التي كانت داخل الفقرة الواحدة (لأنها مجرد أسطر طباعة)،
/// ويحافظ على فواصل الفقرات الحقيقية (الأسطر الفارغة).
/// لا يغيّر أي كلمة من النص، بل يعيد ترتيب العرض فقط.
///
/// عند [preserveNumberedLists] يبدأ كل بند مرقّم (١-، ٢-، ...) في سطر جديد،
/// حتى لا تتداخل بنود التعداد مع الكلام الذي قبلها.
String flowArabicText(String raw, {bool preserveNumberedLists = false}) {
  final normalized = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  if (normalized.isEmpty) return '';

  final blocks = normalized.split(RegExp(r'\n\s*\n'));
  final paragraphs = <String>[];

  for (final block in blocks) {
    final lines = block
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) continue;

    var joined = lines.join(' ');
    if (preserveNumberedLists) {
      joined = joined.replaceAllMapped(
        RegExp(r'\s+([٠-٩]{1,2}\s*[-.)])'),
        (match) => '\n${match.group(1)}',
      );
    }
    paragraphs.add(joined);
  }

  return paragraphs.join('\n\n');
}
