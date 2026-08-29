import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ishtar_platform/Service/api_service.dart';
import 'package:ishtar_platform/Service/session.dart';
import 'package:ishtar_platform/books/books.dart';
import 'package:ishtar_platform/books/pdf_viewer_screen.dart';
import 'package:ishtar_platform/notification_screen.dart';
import 'package:ishtar_platform/profile_screen.dart';
import 'package:ishtar_platform/settings/settings.dart';
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
  int _selectedIndex = 0;
  File? _profileImage;
  String? name;

  // Define your pages list inside initState or build, or map callback here
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadAppBarUserData();
    final baseurl= ApiService().baseUrl;
    // Initialize the pages here to access BuildContext safely
    _pages = [
      const UniversitiesScreen(), // Index 0
      
      // Index 1: Subjects Grid with Offline PDF handling
      SubjectsGridBody(
        onSubjectTap: (subjectTitle) {
          // Map each subject name to its backend PDF URL
          final Map<String, String> backendPdfUrls = {
            'اسلامية': '$baseurl/pdfs/islamic.pdf',
            'الرياضيات': '$baseurl/pdfs/math.pdf',
          
            'الكيمياء': '$baseurl/pdfs/chemistry.pdf',
            'الاحياء': '$baseurl/pdfs/biology.pdf',
            'اللغة العربية': '$baseurl/pdfs/arabic.pdf',
            'الفيزياء': '$baseurl/pdfs/physics.pdf',
            'اللغة الانجليزية': '$baseurl/pdfs/english.pdf',
          };

          final url = backendPdfUrls[subjectTitle];

          if (url != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PdfOfflineViewerScreen(
                  title: subjectTitle,
                  pdfUrl: url,
                ),
              ),
            );
          }
        },
      ),
      
      // const _PlaceholderPage(title: 'الرئيسية'), // Index 2
      // const _PlaceholderPage(title: 'الاساتذة'), // Index 3
      StyledSettingsBody()   // Index 4
    ];
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
                  onTap: () async {
                  final bool? result = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );

                    // If the child screen popped with 'true', refresh the AppBar state
                    if (result == true) {
                      setState(() {
                        // Re-fetch or assign updated name/pic from Session or State
                        _loadAppBarUserData(); 
                      });
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Text(
                        name??'guest', // Replace with user's dynamic name variable
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

  void _loadAppBarUserData() {
    _loadExistingProfileImage();
    name=Session.name;
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