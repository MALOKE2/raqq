import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';
import '../core/text_layout.dart';

/// شاشة عرض محتوى نصي مفكوك من ملف (كما هو بدون تغيير) بواجهة بسيطة وخط ملائم.
class SimpleContentScreen extends StatefulWidget {
  final String title;
  final String assetPath;
  final String? subtitle;

  const SimpleContentScreen({
    super.key,
    required this.title,
    required this.assetPath,
    this.subtitle,
  });

  @override
  State<SimpleContentScreen> createState() => _SimpleContentScreenState();
}

class _SimpleContentScreenState extends State<SimpleContentScreen> {
  late final Future<String> _textFuture;

  @override
  void initState() {
    super.initState();
    _textFuture = rootBundle.loadString(widget.assetPath).then(flowArabicText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<String>(
        future: _textFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'تعذّر تحميل المحتوى، يرجى المحاولة لاحقاً.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 18),
                ),
              ),
            );
          }
          final text = snapshot.data!.trim();
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                    Text(
                      widget.subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 15,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                  ],
                  SelectableText(
                    text,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18.5,
                      height: 1.7,
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w500,
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
