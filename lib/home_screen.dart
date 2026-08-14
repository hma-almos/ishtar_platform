import 'package:flutter/material.dart';
import 'package:ishtar_platform/universityTab/universities_screen.dart';
import 'custom_bottom_nav_bar.dart'; // import the widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  final List<Widget> _pages = const [
    UniversitiesScreen(),
    Center(child: Text('قادم قريبا')),
    Center(child: Text('قادم قريبا')),
    Center(child: Text('قادم قريبا')),
    Center(child: Text('قادم قريبا')),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, 
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: CustomBottomNavBar(
          selectedIndex: _currentIndex,
          onItemTapped: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}