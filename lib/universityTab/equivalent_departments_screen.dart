import 'package:flutter/material.dart';

class EquivalentDepartmentsScreen extends StatefulWidget {
  final String title;

  const EquivalentDepartmentsScreen({
    super.key,
    this.title = 'الأقسام المناظرة',
  });

  @override
  State<EquivalentDepartmentsScreen> createState() =>
      _EquivalentDepartmentsScreenState();
}

class _EquivalentDepartmentsScreenState
    extends State<EquivalentDepartmentsScreen> {
  String? _selectedVocationalDept;

  // Sample Vocational Departments List
  final List<String> _vocationalDepts = [
    'الصناعي - إلكترونيات وسيطرة',
    'التجاري - إدارة أعمال',
    'الزراعي - إنتاج نباتي',
    'الحاسوب وتكنولوجيا المعلومات',
    'الفنون التطبيقية - تصميم داخلي',
  ];

  // Sample Matching Departments Map (Simulating Backend Data)
  final Map<String, List<String>> _equivalentMap = {
    'الصناعي - إلكترونيات وسيطرة': [
      'هندسة الإلكترونيك والاتصالات',
      'هندسة الحاسوب',
      'هندسة التقنيات الكهربائية',
      'علوم الحاسوب',
    ],
    'التجاري - إدارة أعمال': [
      'إدارة الأعمال',
      'المحاسبة والعلوم المالية',
      'العلوم المصرفية',
      'إدارة المؤسسات الصحية',
    ],
    'الزراعي - إنتاج نباتي': [
      'كلية الهندسة الزراعية',
      'تقنيات الإنتاج النباتي',
      'علوم الأغذية',
    ],
    'الحاسوب وتكنولوجيا المعلومات': [
      'هندسة البرمجيات',
      'تكنولوجيا المعلومات (IT)',
      'الأمن السيبراني',
      'ذكاء الاصطناعي',
    ],
    'الفنون التطبيقية - تصميم داخلي': [
      'التصميم الداخلي والديكور',
      'الفنون الجميلة',
      'التصميم الجرافيكي',
    ],
  };

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1B4980);
    const Color backgroundColor = Color(0xFFE3EBF5);

    final List<String> currentMatches = _selectedVocationalDept != null
        ? (_equivalentMap[_selectedVocationalDept] ?? [])
        : [];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // --- TOP HEADER ---
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
                bottom: 16,
                left: 12,
                right: 12,
              ),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  // Screen Title
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

                  const SizedBox(width: 48), // Balance Spacer
                ],
              ),
            ),

            // --- CONTENT AREA ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. STYLIZED INSTRUCTION / RULES CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.12),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F1FA),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'يُسمح لخريجي الدراسة المهنية (الصناعي، التجاري، الزراعي، الفنون التطبيقية، والحاسوب) بالتقديم على أقسام مناظرة أو قريبة في الجامعات والكليات الأهلية. يكون القبول في الدراسات المسائية، أو الصباحي وفق "التعليم الحكومي الخاص" (الموازي) لبعض الفئات، بشرط ألا يقل معدل الطالب عن 60%.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2C4362),
                                fontFamily: 'Cairo',
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 2. VOCATIONAL DEPARTMENT DROPDOWN (القسم المهني)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedVocationalDept,
                        alignment: Alignment.centerRight,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: primaryColor,
                          size: 26,
                        ),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'القسم المهني',
                          prefixIcon: const Icon(
                            Icons.precision_manufacturing_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                          labelStyle: const TextStyle(
                            color: primaryColor,
                            fontFamily: 'Cairo',
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFD0DBE8),
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: primaryColor,
                              width: 2.0,
                            ),
                          ),
                        ),
                        items: _vocationalDepts.map((String dept) {
                          return DropdownMenuItem<String>(
                            value: dept,
                            child: Text(
                              dept,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedVocationalDept = value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 3. EQUIVALENT DEPARTMENTS RESULTS CONTAINER (الأقسام المناظرة)
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 180),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.alt_route_rounded,
                                color: Color(0xFFFFD54F),
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'الأقسام المناظرة المتاحة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            color: Colors.white24,
                            height: 24,
                            thickness: 1,
                          ),

                          if (_selectedVocationalDept == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              child: Center(
                                child: Text(
                                  'يرجى اختيار القسم المهني من القائمة أعلاه لعرض الأقسام المناظرة',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 10,
                              children: currentMatches.map((match) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: Color(0xFFFFD54F),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        match,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
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