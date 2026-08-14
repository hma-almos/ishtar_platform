import 'package:flutter/material.dart';
import 'package:ishtar_platform/models/college_model.dart';
import 'package:ishtar_platform/universityTab/college_picker_screen.dart';

class StreamlinedFormScreen extends StatefulWidget {
  final String title;
  final int maxChoices;
  /// Pass the full list of available colleges from the previous screen
  final List<CollegeModel> availableColleges; 
  /// Optionally pass initial choices if resuming a session
  final List<CollegeModel> initialChoices;

  const StreamlinedFormScreen({
    super.key,
    this.title = 'استمارة الانسيابية',
    this.maxChoices = 10,
    required this.availableColleges, // <-- DATA PASSED FROM PUSHED CLASS
    this.initialChoices = const [],
  });

  @override
  State<StreamlinedFormScreen> createState() => _StreamlinedFormScreenState();
}

class _StreamlinedFormScreenState extends State<StreamlinedFormScreen> {
  late List<CollegeModel> _userChoices;

  @override
  void initState() {
    super.initState();
    // Initialize choices with provided initial data or pre-select top items
    _userChoices = List.from(widget.initialChoices);
  }

  /// Opens CollegePickerScreen using the colleges passed into this widget
  Future<void> _openCollegePicker() async {
    final List<CollegeModel>? selectedList =
        await Navigator.of(context).push<List<CollegeModel>>(
      MaterialPageRoute(
        builder: (context) => CollegePickerScreen(
          title: 'اختيار الكليات',
          availableColleges: widget.availableColleges, // <--- PASSING DATA HERE
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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B4980);
    const backgroundColor = Color(0xFFE3EBF5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
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
            // --- HEADER INFO COUNTER BAR (FIXED OVERFLOW) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.format_list_numbered_rounded,
                            color: primaryColor, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'عدد الاختيارات: ${_userChoices.length} / ${widget.maxChoices}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
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
                      backgroundColor: primaryColor,
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

            // --- REORDERABLE CHOICE LIST ---
            Expanded(
              child: _userChoices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.playlist_add_rounded,
                              size: 64, color: primaryColor.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          const Text(
                            'لم تقم بإضافة أي كليات بعد',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _openCollegePicker,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
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
                                    color: primaryColor,
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
          ],
        ),
      ),
    );
  }
}