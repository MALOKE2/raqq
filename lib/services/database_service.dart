import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/book_model.dart';
import '../models/audio_shortcut.dart';
import '../models/contact_link.dart';
import '../core/constants.dart';

class DatabaseService {
  static Database? _db;

  Future<Database> get db async => _db ??= await _initDb();

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'raqq.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE books(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            author TEXT,
            type TEXT,
            description TEXT,
            keywords TEXT,
            pdf_asset TEXT,
            pdf_path TEXT,
            cover_path TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE audio_shortcuts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            url TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE contact_links(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            label TEXT,
            url TEXT,
            icon TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // فحص الأعمدة والجداول قبل تغيير المخطط لتفادي تكرار الأعمدة إذا كان المخطط محدثاً جزئياً
        final tables = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table'");
        final tableNames = tables.map((r) => r['name'] as String).toSet();
        Future<bool> columnExists(String table, String column) async {
          final info = await db.rawQuery('PRAGMA table_info($table)');
          return info.any((r) => r['name'] == column);
        }

        if (!await columnExists('books', 'pdf_path')) {
          await db.execute('ALTER TABLE books ADD COLUMN pdf_path TEXT');
        }
        if (!await columnExists('books', 'cover_path')) {
          await db.execute('ALTER TABLE books ADD COLUMN cover_path TEXT');
        }
        if (!tableNames.contains('audio_shortcuts')) {
          await db.execute('''
            CREATE TABLE audio_shortcuts(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              url TEXT
            )
          ''');
        }
        if (!tableNames.contains('contact_links')) {
          await db.execute('''
            CREATE TABLE contact_links(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              label TEXT,
              url TEXT,
              icon TEXT
            )
          ''');
        }
      },
    );
  }

  // ===== كتب =====
  Future<int> insertBook(BookModel book) async {
    final d = await db;
    return await d.insert('books', book.toMap());
  }

  Future<List<BookModel>> getBooks() async {
    final d = await db;
    final List<Map<String, Object?>> maps = await d.query('books');
    return maps.map((m) => BookModel.fromMap(m)).toList();
  }

  Future<int> updateBook(BookModel book) async {
    final d = await db;
    return await d.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(int id) async {
    final d = await db;
    return await d.delete('books', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getBookCount() async {
    final d = await db;
    final List<Map<String, Object?>> maps =
        await d.rawQuery('SELECT COUNT(*) as c FROM books');
    return (maps.first['c'] as int?) ?? 0;
  }

  // ===== اختصارات الرقية المسموعة (يوتيوب) =====
  Future<int> insertAudioShortcut(AudioShortcut shortcut) async {
    final d = await db;
    return await d.insert('audio_shortcuts', shortcut.toMap());
  }

  Future<List<AudioShortcut>> getAudioShortcuts() async {
    final d = await db;
    final List<Map<String, Object?>> maps =
        await d.query('audio_shortcuts');
    return maps.map((m) => AudioShortcut.fromMap(m)).toList();
  }

  Future<int> updateAudioShortcut(AudioShortcut shortcut) async {
    final d = await db;
    return await d.update(
      'audio_shortcuts',
      shortcut.toMap(),
      where: 'id = ?',
      whereArgs: [shortcut.id],
    );
  }

  Future<int> deleteAudioShortcut(int id) async {
    final d = await db;
    return await d.delete('audio_shortcuts', where: 'id = ?', whereArgs: [id]);
  }

  // ===== روابط تواصل معنا =====
  Future<int> insertContactLink(ContactLink link) async {
    final d = await db;
    return await d.insert('contact_links', link.toMap());
  }

  Future<List<ContactLink>> getContactLinks() async {
    final d = await db;
    final List<Map<String, Object?>> maps = await d.query('contact_links');
    return maps.map((m) => ContactLink.fromMap(m)).toList();
  }

  Future<int> updateContactLink(ContactLink link) async {
    final d = await db;
    return await d.update(
      'contact_links',
      link.toMap(),
      where: 'id = ?',
      whereArgs: [link.id],
    );
  }

  Future<int> deleteContactLink(int id) async {
    final d = await db;
    return await d.delete('contact_links', where: 'id = ?', whereArgs: [id]);
  }

  /// Ferme la connexion à la base de données et la réinitialise (utilisé pour la restauration).
  static Future<void> resetConnection() async {
    await _db?.close();
    _db = null;
  }

  /// يحصل على مجلد التطبيق في التخزين الداخلي للمستندات
  Future<Directory> get appDocDir async => await getApplicationDocumentsDirectory();

  /// ينسخ ملف من التخزين الداخلي إلى مجلد التطبيق ويكون ملكًا للتطبيق
  Future<File> copyInternalFileToApp(File sourceFile, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = File('${dir.path}/$fileName');
    await sourceFile.copy(dest.path);
    return dest;
  }

  /// يحذف اختصارات الرقية المسموعة الافتراضية القديمة (التي كان التطبيق يزرعها من قبل).
  /// يُستدعى عند كل إقلاع؛ آمن ولا يؤثر على اختصارات أضافها المطور.
  Future<void> removeSeededAudioShortcuts() async {
    final d = await db;
    const seededTitles = [
      'الرقية الشرعية كاملة',
      'آيات السحر',
      'آيات العين والحسد',
    ];
    const seededUrls = [
      'https://www.youtube.com/@AlRaqiIraqi',
      'https://www.youtube.com/@alraqyiraqi',
      'https://www.youtube.com/@Alraqyiraqi',
      'https://www.youtube.com/@al_raqi_iraqi',
    ];
    for (final title in seededTitles) {
      for (final url in seededUrls) {
        await d.delete(
          'audio_shortcuts',
          where: 'title = ? AND url = ?',
          whereArgs: [title, url],
        );
      }
    }
  }

  /// ي Seed البيانات الافتراضية إذا كانت الجداول فارغة (يُستدعى مرة واحدة عند البدء).
  Future<void> seedDefaults() async {
    final d = await db;

    // seeding اختصارات الرقية المسموعة الافتراضية
    final countAudio = Sqflite.firstIntValue(
      await d.rawQuery('SELECT COUNT(*) FROM audio_shortcuts'),
    );
    if (countAudio == 0) {
      for (final item in AppConstants.defaultAudioShortcuts) {
        await d.insert('audio_shortcuts', {
          'title': item['title'],
          'url': item['url'],
        });
      }
    } else {
      // ضمان وجود الروابط الافتراضية حتى لو كانت القاعدة تحتوي بيانات قديمة
      for (final item in AppConstants.defaultAudioShortcuts) {
        final exists = Sqflite.firstIntValue(
          await d.rawQuery(
            'SELECT COUNT(*) FROM audio_shortcuts WHERE title = ? AND url = ?',
            [item['title'], item['url']],
          ),
        );
        if (exists == 0) {
          await d.insert('audio_shortcuts', {
            'title': item['title'],
            'url': item['url'],
          });
        }
      }
    }

    // seeding روابط التواصل
    final countContact = Sqflite.firstIntValue(
      await d.rawQuery('SELECT COUNT(*) FROM contact_links'),
    );
    if (countContact == 0) {
      for (final item in AppConstants.defaultContactLinks) {
        await d.insert('contact_links', {
          'label': item['label'],
          'url': item['url'],
          'icon': item['icon'],
        });
      }
    } else {
      // ضمان وجود روابط التواصل الافتراضية
      for (final item in AppConstants.defaultContactLinks) {
        final exists = Sqflite.firstIntValue(
          await d.rawQuery(
            'SELECT COUNT(*) FROM contact_links WHERE label = ? AND url = ?',
            [item['label'], item['url']],
          ),
        );
        if (exists == 0) {
          await d.insert('contact_links', {
            'label': item['label'],
            'url': item['url'],
            'icon': item['icon'],
          });
        }
      }
    }

    // seeding الكتب الافتراضية (مع ضمان وجودها)
    for (final item in AppConstants.defaultBooks) {
      final title = item['title'] ?? '';
      if (title.isEmpty) continue;
      final existing = await d.query(
        'books',
        where: 'title = ?',
        whereArgs: [title],
        limit: 1,
      );
      if (existing.isEmpty) {
        await d.insert('books', {
          'title': item['title'],
          'author': item['author'],
          'type': item['type'],
          'description': item['description'],
          'keywords': item['keywords'],
          'pdf_asset': item['pdf'],
          'pdf_path': null,
          'cover_path': null,
        });
      } else {
        // تحديث بيانات الكتاب الافتراضي الأساسية مع الحفاظ على الملفات المحلية للمستخدم
        final row = existing.first;
        await d.update(
          'books',
          {
            'author': item['author'],
            'type': item['type'],
            'description': item['description'],
            'keywords': item['keywords'],
            'pdf_asset': item['pdf'],
            'pdf_path': row['pdf_path'],
            'cover_path': row['cover_path'],
          },
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }
  }
}
