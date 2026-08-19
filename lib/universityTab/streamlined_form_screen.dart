import 'package:flutter/material.dart';
import 'package:ishtar_platform/models/college_model.dart';
import 'package:ishtar_platform/universityTab/college_picker_screen.dart';

// PDF Packages
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class StreamlinedFormScreen extends StatefulWidget {
  final String title;
  final int maxChoices;
  final List<CollegeModel> availableColleges;
  final List<CollegeModel> initialChoices;

  const StreamlinedFormScreen({
    super.key,
    this.title = 'استمارة الانسيابية',
    this.maxChoices = 50,
    required this.availableColleges,
    this.initialChoices = const [],
  });

  @override
  State<StreamlinedFormScreen> createState() => _StreamlinedFormScreenState();
}

class _StreamlinedFormScreenState extends State<StreamlinedFormScreen> {
  late List<CollegeModel> _userChoices;
  bool _isGeneratingPdf = false;

  // App Brand Colors
  static const Color appPrimaryColor = Color(0xFF1B4980);
  static const Color appBackgroundColor = Color(0xFFE3EBF5);
  static const Color appAccentColor = Color(0xFF27AE60);

  // PDF Color Conversions
  static final PdfColor pdfPrimaryColor = PdfColor.fromInt(0xFF1B4980);
  static final PdfColor pdfHeaderBgColor = PdfColor.fromInt(0xFFE8EEF5);
  static final PdfColor pdfBorderColor = PdfColor.fromInt(0xFFB0C4DE);

  @override
  void initState() {
    super.initState();
    _userChoices = List.from(widget.initialChoices);
  }

