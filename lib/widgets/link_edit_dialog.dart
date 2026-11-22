import 'package:flutter/material.dart';

import '../models/contact_link.dart';

/// نافذة إضافة/تعديل رابط تواصل — تُرجع الرابط بعد الحفظ أو null عند الإلغاء.
Future<ContactLink?> showContactLinkDialog(
  BuildContext context, {
  ContactLink? link,
}) async {
  final labelCtrl = TextEditingController(text: link?.label ?? '');
  final urlCtrl = TextEditingController(text: link?.url ?? '');
  final iconCtrl = TextEditingController(text: link?.icon ?? 'Icons.link');
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(link == null ? 'إضافة رابط جديد' : 'تعديل الرابط'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: labelCtrl,
            decoration: const InputDecoration(
              labelText: 'اسم الرابط (مثل: واتساب، يوتيوب)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: urlCtrl,
            decoration: const InputDecoration(
              labelText: 'الرابط',
              hintText: 'https://...',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: iconCtrl,
            decoration: const InputDecoration(
              labelText: 'اسم الأيقونة (مثل: Icons.phone, Icons.youtube)',
              hintText: 'Icons.link',
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
  final label = labelCtrl.text.trim();
  final url = urlCtrl.text.trim();
  final icon = iconCtrl.text.trim().isEmpty ? 'Icons.link' : iconCtrl.text.trim();
  if (label.isEmpty || url.isEmpty) return null;
  return ContactLink(id: link?.id, label: label, url: url, icon: icon);
}
