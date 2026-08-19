import 'package:flutter/material.dart';
import 'package:ishtar_platform/models/city_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  String _selectedBranch = 'علمي';
  String _selectedGender = 'ذكر';
  String? _selectedGrade;
  CityModel? _selectedGovernorate;
  File? _profileImage;

  // App Theme Colors
  static const Color primaryColor = Color(0xFF134275);
  static const Color backgroundColor = Color(0xFFDEE6F2);
  static const Color fieldTextColor = Color(0xFF0D2D50);

  final List<String> _grades = [
    'الرابع الإعدادي',
    'الخامس الإعدادي',
    'السادس الإعدادي',
  ];

  final List<CityModel> _governorates = CityModel.baseCities;

  @override
  void initState() {
    super.initState();
    _loadExistingProfileImage();
  }

  // Load image on screen startup if it was saved previously
  Future<void> _loadExistingProfileImage() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final File savedImage = File(p.join(appDocDir.path, 'user_profile_avatar.jpg'));

    if (await savedImage.exists()) {
      setState(() {
        _profileImage = savedImage;
      });
    }
  }

  Future<void> _pickAndSaveImage() async {
    final ImagePicker picker = ImagePicker();

    // 1. Pick image from gallery
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    // 2. Get local app documents directory
    final Directory appDocDir = await getApplicationDocumentsDirectory();

    // 3. Define fixed filename & target path
    const String fixedFileName = 'user_profile_avatar.jpg';
    final String targetPath = p.join(appDocDir.path, fixedFileName);

    // Evict old image cache to trigger UI refresh instantly
    if (_profileImage != null) {
      await FileImage(_profileImage!).evict();
    }

    // 4. Overwrite/save the file to fixed path
    final File newImage = await File(pickedFile.path).copy(targetPath);

    setState(() {
      _profileImage = newImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 2,
          shadowColor: primaryColor.withOpacity(0.3),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              letterSpacing: 0.3,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28.0, vertical: 24.0),
                  child: Column(
                    children: [
                      // --- TOP SECTION: BRANCH RADIOS + AVATAR ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Branch Radio Group
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRadioItem(
                                  title: 'علمي',
                                  value: 'علمي',
                                  groupValue: _selectedBranch,
                                  onChanged: (val) =>
                                      setState(() => _selectedBranch = val!),
                                ),
                                const SizedBox(height: 6),
                                _buildRadioItem(
                                  title: 'ادبي',
                                  value: 'ادبي',
                                  groupValue: _selectedBranch,
                                  onChanged: (val) =>
                                      setState(() => _selectedBranch = val!),
                                ),
                                const SizedBox(height: 6),
                                _buildRadioItem(
                                  title: 'مهني',
                                  value: 'مهني',
                                  groupValue: _selectedBranch,
                                  onChanged: (val) =>
                                      setState(() => _selectedBranch = val!),
                                ),
                              ],
                            ),
                          ),

                          // Profile Picture with Camera Badge
                          Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: primaryColor, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  image: _profileImage != null
                                      ? DecorationImage(
                                          image: FileImage(_profileImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _profileImage == null
                                    ? const Center(
                                        child: Icon(
                                          Icons.person_outline_rounded,
                                          size: 82,
                                          color: primaryColor,
                                        ),
                                      )
                                    : null,
                              ),
                              GestureDetector(
                                onTap: _pickAndSaveImage,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // --- NAME TEXT FIELD ---
                      TextField(
                        controller: _nameController,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: fieldTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          labelText: 'الاسم',
                          labelStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: primaryColor.withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          floatingLabelStyle: const TextStyle(
                            fontFamily: 'Cairo',
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor, width: 2.8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --- GRADE DROPDOWN ---
                      DropdownButtonFormField<String>(
                        value: _selectedGrade,
                        hint: const Center(
                          child: Text(
                            'الصف',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: primaryColor, size: 28),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor, width: 2.8),
                          ),
                        ),
                        items: _grades.map((grade) {
                          return DropdownMenuItem(
                            value: grade,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                grade,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  color: fieldTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedGrade = val),
                      ),

                      const SizedBox(height: 24),

                      // --- GOVERNORATE DROPDOWN ---
                      DropdownButtonFormField<CityModel>(
                        value: _selectedGovernorate,
                        hint: const Center(
                          child: Text(
                            'المحافظة',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: primaryColor, size: 28),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryColor, width: 2.8),
                          ),
                        ),
                        items: _governorates.map((city) {
                          return DropdownMenuItem<CityModel>(
                            value: city,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                city.name,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  color: fieldTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (city) {
                          setState(() {
                            _selectedGovernorate = city;
                          });
                        },
                      ),

                      const SizedBox(height: 28),

                      // --- GENDER RADIO GROUP ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRadioItem(
                              title: 'ذكر',
                              value: 'ذكر',
                              groupValue: _selectedGender,
                              onChanged: (val) =>
                                  setState(() => _selectedGender = val!),
                            ),
                            const SizedBox(height: 6),
                            _buildRadioItem(
                              title: 'انثى',
                              value: 'انثى',
                              groupValue: _selectedGender,
                              onChanged: (val) =>
                                  setState(() => _selectedGender = val!),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- SAVE BUTTON ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      // Save profile logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: primaryColor.withOpacity(0.4),
                    ),
                    child: const Text(
                      'حفظ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Cairo',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Styled Radio Option Item Component
  Widget _buildRadioItem({
    required String title,
    required String value,
    required String groupValue,
    required ValueChanged<String?> onChanged,
  }) {
    final bool isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(16),
      splashColor: primaryColor.withOpacity(0.1),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : primaryColor.withOpacity(0.7),
                  width: 2.2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 9.5,
                        height: 9.5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}