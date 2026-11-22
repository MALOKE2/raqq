import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/database_service.dart';
import '../models/audio_shortcut.dart';

/// شاشة إدارة اختصارات الرقية المسموعة (يوتيوب) للمطور.
class AudioShortcutsManageScreen extends StatefulWidget {
  const AudioShortcutsManageScreen({super.key});

  @override
  State<AudioShortcutsManageScreen> createState() =>
      _AudioShortcutsManageScreenState();
}

class _AudioShortcutsManageScreenState
    extends State<AudioShortcutsManageScreen> {
  final _db = DatabaseService();
  List<AudioShortcut> _shortcuts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getAudioShortcuts();
    if (!mounted) return;
    setState(() {
      _shortcuts = list;
      _isLoading = false;
    });
  }

  Future<void> _addOrEdit({AudioShortcut? shortcut}) async {
    final titleCtrl = TextEditingController(text: shortcut?.title ?? '');
    final urlCtrl = TextEditingController(text: shortcut?.url ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(shortcut == null ? 'إضافة اختصار جديد' : 'تعديل الاختصار'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'اسم الرقية'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'رابط يوتيوب',
                hintText: 'https://www.youtube.com/...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (saved != true) return;
    final title = titleCtrl.text.trim();
    final url = urlCtrl.text.trim();
    if (title.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال الاسم والرابط'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      if (shortcut == null) {
        await _db.insertAudioShortcut(
          AudioShortcut(title: title, url: url),
        );
      } else {
        await _db.updateAudioShortcut(
          AudioShortcut(id: shortcut.id, title: title, url: url),
        );
      }
      _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الحفظ بنجاح'),
          backgroundColor: AppTheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الحفظ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _delete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الاختصار؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _db.deleteAudioShortcut(id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('إدارة اختصارات الصوت'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة اختصار', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shortcuts.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _shortcuts.length,
                  itemBuilder: (context, index) {
                    final s = _shortcuts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.red,
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
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppTheme.primary),
                              onPressed: () => _addOrEdit(shortcut: s),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _delete(s.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              color: AppTheme.primary,
              size: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد اختصارات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أضف اختصاراً جديداً بالاسم ورابط يوتيوب.',
              style: TextStyle(color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
