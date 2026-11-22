import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_theme.dart';
import 'core/constants.dart';
import 'services/dev_mode_service.dart';
import 'services/database_service.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة خدمة وضع المطور قبل تشغيل التطبيق
  DevModeService.instance.init();
  // seeding البيانات الافتراضية (روابط التواصل) + حذف الاختصارات الصوتية القديمة المزروعة
  final _db = DatabaseService();
  _db.seedDefaults();
  _db.removeSeededAudioShortcuts();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [
        Locale('ar', 'AE'),
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      theme: AppTheme.lightTheme(),
      home: const SplashScreen(),
    );
  }
}
