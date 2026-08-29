import 'package:flutter/material.dart';

class SubjectsGridBody extends StatelessWidget {
  final Function(String subjectTitle)? onSubjectTap;
  final double bottomPadding;

  const SubjectsGridBody({
    Key? key,
    this.onSubjectTap,
    this.bottomPadding = 90.0,
  }) : super(key: key);

  static const Color primaryNavy = Color(0xFF16487D);
  static const Color backgroundLight = Color(0xFFE8EEF8);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> subjects = [
      {'title': 'اسلامية', 'icon': Icons.menu_book_rounded},
      {'title': 'الرياضيات', 'icon': Icons.calculate_rounded},
      {'title': 'الكيمياء', 'icon': Icons.science_rounded},
      {'title': 'الاحياء', 'icon': Icons.coronavirus_rounded},
      {'title': 'اللغة العربية', 'textIcon': 'أ ب ج د'},
      {'title': 'الفيزياء', 'textIcon': 'E=mc²'},
      {'title': 'اللغة الانجليزية', 'textIcon': 'En'},
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: backgroundLight,
        child: GridView.builder(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 24.0,
            bottom: bottomPadding,
          ),
          itemCount: subjects.length,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final item = subjects[index];
            return _buildSubjectCard(
              title: item['title'] as String,
              icon: item['icon'] as IconData?,
              textIcon: item['textIcon'] as String?,
              onTap: () {
                if (onSubjectTap != null) {
                  onSubjectTap!(item['title'] as String);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubjectCard({
    required String title,
    IconData? icon,
    String? textIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1D548F),
            primaryNavy,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.12),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: icon != null
                        ? Icon(
                            icon,
                            color: Colors.white,
                            size: 48,
                          )
                        : Text(
                            textIcon ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}