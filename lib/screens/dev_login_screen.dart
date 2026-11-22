import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import '../core/constants.dart';
import 'dev_dashboard_screen.dart';

class DevLoginScreen extends StatefulWidget {
  const DevLoginScreen({super.key});

  @override
  State<DevLoginScreen> createState() => _DevLoginScreenState();
}

class _DevLoginScreenState extends State<DevLoginScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // ملاحظة: لا نقوم بأي فحص تلقائي هنا. هذه الشاشة تُفتح دائماً عند النقر على لوحة المطور.
  }

  /// التحقق من كلمة المرور والدخول للوحة المطور
  Future<void> _attemptLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPassword = prefs.getString(AppConstants.prefKeyDevPassword);
      final defaultPassword = AppConstants.devPasswordDefault;
      final validPassword = storedPassword ?? defaultPassword;

      final entered = _passwordController.text.trim();

      if (entered != validPassword) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'كلمة المرور غير صحيحة.';
        });
        return;
      }

      // حفظ حالة تسجيل الدخول
      await prefs.setBool(AppConstants.prefKeyIsDevLoggedIn, true);

      if (!mounted) return;
      setState(() => _isLoading = false);

      // الانتقال إلى لوحة تحكم المطور
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DevDashboardScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ: $e';
      });
    }
  }

  /// إعادة تعيين كلمة المرور إلى الافتراضية
  Future<void> _resetPassword() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.prefKeyDevPassword, AppConstants.devPasswordDefault);
      await prefs.setBool(AppConstants.prefKeyIsDevLoggedIn, false);

      if (!mounted) return;
      _passwordController.clear();
      setState(() {
        _errorMessage = 'تمت إعادة تعيين كلمة المرور.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'فشل إعادة التعيين: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('تسجيل دخول المطور'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة القفل الكبيرة
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.lock_outline, color: AppTheme.primary, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'لوحة المطور',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'إدارة الكتب والمؤلفات والأغلفة',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // رسالة الخطأ إذا وجدت
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // حقل كلمة المرور
              TextField(
                controller: _passwordController,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, letterSpacing: 1),
                decoration: InputDecoration(
                  labelText: 'أدخل كلمة مرور المطور',
                  labelStyle: TextStyle(color: AppTheme.primary),
                  hintText: 'ادخل كلمة السر',
                  prefixIcon: const Icon(Icons.lock, color: AppTheme.primary),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // زر تسجيل الدخول
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _attemptLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'تسجيل الدخول',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // زر تبديل/إعادة تعيين كلمة المرور
              TextButton.icon(
                icon: const Icon(Icons.lock_reset, size: 18, color: AppTheme.primary),
                label: const Text(
                  'تبديل كلمة المرور',
                  style: TextStyle(color: AppTheme.primary, fontSize: 13),
                ),
                onPressed: _resetPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