  Future<void> _openCollegePicker() async {
    final List<CollegeModel>? selectedList =
        await Navigator.of(context).push<List<CollegeModel>>(
      MaterialPageRoute(
        builder: (context) => CollegePickerScreen(
          title: 'اختيار الكليات',
          availableColleges: widget.availableColleges,
          initiallySelectedColleges: _userChoices,
        ),
      ),
    );

    if (selectedList != null) {
      if (selectedList.length > widget.maxChoices) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تنبيه: تم تجاوز الحد الأقصى! سيتم الاحتفاظ بأول ${widget.maxChoices} كليات فقط.',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.orange[800],
          ),
        );
        setState(() {
          _userChoices = selectedList.take(widget.maxChoices).toList();
        });
      } else {
        setState(() {
          _userChoices = selectedList;
        });
      }
    }
  }

  void _removeItem(int index) {
    final removedCollege = _userChoices[index];
    setState(() {
      _userChoices.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف ${removedCollege.name} من الاختيارات',
            style: const TextStyle(fontFamily: 'Cairo')),
        action: SnackBarAction(
          label: 'تراجع',
          textColor: Colors.amber,
          onPressed: () {
            setState(() {
              _userChoices.insert(index, removedCollege);
            });
          },
        ),
      ),
    );
  }

  Future<void> _generateAndSaveOfficialPdf({
    String studentName = 'اسم الطالب الرباعي',
    String examId = '0000000000',
    String gender = 'ذكر',
    String branch = 'إحيائي',
    String schoolName = 'اسم الثانوية / إعدادية',
  }) async {
    if (_isGeneratingPdf) return;

    setState(() {
      _isGeneratingPdf = true;
    });

    try {
      final pdf = pw.Document();

      final fontRegular = await PdfGoogleFonts.cairoRegular();
      final fontBold = await PdfGoogleFonts.cairoBold();

      final List<String> collegeChoices = _userChoices
          .map((c) => '${c.universityName} - ${c.name}')
          .toList();

      // Determine single vs dual column dynamic layout
      final bool isSingleColumn = widget.maxChoices < 40;
      final int halfChoices = (widget.maxChoices / 2).ceil();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // --- CUSTOM DISCLAIMER HEADER ---
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: pdfHeaderBgColor,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: pdfPrimaryColor, width: 1),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'استمارة محاكاة ترتيب الاختيارات (منصة عشتار)',
                          style: pw.TextStyle(font: fontBold, fontSize: 13, color: pdfPrimaryColor),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'تنبيه هام: هذه الاستمارة عبارة عن تجربة محاكاة افتراضية فقط لمساعدتك في ترتيب خياراتك، وليست التقديم الرسمي. للتقديم النهائي المعتمد يجب استخدام الموقع الرسمي لدائرة الدراسات والتخطيط والمتابعة التابعة لوزارة التعليم العالي والبحث العلمي.',
                          style: pw.TextStyle(font: fontRegular, fontSize: 8.5, color: PdfColors.grey900),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 10),

                  // --- STUDENT INFO TABLE ---
                  pw.Table(
                    border: pw.TableBorder.all(color: pdfBorderColor, width: 0.8),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: pdfHeaderBgColor),
                        children: [
                          _buildTableHeaderCell('الاسم الرباعي للطالب', fontBold),
                          _buildTableHeaderCell('الرقم الامتحاني', fontBold),
                          _buildTableHeaderCell('الجنس', fontBold),
                          _buildTableHeaderCell('الفرع', fontBold),
                          _buildTableHeaderCell('المدرسة', fontBold),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          _buildTableCell(studentName, fontRegular),
                          _buildTableCell(examId, fontRegular),
                          _buildTableCell(gender, fontRegular),
                          _buildTableCell(branch, fontRegular),
                          _buildTableCell(schoolName, fontRegular),
                        ],
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 8),

                  // --- DYNAMIC CHOICES TABLE (1 Column if maxChoices < 40, else 2 Columns) ---
                  pw.Expanded(
                    child: isSingleColumn
                        ? _buildSingleColumnChoicesTable(
                            maxChoices: widget.maxChoices,
                            collegeChoices: collegeChoices,
                            fontRegular: fontRegular,
                            fontBold: fontBold,
                          )
                        : _buildDualColumnChoicesTable(
                            halfChoices: halfChoices,
                            collegeChoices: collegeChoices,
                            fontRegular: fontRegular,
                            fontBold: fontBold,
                          ),
                  ),

                  pw.SizedBox(height: 8),

                  // --- FOOTER SECTION ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'تاريخ الإنشاء: ${DateTime.now().toString().split('.')[0]}',
                            style: pw.TextStyle(font: fontRegular, fontSize: 8, color: pdfPrimaryColor),
                          ),
                          pw.Text(
                            'تم استخراج الملف بواسطة منصة عشتار التعليمية - استمارة محاكاة',
                            style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                     
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        name: 'استمارة_المحاكاة_عشتار',
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء إنشاء الملف: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  // Single-Column layout generator (< 40 choices)
  pw.Widget _buildSingleColumnChoicesTable({
    required int maxChoices,
    required List<String> collegeChoices,
    required pw.Font fontRegular,
    required pw.Font fontBold,
  }) {
    final List<String> choices = List.generate(maxChoices, (index) {
      return index < collegeChoices.length ? collegeChoices[index] : '';
    });

    return pw.Table(
      border: pw.TableBorder.all(color: pdfBorderColor, width: 0.6),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.0),
        1: pw.FlexColumnWidth(4.0),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: pdfHeaderBgColor),
          children: [
            _buildTableHeaderCell('الخيار', fontBold),
            _buildTableHeaderCell('اسم الكلية / المعهد', fontBold),
          ],
        ),
        ...List.generate(maxChoices, (i) {
          return pw.TableRow(
            children: [
              _buildTableCell('رقم (${i + 1})', fontRegular, fontSize: 8.5),
              _buildTableCell(choices[i], fontRegular, fontSize: 8.5, alignRight: true),
            ],
          );
        }),
      ],
    );
  }

  // Dual-Column layout generator (>= 40 choices)
  pw.Widget _buildDualColumnChoicesTable({
    required int halfChoices,
    required List<String> collegeChoices,
    required pw.Font fontRegular,
    required pw.Font fontBold,
  }) {
    final List<String> rightChoices = List.generate(halfChoices, (index) {
      return index < collegeChoices.length ? collegeChoices[index] : '';
    });

    final List<String> leftChoices = List.generate(halfChoices, (index) {
      final realIndex = index + halfChoices;
      return realIndex < collegeChoices.length ? collegeChoices[realIndex] : '';
    });

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Right Column
        pw.Expanded(
          child: pw.Table(
            border: pw.TableBorder.all(color: pdfBorderColor, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(3.8),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: pdfHeaderBgColor),
                children: [
                  _buildTableHeaderCell('الخيار', fontBold),
                  _buildTableHeaderCell('اسم الكلية / المعهد', fontBold),
                ],
              ),
              ...List.generate(halfChoices, (i) {
                return pw.TableRow(
                  children: [
                    _buildTableCell('رقم (${i + 1})', fontRegular, fontSize: 7.5),
                    _buildTableCell(rightChoices[i], fontRegular, fontSize: 7.5, alignRight: true),
                  ],
                );
              }),
            ],
          ),
        ),

        pw.SizedBox(width: 4),

        // Left Column
        pw.Expanded(
          child: pw.Table(
            border: pw.TableBorder.all(color: pdfBorderColor, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(3.8),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: pdfHeaderBgColor),
                children: [
                  _buildTableHeaderCell('الخيار', fontBold),
                  _buildTableHeaderCell('اسم الكلية / المعهد', fontBold),
                ],
              ),
              ...List.generate(halfChoices, (i) {
                final choiceIndex = i + 1 + halfChoices;
                return pw.TableRow(
                  children: [
                    _buildTableCell('رقم ($choiceIndex)', fontRegular, fontSize: 7.5),
                    _buildTableCell(leftChoices[i], fontRegular, fontSize: 7.5, alignRight: true),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableHeaderCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: 8.5, color: pdfPrimaryColor),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(
    String text,
    pw.Font font, {
    double fontSize = 8.0,
    bool alignRight = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5, horizontal: 3),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: fontSize),
        textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.center,
        maxLines: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: appPrimaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.format_list_numbered_rounded,
                            color: appPrimaryColor, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'عدد الاختيارات: ${_userChoices.length} / ${widget.maxChoices}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: appPrimaryColor,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _openCollegePicker,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                    ),
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text(
                      'تعديل الاختيارات',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _userChoices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.playlist_add_rounded,
                              size: 64, color: appPrimaryColor.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          const Text(
                            'لم تقم بإضافة أي كليات بعد',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: appPrimaryColor,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _openCollegePicker,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appPrimaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('اختيار الكليات',
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'Cairo')),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: _userChoices.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final item = _userChoices.removeAt(oldIndex);
                          _userChoices.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final college = _userChoices[index];
                        final morningShift =
                            college.getShift(StudyShift.morning);

                        return Container(
                          key: ValueKey(college.id),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F0FE),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: appPrimaryColor,
                                    fontSize: 13,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              college.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F2C4D),
                                fontFamily: 'Cairo',
                              ),
                            ),
                            subtitle: Text(
                              '${college.universityName} • أدنى معدل: %${morningShift?.requiredGpa ?? '--'}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: Colors.redAccent, size: 22),
                                  onPressed: () => _removeItem(index),
                                ),
                                const Icon(Icons.drag_indicator_rounded,
                                    color: Colors.grey, size: 24),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            if (_userChoices.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingPdf
                          ? null
                          : () => _generateAndSaveOfficialPdf(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appAccentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: _isGeneratingPdf
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf_rounded, size: 22),
                      label: Text(
                        _isGeneratingPdf
                            ? 'جاري إنشاء الملف...'
                            : 'تصدير الاستمارة PDF',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}