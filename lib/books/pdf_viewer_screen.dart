import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfOfflineViewerScreen extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PdfOfflineViewerScreen({
    Key? key,
    required this.title,
    required this.pdfUrl,
  }) : super(key: key);

  static const Color primaryNavy = Color(0xFF16487D);

  @override
  State<PdfOfflineViewerScreen> createState() => _PdfOfflineViewerScreenState();
}

class _PdfOfflineViewerScreenState extends State<PdfOfflineViewerScreen> {
  String? _localFilePath;
  bool _isLoading = true;
  String _downloadProgress = 'جاري تحضير الكتاب...';

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // Create a unique filename from the URL
      final filename = widget.pdfUrl.split('/').last.split('?').first;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');

      // 1. Check if file is already cached locally
      if (await file.exists()) {
        if (!mounted) return;
        setState(() {
          _localFilePath = file.path;
          _isLoading = false;
        });
        return;
      }

      // 2. Download from backend if not cached
      setState(() {
        _downloadProgress = 'جاري تنزيل الكتاب للمرة الأولى...';
      });

      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        
        if (!mounted) return;
        setState(() {
          _localFilePath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحميل الملف: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF8),
      appBar: AppBar(
        backgroundColor: Color(0xFF16487D),
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF16487D)),
                  const SizedBox(height: 16),
                  Text(
                    _downloadProgress,
                    style: const TextStyle(
                      color:Color(0xFF16487D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : _localFilePath != null
              ? PDFView(
                  filePath: _localFilePath,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                )
              : const Center(
                  child: Text(
                    'تعذر فتح الملف',
                    style: TextStyle(color: Color(0xFF16487D), fontSize: 16),
                  ),
                ),
    );
  }
}