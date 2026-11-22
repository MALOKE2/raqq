import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../core/text_layout.dart';

/// شاشة الرقية المكتوبة — تشمل الرقى النصية المفكوكة سابقاً
/// والآيات التي أُضيفت من ملفات PDF (آيات/ايات) بصيغة نص،
/// مع الحفاظ على نفس تصميم وخط القسم قدر الإمكان.
class RuqyahWrittenScreen extends StatefulWidget {
  const RuqyahWrittenScreen({super.key});

  @override
  State<RuqyahWrittenScreen> createState() => _RuqyahWrittenScreenState();
}

class _RuqyahItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String assetPath;

  const _RuqyahItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.assetPath,
  });
}

class _RuqyahWrittenScreenState extends State<RuqyahWrittenScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isNightMode = false;

  static const List<_RuqyahItem> _items = [
    _RuqyahItem(
      title: 'آيات العين والحسد',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/ruqyah/ayn.txt',
      icon: Icons.remove_red_eye_outlined,
    ),
    _RuqyahItem(
      title: 'الرقية الكاملة',
      subtitle: 'الرقية الشرعية الكاملة',
      assetPath: 'assets/ruqyah/kamila.txt',
      icon: Icons.auto_awesome_outlined,
    ),
    _RuqyahItem(
      title: 'آيات السحر',
      subtitle: 'آيات وأدعية لإبطال السحر بإذن الله',
      assetPath: 'assets/ruqyah/sihir.txt',
      icon: Icons.shield_outlined,
    ),
    _RuqyahItem(
      title: 'آيات الشفاء والسكينة',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/roq_text/ayat_shifa_sakina.txt',
      icon: Icons.menu_book_outlined,
    ),
    _RuqyahItem(
      title: 'آيات التنزيل',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/roq_text/ayat_tanzil.txt',
      icon: Icons.menu_book_outlined,
    ),
    _RuqyahItem(
      title: 'آيات الخروج',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/roq_text/ayat_khuruj.txt',
      icon: Icons.menu_book_outlined,
    ),
    _RuqyahItem(
      title: 'آيات الطير',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/roq_text/ayat_tayr.txt',
      icon: Icons.menu_book_outlined,
    ),
    _RuqyahItem(
      title: 'آيات الظلم',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/roq_text/ayat_zulm.txt',
      icon: Icons.menu_book_outlined,
    ),
    _RuqyahItem(
      title: 'آيات العذاب',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/roq_text/ayat_azab.txt',
      icon: Icons.menu_book_outlined,
    ),
    _RuqyahItem(
      title: 'آيات القبور',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/roq_text/ayat_qubur.txt',
      icon: Icons.menu_book_outlined,
    ),
    _RuqyahItem(
      title: 'آيات الكواكب والنجوم',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/roq_text/ayat_kawakib_nujum.txt',
      icon: Icons.menu_book_outlined,
    ),
    _RuqyahItem(
      title: 'آيات تثبيت الحمل',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/roq_text/ayat_tathbit_haml.txt',
      icon: Icons.menu_book_outlined,
    ),
    _RuqyahItem(
      title: 'آيات ذم الفاحشة',
      subtitle: 'آيات وأدعية من الكتاب والسنة',
      assetPath: 'assets/roq_text/ayat_dhamm_fahisha.txt',
      icon: Icons.menu_book_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _items.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNight = _isNightMode;
    final bg = isNight ? const Color(0xFF14110E) : const Color(0xFFFDFCF8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'الرقية المكتوبة',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: isNight ? 'الوضع النهاري' : 'الوضع الليلي',
            icon: Icon(
              isNight ? Icons.brightness_7 : Icons.brightness_4,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _isNightMode = !_isNightMode),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppTheme.accent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
          unselectedLabelStyle:
              const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          tabs: _items
              .map((b) => Tab(icon: Icon(b.icon, size: 18), text: b.title))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _items
            .map(
              (b) => _TextBookReader(
                key: ValueKey(b.assetPath),
                item: b,
                isNight: isNight,
                bg: bg,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final _RuqyahItem item;
  final bool isNight;

  const _SectionHeader({required this.item, required this.isNight});

  @override
  Widget build(BuildContext context) {
    final panel = isNight ? const Color(0xFF1E1A16) : const Color(0xFFF5EFDF);
    final divider = isNight ? const Color(0xFF3A332C) : const Color(0xFFE3DCCB);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: panel,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            children: [
              Icon(item.icon, color: AppTheme.accent, size: 26),
              const SizedBox(height: 6),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color:
                      isNight ? const Color(0xFFF3E9D7) : AppTheme.primaryDark,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13,
                  color:
                      isNight ? const Color(0xFFB8AB8F) : AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                width: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppTheme.accent.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: divider),
      ],
    );
  }
}

class _TextBookReader extends StatefulWidget {
  final _RuqyahItem item;
  final bool isNight;
  final Color bg;

  const _TextBookReader({
    super.key,
    required this.item,
    required this.isNight,
    required this.bg,
  });

  @override
  State<_TextBookReader> createState() => _TextBookReaderState();
}

class _TextBookReaderState extends State<_TextBookReader> {
  late Future<String> _textFuture;

  @override
  void initState() {
    super.initState();
    _textFuture = rootBundle
        .loadString(widget.item.assetPath)
        .then((text) => flowArabicText(text));
  }

  @override
  Widget build(BuildContext context) {
    final isNight = widget.isNight;
    final bg = widget.bg;
    final ink = isNight ? const Color(0xFFEDE3D2) : const Color(0xFF2B241C);
    final marker = isNight ? const Color(0xFFD8C7A6) : const Color(0xFF8A6D3B);
    final divider = isNight ? const Color(0xFF3A332C) : const Color(0xFFE3DCCB);

    return Container(
      color: bg,
      child: FutureBuilder<String>(
        future: _textFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'تعذّر تحميل محتوى الرقية، يرجى المحاولة لاحقاً.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ink, fontFamily: 'Amiri'),
                ),
              ),
            );
          }
          final fullText = snapshot.data!.trim();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(item: widget.item, isNight: isNight),
              Expanded(
                child: ListView(
                  key: PageStorageKey<String>(widget.item.assetPath),
                  padding: const EdgeInsets.fromLTRB(20, 14, 18, 36),
                  children: [
                    Text(
                      fullText,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 19.5,
                        height: 2.0,
                        color: ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: Divider(color: divider, endIndent: 12)),
                        Text(
                          'نسأل الله أن يشفي مرضانا ومرضى المسلمين',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: marker,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Expanded(child: Divider(color: divider, indent: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

