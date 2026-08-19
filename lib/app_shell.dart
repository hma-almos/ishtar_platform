import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ishtar_platform/notification_screen.dart';
import 'package:ishtar_platform/profile_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'custom_bottom_nav_bar.dart'; // Import your custom bottom bar widget
import 'universityTab/universities_screen.dart';   // Index 0
import 'package:path/path.dart' as p;


class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  // Active selected tab index (starts at 0 for 'الجامعات')
  int _selectedIndex = 0;
  File? _profileImage;

  // List of screens corresponding to bottom nav tabs
  final List<Widget> _pages =  [
    UniversitiesScreen(),               // Index 0
    _PlaceholderPage(title: 'الكتب'),   // Index 1
    _PlaceholderPage(title: 'الرئيسية'), // Index 2
    _PlaceholderPage(title: 'الاساتذة'), // Index 3
    _PlaceholderPage(title: 'المزيد'),   // Index 4
  ];
  @override
void initState() {
  super.initState();
  _loadExistingProfileImage();
}

Future<void> _loadExistingProfileImage() async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final File savedImage = File(p.join(appDocDir.path, 'user_profile_avatar.jpg'));

  if (await savedImage.exists()) {
    setState(() {
      _profileImage = savedImage;
    });
  }
}

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
              left: 16,
              right: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Notifications Icon (Left side in LTR / Right side in RTL)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  onPressed: () {
                     Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NotificationScreen(),
                ),
              );
                  },
                ),

                // Profile Section: Avatar + User Name
                GestureDetector(
                  onTap: () {
                   Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'أحمد علي', // Replace with user's dynamic name variable
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1.5),
                        ),
                        child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!) as ImageProvider
                            : const AssetImage('assets/images/user_avatar.png'),
                          ),
                      ),
                    ],
                  ),
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