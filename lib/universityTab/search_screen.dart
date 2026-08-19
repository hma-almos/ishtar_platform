import 'package:flutter/material.dart';
import 'package:ishtar_platform/models/college_model.dart';

class SearchScreen extends StatefulWidget {
  final String title;

  const SearchScreen({
    super.key,
    this.title = 'البحث',
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  // Categories list
  final List<String> _categories = [
    'الكل',
    'بغداد',
    'بابل',
    'البصرة',
  ];

  // Dummy Dataset using CollegeModel with ShiftInfo
  final List<CollegeModel> _allColleges = [
    const CollegeModel(
      id:1,
      name: 'كلية الطب البشري',
      universityName: 'جامعة بغداد',
      city: 'بغداد',
      isPrivate: false,
      shiftOptions: [
        ShiftInfo(shift: StudyShift.morning, requiredGpa: 99.1, cost: 0),
        ShiftInfo(shift: StudyShift.parallel, requiredGpa: 97.0, cost: 3500000),
      ],
      logoUrl: '',
      overview: 'كلية الطب البشري في جامعة بغداد أعرق الكليات الطبية.',
      careerFields: ['مستشفيات', 'عيادات خاصة', 'مراكز بحثية'],
      establishedYear: '1927',
      recognitionDocNumber: '101/2000',
      departments: ['الطب العام', 'الجراحة', 'الأطفال'],
      latitude: 33.3128,
      longitude: 44.3615,      
    ),
    const CollegeModel(
      id: 2,
      name: 'كلية الهندسة - قسم البرمجيات',
      universityName: 'الجامعة التكنولوجية',
      city: 'بغداد',
      isPrivate: false,
      shiftOptions: [
        ShiftInfo(shift: StudyShift.morning, requiredGpa: 88.5, cost: 0),
        ShiftInfo(shift: StudyShift.evening, requiredGpa: 82.0, cost: 1500000),
      ],
      logoUrl: '',
      overview: 'تعنى بتأهيل مهندسي البرمجيات والذكاء الاصطناعي.',
      careerFields: ['تطوير التطبيقات', 'إدارة الشبكات', 'الأمن السيبراني'],
      establishedYear: '1975',
      recognitionDocNumber: '102/2001',
      departments: ['هندسة البرمجيات', 'هندسة الحواسيب'],
      latitude: 33.3152,
      longitude: 44.4468,      
    ),
    const CollegeModel(
      id: 3,
      name: 'كلية الهندسة',
      universityName: 'جامعة بابل',
      city: 'بابل',
      isPrivate: false,
      shiftOptions: [
        ShiftInfo(shift: StudyShift.morning, requiredGpa: 85.5, cost: 0),
      ],
      logoUrl: '',
      overview: 'تعتبر كلية الهندسة من الكليات الرائدة في المحافظة.',
      careerFields: ['التصميم الهندسي', 'إدارة المشاريع'],
      establishedYear: '1993',
      recognitionDocNumber: '4512',
      departments: ['هندسة المدني', 'هندسة الكهرباء', 'هندسة الميكانيك'],
      latitude: 32.4682,
      longitude: 44.4305,
      
    ),
    const CollegeModel(
      id: 4,
      name: 'كلية الصيدلة',
      universityName: 'جامعة البصرة',
      city: 'البصرة',
      isPrivate: false,
      shiftOptions: [
        ShiftInfo(shift: StudyShift.morning, requiredGpa: 97.8, cost: 0),
        ShiftInfo(shift: StudyShift.parallel, requiredGpa: 95.0, cost: 3000000),
      ],
      logoUrl: '',
      overview: 'تخريج صيدلانيين متميزين لدعم القطاع الصحي.',
      careerFields: ['المستشفيات', 'الصيدليات', 'مصانع الأدوية'],
      establishedYear: '1999',
      recognitionDocNumber: '304/2005',
      departments: ['الصيدلانيات', 'الكيمياء الصيدلانية'],
      latitude: 30.5081,
      longitude: 47.7835,      
    ),
    const CollegeModel(
      id: 5,
      name: 'كلية طب الأسنان',
      universityName: 'جامعة المستنصرية',
      city: 'بغداد',
      isPrivate: false,
      shiftOptions: [
        ShiftInfo(shift: StudyShift.morning, requiredGpa: 98.3, cost: 0),
      ],
      logoUrl: '',
      overview: 'تقديم أفضل الخدمات والتعليم في جراحة وطب الأسنان.',
      careerFields: ['عيادات الأسنان', 'المستشفيات العامة'],
      establishedYear: '2000',
      recognitionDocNumber: '505/2010',
      departments: ['صناعة الأسنان', 'جراحة الفك والأسنان'],
      latitude: 33.3386,
      longitude: 44.3939,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1B4980);
    const Color backgroundColor = Color(0xFFE3EBF5);

    // Filter Logic matching query and selected city
    final filteredResults = _allColleges.where((college) {
      final queryLower = _searchQuery.toLowerCase();
      final matchesQuery = college.name.toLowerCase().contains(queryLower) ||
          college.universityName.toLowerCase().contains(queryLower) ||
          college.departments.any((dep) => dep.toLowerCase().contains(queryLower));

      final matchesCategory =
          _selectedCategory == 'الكل' || college.city == _selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // --- TOP HEADER WITH SEARCH FIELD ---
            Container(
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 6,
                bottom: 20,
                left: 16,
                right: 16,
              ),
              child: Column(
                children: [
                  // App Bar Navigation
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
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
                      const SizedBox(width: 48), // Spacer Balance
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Search TextField
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن كليّة، قسم، أو جامعة...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF8A9FB8),
                          fontFamily: 'Cairo',
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: Color(0xFF8A9FB8),
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- CITY FILTER CHIPS ---
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? primaryColor
                              : primaryColor.withOpacity(0.15),
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : primaryColor,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- SEARCH RESULTS LIST / EMPTY STATE ---
            Expanded(
              child: filteredResults.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD6E3F2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 54,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'لا توجد نتائج مطابقة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'تأكد من كتابة اسم الكلية أو القسم بشكل صحيح',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B82A0),
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredResults.length,
                      itemBuilder: (context, index) {
                        final college = filteredResults[index];

                        // Get minimum required GPA among available shifts
                        final minGpa = college.shiftOptions.isNotEmpty
                            ? college.shiftOptions
                                .map((s) => s.requiredGpa)
                                .reduce((a, b) => a < b ? a : b)
                            : 0.0;

                        return GestureDetector(
                          onTap: () {
                            // TODO: Navigate to College Detail Screen passing `college`
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // College Icon / Badge
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F1FA),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.school_rounded,
                                    color: primaryColor,
                                    size: 22,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // College Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        college.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${college.universityName} • ${college.city}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF5A79A0),
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // GPA Score Tag (Shows minimum starting GPA)
                                if (minGpa > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F4F8),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.12),
                                      ),
                                    ),
                                    child: Text(
                                      'من %$minGpa',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        fontFamily: 'Cairo',
                                      ),
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
    );
  }
}