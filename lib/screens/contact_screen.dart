import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../core/constants.dart';
import '../services/database_service.dart';
import '../models/contact_link.dart';

/// شاشة تواصل معنا — الروابط يتم تحميلها من قاعدة البيانات.
/// إدارة الروابط (إضافة/تعديل/حذف) تتم من لوحة المطور فقط.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _db = DatabaseService();
  List<ContactLink> _links = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final links = await _db.getContactLinks();
    if (!mounted) return;
    setState(() {
      _links = links;
      _isLoading = false;
    });
  }

  Future<bool> _launch(String value, String type) async {
    final uri = Uri.parse(value);
    try {
      if (type == 'call') {
        return await launchUrl(Uri(scheme: 'tel', path: uri.path.replaceFirst('tel:', '')));
      } else if (type == 'email') {
        return await launchUrl(uri);
      } else {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      return false;
    }
  }

  String _detectType(String url) {
    if (url.startsWith('tel:')) return 'call';
    if (url.startsWith('mailto:')) return 'email';
    return 'web';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تواصل معنا'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: AppTheme.primary,
                  child: Column(
                    children: [
                      const Icon(Icons.contact_phone, color: Colors.white, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        AppConstants.appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الراقي العراقي — للتواصل والاستفسارات',
                        style: TextStyle(color: Color(0xFFD4C7B3), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _links.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.6,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _links.length,
                          itemBuilder: (context, index) {
                            final item = _links[index];
                            final type = _detectType(item.url);
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final ok = await _launch(item.url, type);
                                  if (!ok && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'تعذر فتح هذا الرابط.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          item.toIconData(),
                                          color: AppTheme.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.5,
                                            height: 1.15,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: AppTheme.primary,
                                      ),
                                    ],
                                  ),
                                ),
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
                Icons.link,
                color: AppTheme.primary,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد روابط مضافة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'أضف روابط تواصل من لوحة المطور.',
              style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
