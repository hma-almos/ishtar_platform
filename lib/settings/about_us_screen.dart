import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  static const Color primaryNavy = Color(0xFF16487D);
  static const Color backgroundLight = Color(0xFFE8EEF8);
  static const Color cardBg = Color(0xFFF3F6FC);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundLight,
        appBar: AppBar(
          backgroundColor: primaryNavy,
          elevation: 2,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
          title: const Text(
            'من نحن',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          children: [
            // Top Branding Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'منصة تعليمية تابعة لكلية\nعشتار الجامعة',
                      style: TextStyle(
                        color: primaryNavy,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // College Logo Replacement
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/ishtarLogo.png', // Replace with your image path
                      width: 70,
                      height: 70,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // College Description Card
            _buildInfoCard(
              title: 'عن الكلية',
              icon: Icons.school_rounded,
              content:
                  'كلية عشتار الاهلية الجامعة هي كلية اهلية تقع في قلب بابل مستوحاة من حضارة عشتار العريقة، نحن نقدم بيئة تعليمية متطورة تضم أقسامًا متميزة حيث تتميز الكلية برصانتها الأكاديمية وتفانيها في تقديم تعليم عالي الجودة، مما يجعلها وجهة مثالية للطلاب الطموحين الذين يسعون لبناء مستقبل مشرق.',
            ),
            const SizedBox(height: 16),

            // App Description Card
            _buildInfoCard(
              title: 'عن التطبيق',
              icon: Icons.touch_app_rounded,
              content:
                  'تم تطوير هذا البرنامج لمساعدة طلاب المدارس على تقديم افضل اداء ممكن في صفوفهم كما وتمت اضافة تقنيات لتسهيل عمليات التقديم على الجامعات.',
            ),
            const SizedBox(height: 28),

            // Developer Credit Banner with Logo
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: primaryNavy.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryNavy.withOpacity(0.12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'تم تطوير البرنامج بواسطة',
                    style: TextStyle(
                      color: primaryNavy,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Click Team Logo Replacement
                  Image.asset(
                    'assets/images/ClickLogo.png', // Replace with your image path
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Icon(icon, color: primaryNavy, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: primaryNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: primaryNavy.withOpacity(0.85),
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}