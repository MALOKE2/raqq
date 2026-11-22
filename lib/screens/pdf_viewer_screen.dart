import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../core/app_theme.dart';
import '../services/pdf_asset_helper.dart';
import '../widgets/quick_scrubber.dart';

/// شاشة عرض PDF تدعم مصدرين:
/// 1) ملف موجود على التخزين الداخلي عبر [filePath]
/// 2) ملف مضمّن في أصول التطبيق عبر [assetPath]
/// مع طرفية جانبية للتنقل السريع بين الصفحات توضح رقم الصفحة أثناء السحب.
class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String assetPath;
  final String? filePath;
  final int defaultPage;

  const PdfViewerScreen({
    super.key,
    required this.title,
    this.assetPath = '',
    this.filePath,
    this.defaultPage = 0,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  File? _file;
  bool _loading = true;
  String? _error;
  PDFViewController? _controller;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (widget.filePath != null && widget.filePath!.isNotEmpty) {
        final local = File(widget.filePath!);
        if (await local.exists()) {
          if (!mounted) return;
          setState(() {
            _file = local;
            _loading = false;
          });
          return;
        }
      }
      if (widget.assetPath.isNotEmpty && widget.assetPath.startsWith('assets/')) {
        final f = await PdfAssetHelper.copyAssetToFile(widget.assetPath);
        if (!mounted) return;
        setState(() {
          _file = f;
          _loading = false;
        });
        return;
      }
      throw 'لا يوجد ملف PDF صالح لهذا الكتاب';
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        bottom: _totalPages > 0
            ? PreferredSize(
                preferredSize: const Size.fromHeight(22),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'صفحة ${_currentPage + 1} من $_totalPages',
                    style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : Stack(
                  children: [
                    PDFView(
                      filePath: _file!.path,
                      defaultPage: widget.defaultPage,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: false,
                      pageFling: true,
                      pageSnap: true,
                      fitPolicy: FitPolicy.BOTH,
                      onViewCreated: (controller) async {
                        _controller = controller;
                        final count = await controller.getPageCount();
                        if (!mounted) return;
                        setState(() => _totalPages = count ?? 0);
                      },
                      onPageChanged: (page, total) {
                        if (!mounted) return;
                        setState(() {
                          _currentPage = page ?? 0;
                          if (total != null && total > 0) _totalPages = total;
                        });
                      },
                    ),
                    if (_totalPages > 1)
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: QuickScrubber(
                          count: _totalPages,
                          color: AppTheme.primary,
                          label: (i) => 'صفحة ${i + 1}',
                          onScrub: (i) {
                            _controller?.setPage(i);
                            if (mounted) setState(() => _currentPage = i);
                          },
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
            const SizedBox(height: 14),
            const Text(
              'تعذر فتح ملف PDF',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _load();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
