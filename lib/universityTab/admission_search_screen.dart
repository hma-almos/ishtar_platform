import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ishtar_platform/models/college_model.dart';
import 'package:ishtar_platform/universityTab/minimum_limits_screen.dart';
import 'package:ishtar_platform/universityTab/streamlined_form_screen.dart';

class AdmissionSearchScreen extends StatefulWidget {
  final String title;
  final bool isPrivate; // Explicit flag for private (أهلي) vs public (حكومي)
  final StudyShift? shift; // Morning, Parallel, Evening

  const AdmissionSearchScreen({
    super.key,
    required this.title,
    required this.isPrivate,
    this.shift,
  });

  @override
  State<AdmissionSearchScreen> createState() => _AdmissionSearchScreenState();
}

class _AdmissionSearchScreenState extends State<AdmissionSearchScreen> {
  final TextEditingController _gpaController = TextEditingController();
  String? _selectedInterest;
  String? _selectedGovernorate;

  final List<String> _interests = ['هندسة', 'طب', 'علوم', 'إدارة واقتصاد'];
  final List<String> _governorates = ['بغداد', 'البصرة', 'أربيل', 'النجف', 'كربلاء'];

  // Smart resolution for Sector (Public vs Private)
  bool get effectiveIsPrivate {
    return widget.isPrivate;
  }

  // Smart resolution for Shift
  StudyShift get effectiveShift {
    if (widget.shift != null) return widget.shift!;
    if (widget.title.contains('موازي')) return StudyShift.parallel;
    if (widget.title.contains('مسائي')) return StudyShift.evening;
    return StudyShift.morning;
  }

  // Rule matrix for displaying tuition fees
  bool get shouldShowCost {
    if (effectiveIsPrivate) {
      // Private (أهلي): Morning & Evening both require fees
      return true;
    } else {
      // Public (حكومي): Free for Morning, paid for Night & Parallel
      return effectiveShift == StudyShift.evening || effectiveShift == StudyShift.parallel;
    }
  }

  @override
  void dispose() {
    _gpaController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final double? userGpa = double.tryParse(_gpaController.text.trim());

    if (userGpa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال معدل صحيح')),
      );
      return;
    }

    final List<CollegeModel> allColleges = _getMockColleges();

