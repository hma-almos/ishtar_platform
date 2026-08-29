import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  // Navigation items ordered from left (0) to right (4) to match LTR coordinates
  final List<NavItemData> _items = const [
    NavItemData(icon: Icons.school_rounded, label: 'الجامعات'),
    NavItemData(icon: Icons.menu_book_rounded, label: 'الكتب'),
    // NavItemData(icon: Icons.home_rounded, label: 'الرئيسية'),
    // NavItemData(icon: Icons.badge_rounded, label: 'الاساتذة'),
    NavItemData(icon: Icons.more_horiz_rounded, label: 'المزيد'),
  ];

  @override
  Widget build(BuildContext context) {
    const double barHeight = 80.0;
    const Color barBgColor = Color(0xFF1B4980);
    const Color indicatorColor = Color(0xFF0F2C4D);

    return Container(
      height: barHeight + 25,
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Background Bar Container
          Container(
            height: barHeight,
            color: barBgColor,
          ),

          // 2. Animated Sliding Active Highlight Box
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.fastOutSlowIn,
            alignment: Alignment(
              -1.0 + (widget.selectedIndex * (2.0 / (_items.length - 1))),
              -0.3,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / _items.length,
              child: Container(
                height: barHeight-20 ,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 3. Navigation Icons & Labels (Forced LTR to keep row and alignment in sync)
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              height: barHeight + 20,
              child: Row(
                children: List.generate(_items.length, (index) {
                  final isSelected = widget.selectedIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.onItemTapped(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        // Move selected item up to align inside the active box
                        transform: Matrix4.translationValues(
                          0,
                          isSelected ? -8.0 : 0.0,
                          0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon enlarges slightly and centers vertically when label is hidden
                            Icon(
                              _items[index].icon,
                              color: Colors.white,
                              size: isSelected ? 34 : 26,
                            ),
                            
                            // Hide text label completely when selected; show when unselected
                            if (!isSelected) ...[
                              const SizedBox(height: 4),
                              Text(
                                _items[index].label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavItemData {
  final IconData icon;
  final String label;

  const NavItemData({required this.icon, required this.label});
}