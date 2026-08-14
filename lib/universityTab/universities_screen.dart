import 'package:flutter/material.dart';
import 'package:ishtar_platform/universityTab/admission_search_screen.dart';
import 'package:ishtar_platform/universityTab/application_channels_screen.dart';
import 'package:ishtar_platform/universityTab/equivalent_departments_screen.dart';
import 'package:ishtar_platform/universityTab/minimum_limits_screen.dart';
import 'package:ishtar_platform/universityTab/search_screen.dart';

class UniversitiesScreen extends StatelessWidget {
  final double navBarHeight;
  const UniversitiesScreen({super.key, this.navBarHeight = 80});

  @override
  Widget build(BuildContext context) {
    // Data lists for items
    final List<_GridItemData> publicItems = [
      const _GridItemData(title: 'التقديم', icon: Icons.wb_sunny_rounded, color: Color(0xFFE65100)),
      // const _GridItemData(title: 'التقديم الموازي', icon: Icons.trending_up_rounded, color: Color(0xFF0288D1)),
      // const _GridItemData(title: 'التقديم المسائي', icon: Icons.nights_stay_rounded, color: Color(0xFF5E35B1)),
      const _GridItemData(title: 'الحدود الدنيا', icon: Icons.show_chart_rounded, color: Color(0xFF2E7D32)),
      const _GridItemData(title: 'الانسيابية', icon: Icons.format_list_bulleted_rounded, color: Color(0xFFD81B60)),
      const _GridItemData(title: 'قنوات التقديم', icon: Icons.post_add_rounded, color: Color(0xFF00897B)),
    ];

    final List<_GridItemData> privateItems = [
      const _GridItemData(title: 'التقديم', icon: Icons.wb_sunny_rounded, color: Color(0xFFE65100)),
      // const _GridItemData(title: 'التقديم المسائي', icon: Icons.nights_stay_rounded, color: Color(0xFF5E35B1)),
      const _GridItemData(title: 'الحدود الدنيا', icon: Icons.show_chart_rounded, color: Color(0xFF2E7D32)),
      // const _GridItemData(title: 'البحث عن قسم', icon: Icons.manage_search_rounded, color: Color(0xFF00ACC1)),
      const _GridItemData(title: 'الاقسام المناظرة', icon: Icons.tune_rounded, color: Color(0xFF8E24AA)),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: navBarHeight + 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: Public Universities ---
            const _SectionHeader(
              title: 'الجامعات الحكومية',
              icon: Icons.account_balance_rounded,
            ),
            const SizedBox(height: 12),
            _buildGrid(publicItems, isPublicSection: true),

            const SizedBox(height: 20),

            // --- SECTION 2: Private Universities ---
            const _SectionHeader(
              title: 'الجامعات الاهلية',
              icon: Icons.domain_rounded,
            ),
            const SizedBox(height: 12),
            _buildGrid(privateItems, isPublicSection: false),
          ],
        ),
      ),
    );
  }

  // --- 2-COLUMN GRID FIX ---
  Widget _buildGrid(List<_GridItemData> items, {required bool isPublicSection}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,     // Set to 2 columns
        crossAxisSpacing: 10,  // Space between columns
        mainAxisSpacing: 10,   // Space between rows
        mainAxisExtent: 72,    // Fixed height for each grid card
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _MenuItemGridCard(
          title: item.title,
          icon: item.icon,
          accentColor: item.color,
          onTap: () {
            if (item.title == 'الحدود الدنيا') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MinimumLimitsScreen(
                    title: item.title,
                    mode: isPublicSection
                        ? MinimumLimitsMode.publicSearch
                        : MinimumLimitsMode.privateSearch,
                  ),
                ),
              );
            } else if (item.title == 'قنوات التقديم') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ApplicationChannelsScreen(title: item.title),
                ),
              );
            } else if (item.title == "الاقسام المناظرة") {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EquivalentDepartmentsScreen(title: item.title),
                ),
              );
            } else if (item.title == "البحث عن قسم") {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchScreen(title: item.title),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdmissionSearchScreen(
                    title: item.title,
                    isPrivate: !isPublicSection,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

// Data holder for grid items
class _GridItemData {
  final String title;
  final IconData icon;
  final Color color;

  const _GridItemData({
    required this.title,
    required this.icon,
    required this.color,
  });
}

// --- SECTION HEADER ---
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1B4980);

    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}

// --- GRID CARD WIDGET ---
class _MenuItemGridCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color accentColor;
  final VoidCallback onTap;

  const _MenuItemGridCard({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                // 1. TEXT (Left side in RTL)
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4980),
                      fontFamily: 'Cairo',
                      height: 1.2,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 2. ICON BADGE (Right side in RTL)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}