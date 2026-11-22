import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import '../services/dev_mode_service.dart';
import 'about_screen.dart';
import 'ruqyah_audio_screen.dart';
import 'ruqyah_written_screen.dart';
import 'adhkar_screen.dart';
import 'books_screen.dart';
import 'booking_screen.dart';
import 'contact_screen.dart';
import 'dev_login_screen.dart';
import 'simple_content_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, dynamic>> _menu = [
    {
      'title': 'نبذة عن الراقي',
      'icon': Icons.person_outline,
      'screen': 'about',
      'color': Color(0xFF0E7C7B),
    },
    {
      'title': 'تعريف الرقية الشرعية',
      'icon': Icons.menu_book_outlined,
      'screen': 'taarif_ruqyah',
      'color': Color(0xFF0E7C7B),
    },
    {
      'title': 'ما هو السحر',
      'icon': Icons.auto_fix_high,
      'screen': 'ma_huwa_sihr',
      'color': Color(0xFF6A1B9A),
    },
    {
      'title': 'تعريف العين والحسد',
      'icon': Icons.visibility_outlined,
      'screen': 'ayn_hasad',
      'color': Color(0xFF1F6FEB),
    },
    {
      'title': 'علامات الإصابة',
      'icon': Icons.fact_check_outlined,
      'screen': 'alamat',
      'color': Color(0xFFB45309),
    },
    {
      'title': 'البرامج العلاجية',
      'icon': Icons.healing_outlined,
      'screen': 'baramij',
      'color': Color(0xFF0F766E),
    },
    {
      'title': 'الرقية المكتوبة',
      'icon': Icons.description_outlined,
      'screen': 'written',
      'color': Color(0xFF8E44AD),
    },
    {
      'title': 'الرقية المسموعة',
      'icon': Icons.audiotrack,
      'screen': 'audio',
      'color': Color(0xFF1F6FEB),
    },
    {
      'title': 'الأذكار',
      'icon': Icons.auto_awesome,
      'screen': 'adhkar',
      'color': Color(0xFF14532D),
    },
    {
      'title': 'مؤلفات الراقي',
      'icon': Icons.library_books,
      'screen': 'books',
      'color': Color(0xFF6A1B9A),
    },
    {
      'title': 'الصرع وأنواعه',
      'icon': Icons.psychology_outlined,
      'screen': 'saraa',
      'color': Color(0xFF7C3AED),
    },
    {
      'title': 'حجز الرقية مباشرة',
      'icon': Icons.calendar_today,
      'screen': 'booking',
      'color': Color(0xFFC5A059),
    },
    {
      'title': 'تواصل معنا',
      'icon': Icons.contact_phone,
      'screen': 'contact',
      'color': Color(0xFF0B5345),
    },
    {
      'title': 'لوحة المطور',
      'icon': Icons.lock_outline,
      'screen': 'dev',
      'color': AppTheme.primary,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            tooltip: 'لوحة المطور',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DevLoginScreen()),
              );
            },
          ),
          if (DevModeService.instance.isDevLoggedIn)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: const Text(
                'الوضع المطور نشط',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/icon/logo_1024.png',
                    width: 86,
                    height: 86,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'رقى شرعية • كتب • حجز مباشر',
                  style: TextStyle(color: Color(0xFFD4C7B3), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.86,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _menu.length,
              itemBuilder: (context, index) {
                final item = _menu[index];
                return _MenuCard(
                  title: item['title'] as String,
                  icon: item['icon'] as IconData,
                  color: item['color'] as Color,
                  onTap: () => _navigateTo(context, item['screen'] as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    switch (route) {
      case 'about':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
        break;
      case 'audio':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RuqyahAudioScreen()));
        break;
      case 'written':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RuqyahWrittenScreen()));
        break;
      case 'adhkar':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdhkarScreen()));
        break;
      case 'baramij':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SimpleContentScreen(
              title: 'البرامج العلاجية',
              assetPath: 'assets/roq_text/baramij_ilajiyya.txt',
            ),
          ),
        );
        break;
      case 'alamat':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SimpleContentScreen(
              title: 'علامات الإصابة',
              assetPath: 'assets/roq_text/alamat_isaba.txt',
            ),
          ),
        );
        break;
      case 'saraa':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SimpleContentScreen(
              title: 'الصرع وأنواعه',
              assetPath: 'assets/roq_text/anwa_saraa.txt',
            ),
          ),
        );
        break;
      case 'taarif_ruqyah':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SimpleContentScreen(
              title: 'تعريف الرقية الشرعية',
              assetPath: 'assets/roq_text/ruqyah_shariya.txt',
            ),
          ),
        );
        break;
      case 'ma_huwa_sihr':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SimpleContentScreen(
              title: 'ما هو السحر',
              assetPath: 'assets/roq_text/ma_huwa_sihr.txt',
            ),
          ),
        );
        break;
      case 'ayn_hasad':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const SimpleContentScreen(
              title: 'تعريف العين والحسد',
              assetPath: 'assets/roq_text/ayn_hasad.txt',
            ),
          ),
        );
        break;
      case 'books':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BooksScreen()));
        break;
      case 'booking':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookingScreen()));
        break;
      case 'contact':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactScreen()));
        break;
      case 'dev':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DevLoginScreen()));
        break;
    }
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.92), color],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
