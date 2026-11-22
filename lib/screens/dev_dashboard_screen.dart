import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/dev_mode_service.dart';
import 'manage_books_screen.dart';
import 'audio_shortcuts_manage_screen.dart';
import 'contact_links_manage_screen.dart';

class DevDashboardScreen extends StatefulWidget {
  const DevDashboardScreen({super.key});

  @override
  State<DevDashboardScreen> createState() => _DevDashboardScreenState();
}

class _DevDashboardScreenState extends State<DevDashboardScreen> {
  final _dev = DevModeService.instance;
  bool _isLoading = true;
  Map<String, String> _deviceInfo = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _dev.init();
    final info = await _dev.getDeviceInfo();
    if (!mounted) return;
    setState(() {
      _deviceInfo = info;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await _dev.logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _goManageBooks() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManageBooksScreen()),
    );
  }

  Future<void> _goManageAudioShortcuts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AudioShortcutsManageScreen()),
    );
  }

  Future<void> _goManageContactLinks() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ContactLinksManageScreen()),
    );
  }

  Future<void> _showRuqyahPhoneDialog() async {
    final controller = TextEditingController(
      text: DevModeService.instance.ruqyahBookingPhone,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إدارة رقم الرقية للحجز'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أدخل رقم الرقية (واتساب) المستخدم لحجز الرقية المباشرة:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الرقية',
                hintText: '+9647700000000',
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
    if (confirmed != true) return;
    final phone = controller.text.trim();
    if (phone.isEmpty) return;
    await DevModeService.instance.setRuqyahBookingPhone(phone);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ رقم الرقية للحجز بنجاح'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Future<void> _changePassword() async {
    final current = TextEditingController();
    final newPass = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تغيير كلمة مرور المطور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور الحالية'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة'),
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
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await _dev.changePassword(current.text, newPass.text);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح'),
          backgroundColor: AppTheme.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('كلمة المرور الحالية غير صحيحة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إعادة تعيين كلمة المرور'),
        content: const Text('هل تريد إعادة تعيين كلمة مرور المطور إلى القيمة الافتراضية (mhnd1978)؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إعادة التعيين'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _dev.resetPassword();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إعادة تعيين كلمة المرور إلى: mhnd1978'),
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  Future<void> _backupDatabase() async {
    try {
      final path = await _dev.backupDatabase();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم النسخ الاحتياطي إلى:\n$path'),
          backgroundColor: AppTheme.primary,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل النسخ الاحتياطي: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreDatabase() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('استعادة نسخة احتياطية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('أدخل مسار ملف النسخة الاحتياطية (.db)'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'مسار الملف',
                hintText: '/storage/emulated/0/Documents/raqq_dev_backup/raqq_backup_....db',
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
            child: const Text('استعادة'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _dev.restoreDatabase(controller.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم استعادة النسخة الاحتياطية بنجاح'),
          backgroundColor: AppTheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الاستعادة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _clearAllBooks() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إعادة تعيين البيانات'),
        content: const Text('سيتم حذف جميع الكتب نهائياً. لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف الكل', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final deleted = await _dev.clearAllBooks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف $deleted كتاب'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الحذف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeviceInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('معلومات الجهاز والتطبيق'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _deviceInfo.entries
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${e.key}: ', style: const TextStyle(fontWeight: FontWeight.w700)),
                        Expanded(child: Text(e.value)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _devToolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 160,
      height: 210,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(
          'لوحة المطور',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: const Text(
              'نشيط',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'أدوات المطور',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'إدارة التطبيق والبيانات وكلمة المرور',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    alignment: WrapAlignment.center,
                    children: [
                      _devToolCard(
                        icon: Icons.library_books,
                        title: 'إدارة الكتب',
                        subtitle: 'إضافة وتعديل وحذف الكتب',
                        color: AppTheme.primary,
                        onTap: _goManageBooks,
                      ),
                      _devToolCard(
                        icon: Icons.audiotrack,
                        title: 'إدارة اختصارات الصوت',
                        subtitle: 'إضافة وتعديل روابط اليوتيوب للرقى',
                        color: Colors.red,
                        onTap: _goManageAudioShortcuts,
                      ),
                      _devToolCard(
                        icon: Icons.contact_phone,
                        title: 'إدارة روابط التواصل',
                        subtitle: 'إضافة وتعديل روابط تواصل معنا',
                        color: AppTheme.primary,
                        onTap: _goManageContactLinks,
                      ),
                      _devToolCard(
                        icon: Icons.phone_callback,
                        title: 'إدارة رقم الحجز',
                        subtitle: 'رقم الرقية المستخدمة للحجز المباشر',
                        color: const Color(0xFF1F6FEB),
                        onTap: _showRuqyahPhoneDialog,
                      ),
                      _devToolCard(
                        icon: Icons.lock,
                        title: 'تغيير كلمة المرور',
                        subtitle: 'تعديل كلمة مرور المطور',
                        color: const Color(0xFF1F6FEB),
                        onTap: _changePassword,
                      ),
                      _devToolCard(
                        icon: Icons.refresh,
                        title: 'إعادة تعيين كلمة المرور',
                        subtitle: 'العودة إلى القيمة الافتراضية mhnd1978',
                        color: const Color(0xFFD35400),
                        onTap: _resetPassword,
                      ),
                      _devToolCard(
                        icon: Icons.backup,
                        title: 'نسخ احتياطي للقاعدة',
                        subtitle: 'حفظ قاعدة البيانات محلياً',
                        color: const Color(0xFF14532D),
                        onTap: _backupDatabase,
                      ),
                      _devToolCard(
                        icon: Icons.restore,
                        title: 'استعادة نسخة احتياطية',
                        subtitle: 'استرجاع من ملف نسخ احتياطي',
                        color: const Color(0xFF8E44AD),
                        onTap: _restoreDatabase,
                      ),
                      _devToolCard(
                        icon: Icons.delete_forever,
                        title: 'إعادة تعيين البيانات',
                        subtitle: 'حذف جميع الكتب من القاعدة',
                        color: Colors.red,
                        onTap: _clearAllBooks,
                      ),
                      _devToolCard(
                        icon: Icons.info,
                        title: 'معلومات الجهاز',
                        subtitle: 'نظام التشغيل والمجلد التطبيق',
                        color: const Color(0xFF6A1B9A),
                        onTap: _showDeviceInfo,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'كلمة المرور الحالية: ${_dev.devPassword}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'جميع العمليات تتم محلياً على الجهاز. لا تُشارك كلمة المرور مع المستخدمين.',
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
