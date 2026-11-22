import 'package:flutter/material.dart';

import '../models/audio_shortcut.dart';

/// نافذة إضافة/تعديل اختصار رقية مسموعة (يوتيوب).
Future<AudioShortcut?> showAudioShortcutDialog(
  BuildContext context, {
  AudioShortcut? shortcut,
}) async {
  final titleCtrl = TextEditingController(text: shortcut?.title ?? '');
  final urlCtrl = TextEditingController(text: shortcut?.url ?? '');
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
          shortcut == null ? 'إضافة اختصار جديد' : 'تعديل الاختصار'),
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
  if (saved != true) return null;
  final title = titleCtrl.text.trim();
  final url = urlCtrl.text.trim();
  if (title.isEmpty || url.isEmpty) return null;
  return AudioShortcut(id: shortcut?.id, title: title, url: url);
}
