import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../services/database_service.dart';

/// Service central du mode développeur.
/// Gère la session développeur, le mot de passe, la sauvegarde/restauration
/// de la base de données locale et la réinitialisation des données.
class DevModeService {
  static final DevModeService instance = DevModeService._internal();
  factory DevModeService() => instance;
  DevModeService._internal();

  SharedPreferences? _prefs;
  final _db = DatabaseService();

  /// Initialise le service (à appeler au démarrage de l'application).
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Indique si une session développeur est active.
  bool get isDevLoggedIn => _prefs?.getBool(AppConstants.prefKeyIsDevLoggedIn) ?? false;

  /// Mot de passe développeur actuel (stocké ou par défaut).
  String get devPassword => _prefs?.getString(AppConstants.prefKeyDevPassword) ?? AppConstants.devPasswordDefault;

  /// Numéro de téléphone du Raqï (راقية) utilisé pour la réservation directe.
  String get ruqyahBookingPhone => _prefs?.getString(AppConstants.prefKeyRuqyahPhone) ?? AppConstants.ruqyahPhone;

  /// Définit le numéro de téléphone du Raqï (راقية) utilisé pour la réservation directe.
  Future<void> setRuqyahBookingPhone(String phone) async {
    if (_prefs == null) await init();
    await _prefs!.setString(AppConstants.prefKeyRuqyahPhone, phone.trim());
  }

  /// Vérifie le mot de passe et active la session développeur.
  Future<bool> login(String password) async {
    if (_prefs == null) await init();
    final entered = password.trim();
    if (entered == devPassword) {
      await _prefs!.setBool(AppConstants.prefKeyIsDevLoggedIn, true);
      return true;
    }
    return false;
  }

  /// Désactive la session développeur.
  Future<void> logout() async {
    if (_prefs == null) await init();
    await _prefs!.setBool(AppConstants.prefKeyIsDevLoggedIn, false);
  }

  /// Change le mot de passe développeur (nécessite l'actuel).
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    if (_prefs == null) await init();
    if (currentPassword.trim() != devPassword) return false;
    if (newPassword.trim().isEmpty) return false;
    await _prefs!.setString(AppConstants.prefKeyDevPassword, newPassword.trim());
    return true;
  }

  /// Réinitialise le mot de passe à la valeur par défaut et déconnecte.
  Future<void> resetPassword() async {
    if (_prefs == null) await init();
    await _prefs!.setString(AppConstants.prefKeyDevPassword, AppConstants.devPasswordDefault);
    await logout();
  }

  /// Sauvegarde la base de données locale dans le stockage interne.
  Future<String> backupDatabase() async {
    final dir = Directory('/storage/emulated/0/Documents/raqq_dev_backup');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final d = await _db.db;
    final dbPath = d.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFile = File('${dir.path}/raqq_backup_$timestamp.db');
    await File(dbPath).copy(backupFile.path);
    return backupFile.path;
  }

  /// Restaure la base de données depuis un fichier de sauvegarde.
  Future<void> restoreDatabase(String backupPath) async {
    final backupFile = File(backupPath);
    if (!await backupFile.exists()) {
      throw Exception('Fichier de sauvegarde introuvable');
    }
    await DatabaseService.resetConnection();
    final d = await _db.appDocDir;
    await backupFile.copy('${d.path}/raqq.db');
  }

  /// Supprime tous les livres de la base de données (réinitialisation des données).
  Future<int> clearAllBooks() async {
    final d = await _db.db;
    return await d.delete('books');
  }

  /// Retourne des informations de base sur l'appareil et l'application.
  Future<Map<String, String>> getDeviceInfo() async {
    final dir = await _db.appDocDir;
    final bookCount = await _db.getBookCount();
    return {
      'plateforme': Platform.operatingSystem,
      'version_systeme': Platform.version,
      'dossier_application': dir.path,
      'nombre_de_livres': bookCount.toString(),
      'mot_de_passe_actif': devPassword,
    };
  }
}
