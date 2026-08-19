import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ishtar_platform/models/city_model.dart';
import 'package:ishtar_platform/models/college_model.dart';
import 'package:ishtar_platform/universityTab/minimum_limits_screen.dart';
import 'package:ishtar_platform/universityTab/streamlined_form_screen.dart';

class AdmissionSearchScreen extends StatefulWidget {
  final String title;
  final bool isPrivate;
  final StudyShift? shift;
  final Future<List<CollegeModel>>? initialColleges;

  const AdmissionSearchScreen({
    super.key,
    required this.title,
    required this.isPrivate,
    this.shift,
    this.initialColleges,
  });

  @override
  State<AdmissionSearchScreen> createState() => _AdmissionSearchScreenState();
}

class _AdmissionSearchScreenState extends State<AdmissionSearchScreen> {
  final TextEditingController _gpaController = TextEditingController();

  // Set default selection to 'الكل'
  String? _selectedInterest = 'الكل';
  CityModel? _selectedGovernorate;
  bool _isLoading = false;

  // Interests & Governorates using CityModel
  final List<String> _interests = ['الكل', 'هندسة', 'طب', 'علوم', 'إدارة واقتصاد'];
  
  late final List<CityModel> _governorates = [
    const CityModel(name: 'الكل', distance: 0),
    ...CityModel.baseCities,
  ];

  @override
  void initState() {
    super.initState();
    _selectedGovernorate = _governorates.first;
  }

  bool get effectiveIsPrivate => widget.isPrivate;

  StudyShift get effectiveShift {
    if (widget.shift != null) return widget.shift!;
    if (widget.title.contains('موازي')) return StudyShift.parallel;
    if (widget.title.contains('مسائي')) return StudyShift.evening;
    return StudyShift.morning;
  }

  bool get shouldShowCost {
    if (effectiveIsPrivate) {
      return true;
    } else {
      return effectiveShift == StudyShift.evening || effectiveShift == StudyShift.parallel;
    }
  }

  @override
  void dispose() {
    _gpaController.dispose();
    super.dispose();
  }

  void _handleSearchSubmit() async {
    final double? userGpa = double.tryParse(_gpaController.text.trim());

    if (userGpa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال معدل صحيح')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Fetch raw list
      final List<CollegeModel>? rawColleges = await widget.initialColleges;
      final List<CollegeModel> allColleges = rawColleges ?? [];

      final bool isStreamlined = widget.title == 'الانسيابية';

      // 2. Perform local filtering
      final results = allColleges.where((college) {
        // Sector Filter
        if (college.isPrivate != effectiveIsPrivate) return false;

        // Governorate Filter
        if (_selectedGovernorate != null &&
            _selectedGovernorate!.name.isNotEmpty &&
            _selectedGovernorate!.name != 'الكل') {
          // STRICT FILTER: If NOT 'الانسيابية', filter out all other cities
          if (!isStreamlined && college.city != _selectedGovernorate!.name) {
            return false;
          }
        }

        // Interest Filter
        if (_selectedInterest != null &&
            _selectedInterest!.isNotEmpty &&
            _selectedInterest != 'الكل') {
          final matchesDept = college.departments
              .any((d) => d.contains(_selectedInterest!));
          final matchesCareer = college.careerFields
              .any((c) => c.contains(_selectedInterest!));
          if (!matchesDept && !matchesCareer) return false;
        }

        // Shift Availability Filter
        final ShiftInfo? shiftData = college.getShift(effectiveShift);
        if (shiftData == null) return false;

        // GPA Threshold Filter
        return userGpa >= shiftData.requiredGpa;
      }).toList();

      if (!mounted) return;

      // 3. Navigation & Sorting Logic
      if (isStreamlined) {
        final initialChoices=results;
        
        // PROXIMITY SORT: Only sort all cities by distance if a specific city was selected
        if (_selectedGovernorate != null && _selectedGovernorate!.name != 'الكل') {
          final proximityCities = CityModel.getCitiesSortedByProximity(_selectedGovernorate!);

          final Map<String, int> distanceLookup = {
            for (var city in proximityCities) city.name: city.distance,
          };

          initialChoices.sort((a, b) {
            final distA = distanceLookup[a.city] ?? 999999;
            final distB = distanceLookup[b.city] ?? 999999;
            return distA.compareTo(distB);
          });
        }

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StreamlinedFormScreen(
              availableColleges: initialChoices,
              initialChoices: results.sublist(0,20),
              maxChoices: 20,
            ),
          ),
        );
      } else {
        // STRICT RESULTS: Only colleges in the exact selected city are passed here
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MinimumLimitsScreen(
              title: 'نتائج الحدود الدنيا',
              mode: effectiveIsPrivate
                  ? MinimumLimitsMode.privateSearch
                  : MinimumLimitsMode.publicSearch,
              userGpa: userGpa,
              initialColleges: Future.value(results),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء معالجة البيانات: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

                      // Governorate Dropdown (Using CityModel)
                      DropdownButtonFormField<CityModel>(
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
                        items: _governorates
                            .map((item) => DropdownMenuItem<CityModel>(
                                  value: item,
                                  child: Text(item.name),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedGovernorate = value),
                      ),

                      const SizedBox(height: 36),

                      // Search Button / Loader
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            elevation: 2,
                            shadowColor: buttonColor.withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: _isLoading ? null : _handleSearchSubmit,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_rounded, color: Colors.white, size: 22),
                                    SizedBox(width: 8),
                                    Text(
                                      'بحث',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
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
}