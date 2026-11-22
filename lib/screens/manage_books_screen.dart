import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_theme.dart';
import '../core/constants.dart';
import '../models/book_model.dart';
import '../services/database_service.dart';
import 'add_edit_book_screen.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  final _db = DatabaseService();
  List<BookModel> _dbBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _db.getBooks();
      if (!mounted) return;
      setState(() {
        _dbBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage('فشل تحميل الكتب: $e', isError: true);
    }
  }

  /// يعرض جميع الكتب: الافتراضية من الثوابت + الكتب المخزنة في القاعدة.
  /// الكتب الافتراضية التي لها نسخة معدلة في القاعدة تُستبعد من القائمة الافتراضية
  /// لمنع التكرار.
  List<BookModel> _allBooks() {
    final list = <BookModel>[];
    final dbTitles = _dbBooks.map((b) => b.title).toSet();
    for (final b in AppConstants.defaultBooks) {
      if (dbTitles.contains(b['title']!)) continue;
      list.add(
        BookModel(
          title: b['title']!,
          author: b['author']!,
          type: b['type']!,
          description: b['description']!,
          keywords: b['keywords']!,
          pdfAsset: b['pdf']!,
        ),
      );
    }
    list.addAll(_dbBooks);
    return list;
  }

  Future<void> _addNewBook() async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AddEditBookScreen()));
    _loadBooks();
  }

  Future<void> _editBook(BookModel book) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AddEditBookScreen(book: book)));
    _loadBooks();
  }

  Future<void> _deleteBook(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الكتاب نهائياً؟'),
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
      await _db.deleteBook(id);
      _loadBooks();
    }
  }

  /// تصدير كتاب إلى التخزين الداخلي
  Future<void> _exportBook(BookModel book) async {
    try {
      final exportDir = Directory('/storage/emulated/0/Documents/raqq_export');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      int exported = 0;

      if (book.pdfPath != null && File(book.pdfPath!).existsSync()) {
        final safeName = book.title.replaceAll(
          RegExp(r'[^\w\u0600-\u06FF\s-]+'),
          '_',
        );
        final fileName = '$safeName.pdf';
        await File(book.pdfPath!).copy('${exportDir.path}/$fileName');
        exported++;
      }

      if (book.coverPath != null && File(book.coverPath!).existsSync()) {
        final ext = book.coverPath!.split('.').last;
        final safeName = book.title.replaceAll(
          RegExp(r'[^\w\u0600-\u06FF\s-]+'),
          '_',
        );
        final fileName = '${safeName}_cover.$ext';
        await File(book.coverPath!).copy('${exportDir.path}/$fileName');
        exported++;
      }

      if (!mounted) return;
      if (exported > 0) {
        _showMessage('تم التصدير إلى: ${exportDir.path}');
      } else {
        _showMessage('لا توجد ملفات لتصديرها لهذا الكتاب');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('فشل التصدير: $e', isError: true);
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.prefKeyIsDevLoggedIn, false);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      _showMessage('فشل تسجيل الخروج: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppTheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allBooks = _allBooks();
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('إدارة الكتب (المطور)'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : allBooks.isEmpty
              ? _buildEmptyState()
              : _buildBooksList(allBooks),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewBook,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة كتاب', style: TextStyle(color: Colors.white)),
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
                Icons.library_books,
                color: AppTheme.primary,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد كتب مضافة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'ابدأ بإضافة أول كتاب أو تعديل الكتب الافتراضية من خلال زر الإضافة أدناه.',
              style: TextStyle(fontSize: 15, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'إضافة كتاب جديد',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _addNewBook,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksList(List<BookModel> books) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isDefault = book.id == null;
        final hasPdf = book.canOpenPdf;
        final hasCover = book.hasCover;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isDefault
                          ? AppTheme.accent.withValues(alpha: 0.1)
                          : AppTheme.primary.withValues(alpha: 0.1),
                      radius: 24,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                isDefault ? Icons.library_books : Icons.person_outline,
                                size: 14,
                                color: AppTheme.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  book.author.isEmpty
                                      ? 'غير محدد'
                                      : book.author,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppTheme.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isDefault)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'افتراضي',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF8A5A1E),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (book.type == 'مؤلفات الراقي'
                                    ? AppTheme.primary
                                    : AppTheme.accent)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book.type,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: book.type == 'مؤلفات الراقي'
                              ? AppTheme.primary
                              : const Color(0xFF8A5A1E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      hasPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                      size: 15,
                      color: hasPdf ? AppTheme.primary : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'PDF: ${hasPdf ? 'موجود' : 'غير متاح'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasPdf
                            ? AppTheme.primary
                            : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      hasCover ? Icons.image : Icons.image_not_supported,
                      size: 15,
                      color: hasCover ? AppTheme.primary : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'الغلاف: ${hasCover ? 'موجود' : 'غير متاح'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: hasCover
                            ? AppTheme.primary
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    if (hasPdf)
                      TextButton.icon(
                        onPressed: () => _exportBook(book),
                        icon: const Icon(Icons.ios_share, size: 18),
                        label: const Text('تصدير'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                        ),
                      ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _editBook(book),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('تعديل'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (!isDefault)
                      TextButton.icon(
                        onPressed: () => _deleteBook(book.id!),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('حذف'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
