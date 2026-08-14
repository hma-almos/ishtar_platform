import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ishtar_platform/models/college_model.dart'; // Adjust path if needed

class CollegeDetailsScreen extends StatelessWidget {
  final CollegeModel college;

  const CollegeDetailsScreen({
    super.key,
    required this.college,
  });

  String _formatCurrency(int amount) {
    if (amount == 0) return 'مجاني';
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = amount.toString().replaceAllMapped(
          regExp,
          (Match m) => '${m[1]},',
        );
    return '$formatted د.ع';
  }

  String _getShiftLabel(StudyShift shift) {
    switch (shift) {
      case StudyShift.morning:
        return 'الصباحي';
      case StudyShift.parallel:
        return 'الموازي';
      case StudyShift.evening:
        return 'المسائي';
    }
  }

  // Helper method to open Google Maps
  Future<void> _openMap(BuildContext context, double lat, double lng) async {
    final Uri googleMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    try {
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر فتح الخريطة')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء فتح الخريطة')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B4980);
    const backgroundColor = Color(0xFFE3EBF5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          college.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER CARD ---
              _buildHeaderCard(primaryColor),

              const SizedBox(height: 16),

              // --- LOCATION CARD SECTION ---
              if (college.latitude != null && college.longitude != null) ...[
                _buildLocationCard(context, primaryColor),
                const SizedBox(height: 16),
              ],

              // --- SHIFT & MINIMUM LIMITS CARD ---
              _buildSectionCard(
                title: 'متطلبات المعدل والأقساط',
                icon: Icons.payments_rounded,
                child: Column(
                  children: college.shiftOptions.map((shiftInfo) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getShiftLabel(shiftInfo.shift),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  '%${shiftInfo.requiredGpa}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                backgroundColor: const Color(0xFFE8F0FE),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatCurrency(shiftInfo.cost),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: shiftInfo.cost > 0 ? Colors.green[700] : primaryColor,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // --- OVERVIEW SECTION ---
              if (college.overview.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'نبذة عن الكلية',
                  icon: Icons.info_outline_rounded,
                  child: Text(
                    college.overview,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.black87,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // --- DEPARTMENTS SECTION ---
              if (college.departments.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'الأقسام المتاحة',
                  icon: Icons.account_tree_rounded,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: college.departments.map((dept) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primaryColor.withOpacity(0.2)),
                        ),
                        child: Text(
                          dept,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // --- CAREER FIELDS SECTION ---
              if (college.careerFields.isNotEmpty) ...[
                _buildSectionCard(
                  title: 'مجالات العمل بعد التخرج',
                  icon: Icons.work_outline_rounded,
                  child: Column(
                    children: college.careerFields.map((field) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                field,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Location Card Widget
  Widget _buildLocationCard(BuildContext context, Color primaryColor) {
    return _buildSectionCard(
      title: 'الموقع الجغرافي',
      icon: Icons.location_on_rounded,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.map_rounded, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المحافظة / المدينة',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        college.city,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMap(context, college.latitude, college.longitude),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: const Text(
                  'عرض الموقع على الخريطة',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header banner widget
  Widget _buildHeaderCard(Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD0DBE8), width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: college.logoUrl.isNotEmpty
                      ? Image.network(
                          college.logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.account_balance_rounded,
                            color: primaryColor,
                            size: 30,
                          ),
                        )
                      : Icon(
                          Icons.account_balance_rounded,
                          color: primaryColor,
                          size: 30,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      college.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2C4D),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${college.universityName} • ${college.city}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetaInfo('نوع الجامعة', college.isPrivate ? 'أهلية' : 'حكومية'),
              _buildMetaInfo('سنة التأسيس', college.establishedYear.isNotEmpty ? college.establishedYear : 'غير محدد'),
              _buildMetaInfo('الأعتراف', college.recognitionDocNumber.isNotEmpty ? college.recognitionDocNumber : 'معترف بها'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Cairo'),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4980),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1B4980)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4980),
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}