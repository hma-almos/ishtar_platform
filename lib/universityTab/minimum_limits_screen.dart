import 'package:flutter/material.dart';
import 'package:ishtar_platform/models/college_model.dart';
import 'package:ishtar_platform/universityTab/college_details_screen.dart';
import 'package:ishtar_platform/widgets/college_card_tile.dart';

/// Define the 3 Use Cases for the screen
enum MinimumLimitsMode {
  minimumLimits, // 1. General Minimum Limits list
  publicSearch,  // 2. Public University admission search results
  privateSearch, // 3. Private University admission search results
}

class MinimumLimitsScreen extends StatefulWidget {
  final String title;
  final MinimumLimitsMode mode;
  final double? userGpa;
  final List<CollegeModel>? initialColleges; // Added for reusable search results
  final StudyShift? initialShift; // Optional pre-selected shift

  const MinimumLimitsScreen({
    super.key,
    this.title = 'الحدود الدنيا',
    this.mode = MinimumLimitsMode.minimumLimits,
    this.userGpa,
    this.initialColleges,
    this.initialShift,
  });

  @override
  State<MinimumLimitsScreen> createState() => _MinimumLimitsScreenState();
}

class _MinimumLimitsScreenState extends State<MinimumLimitsScreen> {
  bool _showFilters = false;

  // Selected filter states
  String? _selectedSpecialty;
  String? _selectedGovernorate;
  String _searchQuery = '';
  late StudyShift _selectedShift;

  final TextEditingController _searchController = TextEditingController();

