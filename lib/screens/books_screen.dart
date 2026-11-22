import 'dart:io';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/constants.dart';
import '../models/book_model.dart';
import '../services/database_service.dart';
import 'pdf_viewer_screen.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  final _db = DatabaseService();
  List<BookModel> _dbBooks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final books = await _db.getBooks();
    if (!mounted) return;
    setState(() => _dbBooks = books);
  }

  List<BookModel> _allBooks() {
    final list = <BookModel>[];
    final dbTitles = _dbBooks.map((b) => b.title).toSet();
    final defaultCoverByTitle = <String, String>{
      for (final b in AppConstants.defaultBooks)
        if ((b['title'] ?? '').isNotEmpty && (b['cover'] ?? '').isNotEmpty)
          b['title']!: b['cover']!,
    };

    for (final b in AppConstants.defaultBooks) {
      // إذا تم تعديل الكتاب الافتراضي وحفظه في القاعدة تحت نفس العنوان، نعرض النسخة من القاعدة فقط
      if (dbTitles.contains(b['title']!)) continue;
      list.add(
        BookModel(
          title: b['title']!,
          author: b['author']!,
          type: b['type']!,
          description: b['description']!,
          keywords: b['keywords']!,
          pdfAsset: b['pdf']!,
          coverAsset: b['cover'],
        ),
      );
    }

    for (final b in _dbBooks) {
      final coverAsset = b.coverAsset ?? defaultCoverByTitle[b.title];
      if (coverAsset != null && coverAsset != b.coverAsset) {
        list.add(BookModel(
          id: b.id,
          title: b.title,
          author: b.author,
          type: b.type,
          description: b.description,
          keywords: b.keywords,
          pdfAsset: b.pdfAsset,
          pdfPath: b.pdfPath,
          coverPath: b.coverPath,
          coverAsset: coverAsset,
        ));
      } else {
        list.add(b);
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final books = _allBooks();
    return Scaffold(
      appBar: AppBar(title: const Text('مؤلفات وكتب أخرى')),
      body: books.isEmpty
          ? const Center(child: Text('لا توجد كتب متاحة'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final b = books[index];
                final isAuthorBook = b.type == 'مؤلفات الراقي';
                return _BookCard(
                  book: b,
                  isAuthorBook: isAuthorBook,
                );
              },
            ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;
  final bool isAuthorBook;

  const _BookCard({
    required this.book,
    required this.isAuthorBook,
  });

  Widget _buildCover() {
    Widget fallback() => Container(
          color: AppTheme.primary.withValues(alpha: 0.1),
          alignment: Alignment.center,
          child: Icon(
            isAuthorBook ? Icons.person : Icons.book,
            color: AppTheme.primary,
            size: 40,
          ),
        );

    if (book.hasCoverFile) {
      return Image.file(
        File(book.coverPath!),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (book.hasCoverAsset) {
            return Image.asset(
              book.coverAsset!,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => fallback(),
            );
          }
          return fallback();
        },
      );
    }
    if (book.hasCoverAsset) {
      return Image.asset(
        book.coverAsset!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback(),
      );
    }
    return fallback();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: _buildCover(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: (isAuthorBook ? AppTheme.primary : AppTheme.accent)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      book.type,
                      style: TextStyle(
                        color: isAuthorBook
                            ? AppTheme.primary
                            : const Color(0xFF8A5A1E),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf, size: 15),
                          label: const Text(
                            'عرض',
                            style: TextStyle(fontSize: 10.5),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primary,
                            side: const BorderSide(color: AppTheme.primary),
                            minimumSize: const Size(0, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: book.canOpenPdf
                              ? () => _openPdf(context)
                              : () => _showWordNotice(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPdf(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfViewerScreen(
          title: book.title,
          assetPath: book.hasAssetPdf ? book.pdfAsset : '',
          filePath: book.hasLocalPdf ? book.pdfPath : null,
        ),
      ),
    );
  }

  void _showWordNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'ملف PDF غير متاح لهذا الكتاب. الرجاء إضافة الملف من لوحة المطور.',
        ),
      ),
    );
  }
}
