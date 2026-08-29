import 'package:flutter/material.dart';
import 'package:ishtar_platform/models/college_model.dart';
import 'package:ishtar_platform/universityTab/college_details_screen.dart';
import 'package:ishtar_platform/widgets/college_card_tile.dart';

enum MinimumLimitsMode {
  minimumLimits,
  publicSearch,
  privateSearch,
}

class MinimumLimitsScreen extends StatefulWidget {
  final String title;
  final MinimumLimitsMode mode;
  final double? userGpa;
  final Future<List<CollegeModel>>? initialColleges;
  final StudyShift? initialShift;

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
  
  // Asynchronous API call definition
  late Future<List<CollegeModel>> _collegesFuture;

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

    // Initialize API request if external list wasn't provided
    if (widget.initialColleges != null) {
      _collegesFuture = Future.value(widget.initialColleges);
    } 
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters loaded colleges based on user controls
  List<CollegeModel> _applyFilters(List<CollegeModel> rawList) {
    return rawList.where((college) {
      // 1. Strict Mode Filter: Public vs Private
      if (widget.mode == MinimumLimitsMode.publicSearch && college.isPrivate) {
        return false;
      }
      if (widget.mode == MinimumLimitsMode.privateSearch && !college.isPrivate) {
        return false;
      }

      // 2. Parallel shift check
      if (_selectedShift == StudyShift.parallel && college.isPrivate) {
        return false;
      }

      // 3. Extract active shift details
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
          college.departments.any((dep) => dep.name.contains(_selectedSpecialty!));

      return matchesGovernorate && matchesSpecialty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1B4980);
    const Color backgroundColor = Color(0xFFE3EBF5);
    const Color filterBgColor = Color(0xFF133660);

    final bool hasActiveFilters = _selectedSpecialty != null ||
        _selectedGovernorate != null ||
        _searchQuery.isNotEmpty;

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

            // --- LIST CONTENT WITH FUTUREBUILDER ---
            Expanded(
              child: FutureBuilder<List<CollegeModel>>(
                future: _collegesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'حدث خطأ أثناء تحميل البيانات: ${snapshot.error}',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  final allColleges = snapshot.data ?? [];
                  final filteredColleges = _applyFilters(allColleges);

                  if (filteredColleges.isEmpty) {
                    return Center(
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
                    );
                  }

                  return ListView.builder(
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
                                builder: (context) =>
                                    CollegeDetailsScreen(college: college),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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