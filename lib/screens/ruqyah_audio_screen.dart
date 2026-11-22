import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../services/database_service.dart';
import '../models/audio_shortcut.dart';

/// شاشة الرقى المسموعة — اختصارات يوتيوب مضافة يدويًا، عند الضغط على أي رقية
/// يتم فتح رابط اليوتيوب مباشرة في المتصفح الخارجي.
/// إدارة الاختصارات (إضافة/تعديل/حذف) تتم من لوحة المطور فقط.
class RuqyahAudioScreen extends StatefulWidget {
  const RuqyahAudioScreen({super.key});

  @override
  State<RuqyahAudioScreen> createState() => _RuqyahAudioScreenState();
}

class _RuqyahAudioScreenState extends State<RuqyahAudioScreen> {
  final _db = DatabaseService();
  List<AudioShortcut> _shortcuts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final shortcuts = await _db.getAudioShortcuts();
    if (!mounted) return;
    setState(() {
      _shortcuts = shortcuts;
      _isLoading = false;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح الرابط، تأكد من اتصالك بالإنترنت.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرقية المسموعة'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shortcuts.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.audiotrack,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'الرقى المسموعة عبر يوتيوب',
                                  style: TextStyle(
                                    color: AppTheme.textDark,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'اضغط على أي رقية لفتحها مباشرة في يوتيوب.',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _shortcuts.length,
                        itemBuilder: (context, index) {
                          final s = _shortcuts[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.red.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.red,
                                  size: 28,
                                ),
                              ),
                              title: Text(
                                s.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Text(
                                s.url,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(
                                Icons.open_in_new,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                              onTap: () => _openUrl(s.url),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_circle_outline,
                color: AppTheme.primary,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد اختصارات مضافة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'لم تُضف أي رقى مسموعة بعد.',
              style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