  // Default Mock Dataset (Fallback if no external list is passed)
  final List<CollegeModel> _defaultColleges = [
    const CollegeModel(
      id: 'col_01',
      name: 'كلية الطب البشري',
      universityName: 'جامعة بغداد',
      city: 'بغداد',
      isPrivate: false,
      logoUrl: '',
      overview: 'كلية الطب البشري في جامعة بغداد أعرق الكليات الطبية.',
      careerFields: ['مستشفيات', 'عيادات خاصة'],
      establishedYear: '1927',
      recognitionDocNumber: '101/2000',
      departments: ['الطب العام', 'الجراحة'],
      latitude: 33.3128,
      longitude: 44.3615,
      shiftOptions: [
        ShiftInfo(shift: StudyShift.morning, requiredGpa: 99.1, cost: 0),
        ShiftInfo(shift: StudyShift.parallel, requiredGpa: 96.5, cost: 3500000),
        ShiftInfo(shift: StudyShift.evening, requiredGpa: 94.0, cost: 4500000),
      ],
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
    const CollegeModel(
      id: 'col_03',
      name: 'كلية الهندسة - قسم البرمجيات',
      universityName: 'الجامعة التكنولوجية',
      city: 'بغداد',
      isPrivate: false,
      logoUrl: '',
      overview: 'تعنى بتأهيل مهندسي البرمجيات والذكاء الاصطناعي.',
      careerFields: ['تطوير التطبيقات', 'الأمن السيبراني'],
      establishedYear: '1975',
      recognitionDocNumber: '102/2001',
      departments: ['هندسة البرمجيات'],
      latitude: 33.3152,
      longitude: 44.4468,
      shiftOptions: [
        ShiftInfo(shift: StudyShift.morning, requiredGpa: 88.5, cost: 0),
        ShiftInfo(shift: StudyShift.parallel, requiredGpa: 84.0, cost: 1500000),
        ShiftInfo(shift: StudyShift.evening, requiredGpa: 80.0, cost: 2000000),
      ],
    ),
  ];

  /// Resolves which dataset to use (passed external list or default mock data)
  List<CollegeModel> get _collegesSource =>
      widget.initialColleges ?? _defaultColleges;

  @override
  void initState() {
    super.initState();
    // Safety check: Private education doesn't support Parallel shift
    if (widget.mode == MinimumLimitsMode.privateSearch &&
        widget.initialShift == StudyShift.parallel) {
      _selectedShift = StudyShift.morning;
    } else {
      _selectedShift = widget.initialShift ?? StudyShift.morning;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1B4980);
    const Color backgroundColor = Color(0xFFE3EBF5);
    const Color filterBgColor = Color(0xFF133660);

    final bool hasActiveFilters = _selectedSpecialty != null ||
        _selectedGovernorate != null ||
        _searchQuery.isNotEmpty;

    final filteredColleges = _collegesSource.where((college) {
      // 1. Strict Mode Filter: Public vs Private
      if (widget.mode == MinimumLimitsMode.publicSearch && college.isPrivate) {
        return false;
      }
      if (widget.mode == MinimumLimitsMode.privateSearch && !college.isPrivate) {
        return false;
      }

      // 2. Parallel shift check: Only public universities offer Parallel
      if (_selectedShift == StudyShift.parallel && college.isPrivate) {
        return false;
      }

      // 3. Extract active shift details from model
      final activeShift = college.getShift(_selectedShift);
      if (activeShift == null) return false;

      // 4. User GPA Eligibility Check
      if (widget.userGpa != null && activeShift.requiredGpa > widget.userGpa!) {
        return false;
      }

      // 5. Text Search Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = college.name.toLowerCase().contains(query);
        final matchesUni = college.universityName.toLowerCase().contains(query);
        if (!matchesName && !matchesUni) return false;
      }

      // 6. Dropdown Filters
      final matchesGovernorate = _selectedGovernorate == null ||
          college.city == _selectedGovernorate;

      final matchesSpecialty = _selectedSpecialty == null ||
          college.name.contains(_selectedSpecialty!) ||
          college.departments.any((dep) => dep.contains(_selectedSpecialty!));

      return matchesGovernorate && matchesSpecialty;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // --- TOP HEADER APP BAR ---
            Container(
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
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
                bottom: 14,
                left: 12,
                right: 12,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          _getScreenTitle(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            if (hasActiveFilters)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFB300),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // --- SHIFT SELECTION CHIPS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTypeChip('الصباحي (العام)', StudyShift.morning),
                      // Hide Parallel shift completely for Private Colleges Search Mode
                      if (widget.mode != MinimumLimitsMode.privateSearch) ...[
                        const SizedBox(width: 6),
                        _buildTypeChip('الموازي', StudyShift.parallel),
                      ],
                      const SizedBox(width: 6),
                      _buildTypeChip('المسائي', StudyShift.evening),
                    ],
                  ),

                  // --- EXPANDABLE FILTER PANEL ---
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(
                          top: 14, bottom: 4, left: 8, right: 8),
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: filterBgColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontFamily: 'Cairo'),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'بحث باسم الكلية أو الجامعة...',
                                hintStyle: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    fontFamily: 'Cairo'),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.white70, size: 18),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear,
                                            color: Colors.white70, size: 16),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFilterDropdown(
                                  hint: 'الاختصاص',
                                  value: _selectedSpecialty,
                                  items: ['هندسة', 'طب', 'علوم', 'صيدلة'],
                                  bgColor: filterBgColor,
                                  onChanged: (val) => setState(
                                      () => _selectedSpecialty = val),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildFilterDropdown(
                                  hint: 'المحافظة',
                                  value: _selectedGovernorate,
                                  items: [
                                    'بغداد',
                                    'البصرة',
                                    'النجف',
                                    'كربلاء',
                                    'بابل'
                                  ],
                                  bgColor: filterBgColor,
                                  onChanged: (val) => setState(
                                      () => _selectedGovernorate = val),
                                ),
                              ),
                            ],
                          ),
                          if (hasActiveFilters) ...[
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedSpecialty = null;
                                  _selectedGovernorate = null;
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                              child: const Text(
                                'مسح التصفية',
                                style: TextStyle(
                                  color: Color(0xFFFFD54F),
                                  fontSize: 12,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                    crossFadeState: _showFilters
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),

            // --- LIST CONTENT ---
            Expanded(
              child: filteredColleges.isEmpty
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
                                Icons.filter_alt_off_rounded,
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
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: filteredColleges.length,
                      itemBuilder: (context, index) {
                        final college = filteredColleges[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CollegeCardTile(
                            college: college,
                            selectedShift: _selectedShift,
                            userGpa: widget.userGpa,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CollegeDetailsScreen(college: college),
                                ),
                              );
                            },
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

  // Application shift selection chips
  Widget _buildTypeChip(String label, StudyShift shift) {
    final bool isSelected = _selectedShift == shift;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Cairo',
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF1B4980) : Colors.white,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFFFD54F),
      backgroundColor: const Color(0xFF133660),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _selectedShift = shift;
          });
        }
      },
    );
  }

  String _getScreenTitle() {
    switch (widget.mode) {
      case MinimumLimitsMode.publicSearch:
        return 'القبول الحكومي';
      case MinimumLimitsMode.privateSearch:
        return 'القبول الأهلي والأقساط';
      case MinimumLimitsMode.minimumLimits:
      default:
        return widget.title;
    }
  }

  Widget _buildFilterDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Color bgColor,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value != null ? const Color(0xFFFFD54F) : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontFamily: 'Cairo',
            ),
          ),
          dropdownColor: bgColor,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 20,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Cairo',
          ),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}