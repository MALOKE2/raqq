import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../core/app_theme.dart';
import '../models/book_model.dart';
import '../services/database_service.dart';
import 'manage_books_screen.dart';

class AddEditBookScreen extends StatefulWidget {
  final BookModel? book;
  final String? initialPdfPath;

  const AddEditBookScreen({super.key, this.book, this.initialPdfPath});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _db = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _pdfAssetController = TextEditingController();

  String _type = 'مؤلفات الراقي';
  File? _coverFile;
  String? _existingCoverPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      final b = widget.book!;
      _titleController.text = b.title;
      _authorController.text = b.author;
      _type = b.type;
      _descController.text = b.description;
      _keywordsController.text = b.keywords;
      _pdfAssetController.text = b.hasLocalPdf
          ? b.pdfPath ?? ''
          : b.pdfAsset;
      _existingCoverPath = b.coverPath;
    }
    if (widget.initialPdfPath != null) {
      _pdfAssetController.text = widget.initialPdfPath ?? '';
    }
  }

  Future<void> _pickCoverFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (picked != null) {
        setState(() => _coverFile = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('فشل اختيار الصورة: $e', isError: true);
    }
  }

  /// اختيار ملف PDF من التخزين الداخلي للهاتف عبر مدير الملفات المدمج.
  /// يتم نسخ الملف إلى مجلد التطبيق وسيعمل حتى بعد نقل/مسح الملف الأصلي.
  Future<void> _pickPdfFromPhone() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (files.isEmpty) return;
      final pickedPath = files.single.path;
      if (pickedPath == null) return;
      final source = File(pickedPath);
      if (!await source.exists()) {
        throw 'تعذر الوصول إلى الملف المختار';
      }
      final copied = await _db.copyInternalFileToApp(
        source,
        'book_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      setState(() => _pdfAssetController.text = copied.path);
      _showMessage('تم اختيار الملف وربطه بنجاح');
    } catch (e) {
      if (!mounted) return;
      _showMessage('فشل اختيار الملف: $e', isError: true);
    }
  }

  /// لصق مسار ملف PDF من الحافظة
  Future<void> _pastePdfPath() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData != null &&
          clipboardData.text != null &&
          clipboardData.text!.isNotEmpty) {
        setState(() {
          _pdfAssetController.text = clipboardData.text!;
        });
        _showMessage('تم لصق المسار من الحافظة');
      } else {
        _showMessage('الحافظة فارغة أو لا تحتوي على نص', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('فشل اللصق من الحافظة: $e', isError: true);
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // نسخ الغلاف إلى مجلد التطبيق الداخلي
      String? coverPath = _existingCoverPath;
      if (_coverFile != null) {
        final copied = await _db.copyInternalFileToApp(
          _coverFile!,
          'cover_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        coverPath = copied.path;
      } else if (widget.book == null) {
        coverPath = null;
      }

      // معالجة مسار ملف PDF: نسخه إلى مجلد التطبيق إن كان خارجياً
      final enteredPdf = _pdfAssetController.text.trim();
      String pdfAssetValue = '';
      String? pdfPathValue;

      if (enteredPdf.isNotEmpty) {
        if (enteredPdf.startsWith('assets/')) {
          pdfAssetValue = enteredPdf;
          pdfPathValue = null;
        } else {
          final source = File(enteredPdf);
          if (!await source.exists()) {
            throw 'ملف PDF غير موجود في المسار المحدد:\n$enteredPdf';
          }
          final appDir = await _db.appDocDir;
          if (enteredPdf.startsWith(appDir.path)) {
            pdfPathValue = enteredPdf;
          } else {
            final copied = await _db.copyInternalFileToApp(
              source,
              'book_${DateTime.now().millisecondsSinceEpoch}.pdf',
            );
            pdfPathValue = copied.path;
          }
        }
      }

      final book = BookModel(
        id: widget.book?.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        type: _type,
        description: _descController.text.trim(),
        keywords: _keywordsController.text.trim(),
        pdfAsset: pdfAssetValue,
        pdfPath: pdfPathValue,
        coverPath: coverPath,
      );

      if (widget.book == null || widget.book!.id == null) {
        await _db.insertBook(book);
      } else {
        await _db.updateBook(book);
      }

      if (!mounted) return;
      setState(() => _isSaving = false);
      _showMessage('تم حفظ الكتاب بنجاح');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ManageBooksScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showMessage('فشل الحفظ: $e', isError: true);
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

  Widget _buildFileSection() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _pdfAssetController,
      builder: (context, value, _) {
        final path = value.text.trim();
        final isAsset = path.startsWith('assets/');
        final exists = path.isNotEmpty && !isAsset && File(path).existsSync();
        final valid = isAsset || exists;
        final invalid = path.isNotEmpty && !valid;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: valid
                ? AppTheme.primary.withValues(alpha: 0.05)
                : Colors.white,
            border: Border.all(
              color: invalid
                  ? Colors.redAccent
                  : valid
                  ? AppTheme.primary
                  : AppTheme.divider,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ملف PDF في التخزين الداخلي',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                'اضغط "اختيار ملف PDF من الهاتف" وحدد الملف من التخزين الداخلي، وسيُنسخ تلقائياً مع الكتاب.',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.file_open,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'اختيار ملف PDF من الهاتف',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _pickPdfFromPhone,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pdfAssetController,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: 'مسار ملف PDF',
                  hintText: '/storage/emulated/0/Documents/book.pdf',
                  prefixIcon: const Icon(
                    Icons.picture_as_pdf,
                    color: AppTheme.primary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.content_paste,
                    color: AppTheme.primary,
                  ),
                  label: const Text('لصق المسار من الحافظة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _pastePdfPath,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: invalid
                      ? Colors.red.withValues(alpha: 0.06)
                      : AppTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      path.isEmpty
                          ? Icons.info_outline
                          : invalid
                          ? Icons.error_outline
                          : Icons.check_circle,
                      color: invalid
                          ? Colors.red
                          : AppTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        path.isEmpty
                            ? 'لم يتم تحديد ملف PDF بعد (اختياري).'
                            : invalid
                            ? 'المسار غير صحيح أو الملف غير موجود.'
                            : isAsset
                            ? 'ملف مضمّن داخل التطبيق.'
                            : 'الملف موجود وسيتم نسخه إلى مجلد التطبيق الداخلي عند الحفظ.',
                        style: TextStyle(
                          color: invalid ? Colors.red : AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoverSection() {
    final hasCover =
        (_coverFile != null && _coverFile!.existsSync()) ||
        (_existingCoverPath != null && File(_existingCoverPath!).existsSync());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasCover
            ? AppTheme.primary.withValues(alpha: 0.05)
            : Colors.white,
        border: Border.all(
          color: hasCover ? AppTheme.primary : AppTheme.divider,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'صورة غلاف الكتاب',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _coverFile != null
                        ? Image.file(
                            _coverFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (c, e, s) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: AppTheme.primary,
                                size: 40,
                              ),
                            ),
                          )
                        : _existingCoverPath != null &&
                              File(_existingCoverPath!).existsSync()
                        ? Image.file(
                            File(_existingCoverPath!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (c, e, s) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: AppTheme.primary,
                                size: 40,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.add_a_photo,
                              color: AppTheme.primary,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  SizedBox(
                    width: 100,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _pickCoverFromGallery,
                      icon: const Icon(Icons.photo_library, size: 16),
                      label: const Text(
                        'اختيار',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  if (hasCover)
                    SizedBox(
                      width: 100,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _coverFile = null;
                          if (widget.book == null) _existingCoverPath = null;
                        }),
                        icon: const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'إزالة',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(widget.book == null ? 'إضافة كتاب جديد' : 'تعديل الكتاب'),
        centerTitle: true,
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // العنوان
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'عنوان الكتاب',
                prefixIcon: const Icon(Icons.title, color: AppTheme.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'الرجاء إدخال العنوان' : null,
            ),
            const SizedBox(height: 16),

            // المؤلف
            TextFormField(
              controller: _authorController,
              decoration: InputDecoration(
                labelText: 'المؤلف',
                prefixIcon: const Icon(Icons.person, color: AppTheme.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // النوع
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: 'نوع الكتاب',
                prefixIcon: const Icon(Icons.category, color: AppTheme.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'مؤلفات الراقي',
                  child: Text('مؤلفات الراقي'),
                ),
                DropdownMenuItem(value: 'كتب أخرى', child: Text('كتب أخرى')),
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),

            // الوصف
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'وصف الكتاب',
                prefixIcon: const Icon(
                  Icons.description,
                  color: AppTheme.primary,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // الكلمات المفتاحية
            TextFormField(
              controller: _keywordsController,
              decoration: InputDecoration(
                labelText: 'كلمات مفتاحية (مفصولة بفاصلة)',
                prefixIcon: const Icon(Icons.key, color: AppTheme.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // قسم ملف PDF
            _buildFileSection(),
            const SizedBox(height: 20),

            // قسم صورة الغلاف
            _buildCoverSection(),
            const SizedBox(height: 30),

            // زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'حفظ الكتاب',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    _keywordsController.dispose();
    _pdfAssetController.dispose();
    super.dispose();
  }
}