    final results = allColleges.where((college) {
      // 1. Sector Filter
      if (college.isPrivate != effectiveIsPrivate) return false;

      // 2. Governorate Filter
      if (_selectedGovernorate != null && _selectedGovernorate!.isNotEmpty) {
        if (college.city != _selectedGovernorate) return false;
      }

      // 3. Interest Filter
      if (_selectedInterest != null && _selectedInterest!.isNotEmpty) {
        final matchesDept = college.departments.any((d) => d.contains(_selectedInterest!));
        final matchesCareer = college.careerFields.any((c) => c.contains(_selectedInterest!));
        if (!matchesDept && !matchesCareer) return false;
      }

      // 4. Shift Availability Filter
      final ShiftInfo? shiftData = college.getShift(effectiveShift);
      if (shiftData == null) return false;

      // 5. GPA Threshold Filter
      return userGpa >= shiftData.requiredGpa;
    }).toList();
    if(widget.title=='الانسيابية'){
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => StreamlinedFormScreen(availableColleges: results,),
        ),
      );
    }else{
      // Navigate to Minimum Limits Result Screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MinimumLimitsScreen(
            title: 'نتائج الحدود الدنيا',
            mode:effectiveIsPrivate?
                MinimumLimitsMode.privateSearch: 
                MinimumLimitsMode.publicSearch, // or privateSearch / minimumLimits
            userGpa: userGpa,
            initialColleges: results, // Pass the list here
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1B4980);
    const Color backgroundColor = Color(0xFFE3EBF5);
    const Color buttonColor = Color(0xFF0F2C4D);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // --- TOP BAR ---
            Container(
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 6,
                bottom: 16,
                left: 12,
                right: 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // --- FORM AREA ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أدخل البيانات التالية للبحث',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // GPA Input
                      TextField(
                        controller: _gpaController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'المعدل',
                          hintText: 'مثال: 85.5',
                          prefixIcon: const Icon(Icons.percent_rounded, color: primaryColor, size: 22),
                          labelStyle: const TextStyle(color: primaryColor, fontFamily: 'Cairo', fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFF7FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD0DBE8), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryColor, width: 2.0),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Interest Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedInterest,
                        alignment: Alignment.centerRight,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 26),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: 'اهتمامك',
                          prefixIcon: const Icon(Icons.school_outlined, color: primaryColor, size: 22),
                          labelStyle: const TextStyle(color: primaryColor, fontFamily: 'Cairo', fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFF7FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD0DBE8), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryColor, width: 2.0),
                          ),
                        ),
                        items: _interests.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                        onChanged: (value) => setState(() => _selectedInterest = value),
                      ),

                      const SizedBox(height: 20),

                      // Governorate Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedGovernorate,
                        alignment: Alignment.centerRight,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 26),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: 'المحافظة',
                          prefixIcon: const Icon(Icons.location_on_outlined, color: primaryColor, size: 22),
                          labelStyle: const TextStyle(color: primaryColor, fontFamily: 'Cairo', fontSize: 14),
                          filled: true,
                          fillColor: const Color(0xFFF7FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD0DBE8), width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: primaryColor, width: 2.0),
                          ),
                        ),
                        items: _governorates.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                        onChanged: (value) => setState(() => _selectedGovernorate = value),
                      ),

                      const SizedBox(height: 36),

                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            elevation: 2,
                            shadowColor: buttonColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _performSearch,
                          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                          label: const Text(
                            'بحث',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CollegeModel> _getMockColleges() {
    return [
      const CollegeModel(
        id: '1',
        name: 'كلية الطب',
        universityName: 'جامعة بغداد',
        city: 'بغداد',
        isPrivate: false,
        shiftOptions: [
          ShiftInfo(shift: StudyShift.morning, requiredGpa: 98.5, cost: 0),
          ShiftInfo(shift: StudyShift.parallel, requiredGpa: 96.0, cost: 3500000),
        ],
        logoUrl: '',
        overview: '',
        careerFields: ['طب'],
        establishedYear: '1927',
        recognitionDocNumber: '101',
        departments: ['الطب العام'],
        latitude: 0,
        longitude: 0,
      ),
      const CollegeModel(
        id: '2',
        name: 'كلية الهندسة - قسم المدني',
        universityName: 'جامعة دجلة الأهلية',
        city: 'بغداد',
        isPrivate: true,
        shiftOptions: [
          ShiftInfo(shift: StudyShift.morning, requiredGpa: 72.0, cost: 2500000),
          ShiftInfo(shift: StudyShift.evening, requiredGpa: 68.0, cost: 2500000),
        ],
        logoUrl: '',
        overview: '',
        careerFields: ['هندسة'],
        establishedYear: '2010',
        recognitionDocNumber: '202',
        departments: ['هندسة البناء والانشاءات'],
        latitude: 0,
        longitude: 0,
      ),
      const CollegeModel(
        id: 'col_02',
        name: 'كلية طب الأسنان',
        universityName: 'جامعة الفراهيدي الأهلية',
        city: 'بغداد',
        isPrivate: true,
        logoUrl: '',
        overview: 'كلية طب الأسنان في جامعة الفراهيدي الأهلية.',
        careerFields: ['عيادات الأسنان', 'مراكز التجميل'],
        establishedYear: '2012',
        recognitionDocNumber: '202/2012',
        departments: ['طب وجراحة الفم والأسنان'],
        latitude: 33.2800,
        longitude: 44.3900,
        shiftOptions: [
          ShiftInfo(shift: StudyShift.morning, requiredGpa: 80.0, cost: 8500000),
          ShiftInfo(shift: StudyShift.evening, requiredGpa: 78.0, cost: 9000000),
        ],
      ),
    ];
  }
}

// --- NEW SCREEN: MINIMUM LIMITS RESULT SCREEN ---
class MinimumLimitsResultScreen extends StatelessWidget {
  final String title;
  final List<CollegeModel> colleges;
  final StudyShift effectiveShift;
  final bool shouldShowCost;

  const MinimumLimitsResultScreen({
    super.key,
    required this.title,
    required this.colleges,
    required this.effectiveShift,
    required this.shouldShowCost,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1B4980);
    const Color backgroundColor = Color(0xFFE3EBF5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // --- TOP BAR ---
            Container(
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 6,
                bottom: 16,
                left: 12,
                right: 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'نتائج الحدود الدنيا - $title',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // --- CONTENT AREA ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عدد الكليات المتاحة: (${colleges.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: colleges.isEmpty
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'لا توجد كليات مطابقة للشروط',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: colleges.length,
                              itemBuilder: (context, index) {
                                final college = colleges[index];
                                final shiftData = college.getShift(effectiveShift)!;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 1,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    title: Text(
                                      college.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                        fontSize: 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${college.universityName} - ${college.city}',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'الحد الأدنى: ${shiftData.requiredGpa}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                            fontFamily: 'Cairo',
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (shouldShowCost && shiftData.cost > 0)
                                          Text(
                                            'القسط: ${shiftData.cost} د.ع',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}