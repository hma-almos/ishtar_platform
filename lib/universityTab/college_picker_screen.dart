import 'package:flutter/material.dart';
import 'package:ishtar_platform/models/college_model.dart';

class CollegePickerScreen extends StatefulWidget {
  final String title;
  final List<CollegeModel> availableColleges;
  final List<CollegeModel> initiallySelectedColleges;

  const CollegePickerScreen({
    super.key,
    this.title = 'اختيار الكليات',
    required this.availableColleges,
    this.initiallySelectedColleges = const [],
  });

  @override
  State<CollegePickerScreen> createState() => _CollegePickerScreenState();
}

class _CollegePickerScreenState extends State<CollegePickerScreen> {
  late Set<int> _selectedCollegeIds;
  late List<CollegeModel> _selectedColleges;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill selection set with initially selected colleges
    _selectedColleges = List.from(widget.initiallySelectedColleges);
    _selectedCollegeIds = widget.initiallySelectedColleges.map((c) => c.id).toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(CollegeModel college) {
    setState(() {
      if (_selectedCollegeIds.contains(college.id)) {
        _selectedCollegeIds.remove(college.id);
        _selectedColleges.removeWhere((item) => item.id == college.id);
      } else {
        _selectedCollegeIds.add(college.id);
        _selectedColleges.add(college);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B4980);
    const backgroundColor = Color(0xFFE3EBF5);

    // Filter available colleges by search query
    final filteredColleges = widget.availableColleges.where((college) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return college.name.toLowerCase().contains(query) ||
          college.universityName.toLowerCase().contains(query) ||
          college.city.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(), // Cancels without changes
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
            // --- SEARCH BAR HEADER ---
            Container(
              padding: const EdgeInsets.all(12),
              color: primaryColor,
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF133660),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Cairo'),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'بحث باسم الكلية أو الجامعة...',
                    hintStyle: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Cairo'),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            // --- LIST OF COLLEGES ---
            Expanded(
              child: filteredColleges.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد كليات مطابقة للبحث',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredColleges.length,
                      itemBuilder: (context, index) {
                        final college = filteredColleges[index];
                        final isSelected = _selectedCollegeIds.contains(college.id);

                        return Material(
                          color: Colors.transparent,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor.withOpacity(0.06) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? primaryColor : Colors.transparent,
                                width: 1.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _toggleSelection(college),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    // Custom Checkbox
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isSelected ? primaryColor : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? primaryColor : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                                          : null,
                                    ),

                                    const SizedBox(width: 14),

                                    // College Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            college.name,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? primaryColor : const Color(0xFF0F2C4D),
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${college.universityName} • ${college.city}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.black54,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // --- BOTTOM CONFIRMATION BUTTON ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    // Pop back returning ONLY selected colleges
                    Navigator.of(context).pop(_selectedColleges);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'تأكيد الاختيار (${_selectedCollegeIds.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Cairo',
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