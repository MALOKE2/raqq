import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../core/text_layout.dart';

/// شاشة النبذة (نبذة عن الراقي) — تُظهر كتابة الراقي مباشرةً
/// بخط أميري وبتصميم مريح، بدون عرض ملف PDF.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const String _assetPath = 'assets/ruqyah/about_raqi.txt';

  late final Future<String> _textFuture = _loadText();

  bool _isNightMode = false;

  @override
  Widget build(BuildContext context) {
    final isNight = _isNightMode;
    final bg = isNight ? const Color(0xFF14110E) : const Color(0xFFFDFCF8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'نبذة عن الراقي',
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
      ),
      body: Container(
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
                    'تعذّر تحميل نص النبذة، يرجى المحاولة لاحقاً.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isNight ? const Color(0xFFEDE3D2) : const Color(0xFF2B241C),
                      fontFamily: 'Amiri',
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            }

            final text = snapshot.data!;
            final ink = isNight ? const Color(0xFFEDE3D2) : const Color(0xFF2B241C);
            final marker = isNight ? const Color(0xFFD8C7A6) : const Color(0xFF8A6D3B);
            final divider =
                isNight ? const Color(0xFF3A332C) : const Color(0xFFE3DCCB);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 18, 28),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  decoration: BoxDecoration(
                    color: isNight ? const Color(0xFF1E1A16) : AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.person_outline, color: AppTheme.accent, size: 30),
                      const SizedBox(height: 6),
                      Text(
                        'نبذة عن الراقي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isNight
                              ? const Color(0xFFF3E9D7)
                              : AppTheme.primaryDark,
                          height: 1.3,
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
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: isNight ? const Color(0xFF1E1A16) : AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Text(
                    text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18.5,
                      height: 1.55,
                      color: ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(color: divider, endIndent: 12)),
                    Text(
                      'نسأل الله أن ينفع بهذا العمل ويجعله خالصاً لوجهه',
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
            );
          },
        ),
      ),
    );
  }

  Future<String> _loadText() async {
    final raw = await rootBundle.loadString(_assetPath);
    return flowArabicText(raw, preserveNumberedLists: true);
  }
}
