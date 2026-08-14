import 'package:flutter/material.dart';
import 'custom_bottom_nav_bar.dart'; // Import your custom bottom bar widget
import 'universityTab/universities_screen.dart';   // Index 0

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  // Active selected tab index (starts at 0 for 'الجامعات')
  int _selectedIndex = 0;

  // List of screens corresponding to bottom nav tabs
  final List<Widget> _pages = const [
    UniversitiesScreen(),               // Index 0
    _PlaceholderPage(title: 'الكتب'),   // Index 1
    _PlaceholderPage(title: 'الرئيسية'), // Index 2
    _PlaceholderPage(title: 'الاساتذة'), // Index 3
    _PlaceholderPage(title: 'المزيد'),   // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1B4980);
    const Color backgroundColor = Color(0xFFE3EBF5);

    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // --- SHARED GLOBAL HEADER ---
          Container(
            color: primaryColor,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8, // Safe area padding
              bottom: 12,
              left: 12,
              right: 12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // --- DYNAMIC BODY CONTENT ---
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),

      // --- SHARED CUSTOM BOTTOM NAV BAR ---
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// Temporary placeholder page for coming-soon tabs
class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'صفحة $title (قريباً)',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B4980),
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}