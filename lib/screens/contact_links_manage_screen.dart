import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../services/database_service.dart';
import '../models/contact_link.dart';

/// شاشة إدارة روابط تواصل معنا للمطور.
class ContactLinksManageScreen extends StatefulWidget {
  const ContactLinksManageScreen({super.key});

  @override
  State<ContactLinksManageScreen> createState() =>
      _ContactLinksManageScreenState();
}

class _ContactLinksManageScreenState extends State<ContactLinksManageScreen> {
  final _db = DatabaseService();
  List<ContactLink> _links = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _db.getContactLinks();
    if (!mounted) return;
    setState(() {
      _links = list;
      _isLoading = false;
    });
  }

  Future<void> _addOrEdit({ContactLink? link}) async {
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
              decoration: const InputDecoration(labelText: 'اسم الرابط (مثل: واتساب، يوتيوب)'),
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
    if (saved != true) return;
    final label = labelCtrl.text.trim();
    final url = urlCtrl.text.trim();
    final icon = iconCtrl.text.trim().isEmpty ? 'Icons.link' : iconCtrl.text.trim();
    if (label.isEmpty || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال الاسم والرابط'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      if (link == null) {
        await _db.insertContactLink(
          ContactLink(label: label, url: url, icon: icon),
        );
      } else {
        await _db.updateContactLink(
          ContactLink(id: link.id, label: label, url: url, icon: icon),
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
        content: const Text('هل أنت متأكد من حذف هذا الرابط؟'),
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
      await _db.deleteContactLink(id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('إدارة روابط التواصل'),
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
        label: const Text('إضافة رابط', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _links.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _links.length,
                  itemBuilder: (context, index) {
                    final l = _links[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                          child: Icon(
                            l.toIconData(),
                            color: AppTheme.primary,
                          ),
                        ),
                        title: Text(
                          l.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Text(
                          l.url,
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
                              onPressed: () => _addOrEdit(link: l),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _delete(l.id!),
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
              Icons.link,
              color: AppTheme.primary,
              size: 50,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد روابط',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'أضف رابط تواصل جديد باسمه ورابطه.',
              style: TextStyle(color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
