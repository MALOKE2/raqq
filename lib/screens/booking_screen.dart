import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_theme.dart';
import '../models/contact_link.dart';
import '../services/database_service.dart';

/// شاشة الحجز المباشر — تُظهر العبارة: «قم بالحجز من خلال»
/// مع رابط واتساب ورقم الرقية، ويتم جلبهما من قسم «تواصل معنا».
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _db = DatabaseService();
  final _ruqyahPhone = TextEditingController();
  bool _isLoading = true;
  String _whatsappUrl = '';
  String _ruqyahNumber = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ruqyahPhone.dispose();
    super.dispose();
  }

  /// جلب رابط واتساب ورقم الرقية من قسم «تواصل معنا» (قائمة روابط التواصل).
  Future<void> _load() async {
    ContactLink? waLink;
    try {
      final links = await _db.getContactLinks();
      for (final l in links) {
        if (l.url.contains('wa.me')) {
          waLink = l;
          break;
        }
      }
    } catch (_) {}

    String digits = '';
    String waUrl = '';
    if (waLink != null) {
      digits = waLink.url.replaceAll(RegExp(r'[^0-9]'), '');
      waUrl = 'https://wa.me/$digits';
    } else {
      digits = '9647700000000';
      waUrl = 'https://wa.me/9647700000000';
    }

    if (!mounted) return;
    setState(() {
      _whatsappUrl = waUrl;
      _ruqyahNumber = digits;
      _ruqyahPhone.text = digits;
      _isLoading = false;
    });
  }

  /// فتح رابط واتساب الحجز.
  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(_whatsappUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح رابط الواتساب، تأكد من اتصالك بالإنترنت.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز الرقية مباشرة'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.calendar_today, color: AppTheme.primary, size: 46),
                        const SizedBox(height: 14),
                        const Text(
                          'قم بالحجز من خلال',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.phone_iphone,
                                color: AppTheme.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  'رقم الرقية: $_ruqyahNumber',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppTheme.textDark,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.chat_bubble, color: Colors.white),
                            label: const Text(
                              'فتح واتساب للحجز',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _openWhatsApp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'اضغط على زر الواتساب لمراسلة الراقي مباشرة وحجز جلستك.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
