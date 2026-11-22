import 'package:flutter/material.dart';

import '../core/adhkar_topics.dart';
import '../core/app_theme.dart';
import '../widgets/quick_scrubber.dart';
import 'pdf_viewer_screen.dart';

/// شاشة الأذكار (حصن المسلم) — عرض المواضيع مع بحث ذكي بالكلمات المفتاحية
/// وطرفية جانبية للتنقل السريع بين أسماء الأذكار.
class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scroll = ScrollController();
  String _query = '';
  bool _searchOpen = false;

  static String _norm(String s) {
    String t = s.toLowerCase();
    for (final c in 'ًٌٍَُِّْٰ'.split('')) {
      t = t.replaceAll(c, '');
    }
    t = t.replaceAll('إ', 'ا').replaceAll('أ', 'ا').replaceAll('آ', 'ا')
        .replaceAll('ؤ', 'و').replaceAll('ئ', 'ي').replaceAll('ة', 'ه')
        .replaceAll('ٱ', 'ا').replaceAll('ى', 'ي');
    return t.replaceAll(RegExp(r'\s+'), '');
  }

  /// مطابقة تقريبية: كلمة من البحث موجودة في العنوان، أو حروفه تظهر بالترتيب.
  static bool _matches(String title, String q) {
    if (q.isEmpty) return true;
    final t = _norm(title);
    final nq = _norm(q);
    if (t.contains(nq)) return true;
    final words = t.split(RegExp(r'[^ا-ي0-9]+')).where((w) => w.length >= 3);
    for (final w in words) {
      if (w.contains(nq) || nq.contains(w)) return true;
    }
    // تطابق بالترتيب (كلمة مقاربة)
    int i = 0;
    for (final ch in t.runes) {
      if (i < nq.length && ch == nq.runes.elementAt(i)) i++;
    }
    return i >= (nq.length * 0.7).round() && nq.length >= 3;
  }

  List<AdhkarTopic> get _filtered {
    if (_query.trim().isEmpty) return AdhkarTopics.topics;
    return AdhkarTopics.topics.where((t) => _matches(t.title, _query)).toList();
  }

  void _openTopic(BuildContext context, AdhkarTopic topic) {
    final page = (topic.startPage - 1).clamp(0, AdhkarTopics.totalPages - 1);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          title: topic.title,
          assetPath: AdhkarTopics.pdfAsset,
          defaultPage: page,
        ),
      ),
    );
  }

  void _openIndex(BuildContext context, List<AdhkarTopic> topics) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AdhkarIndexScreen(
          topics: topics,
          onSelect: (topic) => _openTopic(context, topic),
        ),
      ),
    );
  }

  void _scrollToIndex(int index, int count) {
    if (count <= 1) return;
    final max = _scroll.position.maxScrollExtent;
    _scroll.jumpTo(max * (index / (count - 1)).clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topics = _filtered;
    final showIndexCard = _query.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'بحث في الأذكار',
            icon: Icon(_searchOpen ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) {
                  _search.clear();
                  _query = '';
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primary, Color(0xFF147A64)],
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
                const SizedBox(height: 6),
                const Text(
                  'حصن المسلم',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'ابحث بكلمة مقاربة أو استخدم الطرفية للتنقل السريع',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontSize: 12.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (_searchOpen) _buildSearchBox(topics),
          Expanded(
            child: Stack(
              children: [
                ListView.separated(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(14, 12, 44, 12),
                  itemCount: topics.length + (showIndexCard ? 1 : 0),
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (showIndexCard && index == 0) {
                      return _indexCard(context, AdhkarTopics.topics);
                    }
                    final topicIndex = showIndexCard ? index - 1 : index;
                    if (topicIndex < 0 || topicIndex >= topics.length) return const SizedBox.shrink();
                    final topic = topics[topicIndex];
                    return _topicCard(topic, topicIndex + 1);
                  },
                ),
                if (topics.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: QuickScrubber(
                      count: topics.length,
                      color: AppTheme.accent,
                      label: (i) => _shortLabel(topics[i].title, i),
                      onScrub: (i) => _scrollToIndex(i, topics.length),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _shortLabel(String title, int index) {
    final t = title.replaceAll(RegExp(r'^(أذكار|دعاء|الدعاء)\s*'), '').trim();
    return t.isEmpty ? '${index + 1}' : (t.length > 12 ? '${t.substring(0, 12)}…' : t);
  }

  Widget _buildSearchBox(List<AdhkarTopic> results) {
    final query = _query.trim();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      color: AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            textDirection: TextDirection.rtl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'اكتب كلمة أو جزءاً من الدعاء…',
              prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppTheme.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppTheme.divider),
              ),
            ),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 15, color: AppTheme.accent),
                const SizedBox(width: 4),
                Text(
                  results.isEmpty ? 'لا توجد نتائج مطابقة' : 'كلمات مقترحة (${results.length})',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                reverse: true,
                itemCount: results.length > 12 ? 12 : results.length,
                separatorBuilder: (context, _) => const SizedBox(width: 6),
                itemBuilder: (context, i) {
                  final t = results[i];
                  return ActionChip(
                    avatar: const Icon(Icons.auto_stories, size: 14, color: AppTheme.primary),
                    label: Text(
                      t.title.length > 26 ? '${t.title.substring(0, 26)}…' : t.title,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () => _openTopic(context, t),
                    backgroundColor: AppTheme.accent.withValues(alpha: 0.14),
                    side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.4)),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _indexCard(BuildContext context, List<AdhkarTopic> topics) {
    return Card(
      elevation: 0,
      color: AppTheme.accent.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.55)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openIndex(context, topics),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.list_alt_rounded, color: AppTheme.primaryDark, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'الفهرس — كل أسماء الأذكار',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.primaryDark),
                ),
              ),
              Icon(Icons.chevron_left, color: AppTheme.primaryDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topicCard(AdhkarTopic topic, int number) {
    return Card(
      elevation: 0,
      color: AppTheme.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.divider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openTopic(context, topic),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 12.5),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  topic.title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    height: 1.35,
                  ),
                ),
              ),
              const Icon(Icons.chevron_left, color: AppTheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// شاشة الفهرس المدمجة.
class _AdhkarIndexScreen extends StatelessWidget {
  final List<AdhkarTopic> topics;
  final ValueChanged<AdhkarTopic> onSelect;

  const _AdhkarIndexScreen({required this.topics, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الفهرس'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(10, 6, 44, 6),
        itemCount: topics.length,
        separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.6, color: AppTheme.divider),
        itemBuilder: (context, index) {
          final topic = topics[index];
          return InkWell(
            onTap: () => onSelect(topic),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      topic.title,
                      style: const TextStyle(fontSize: 15.2, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
