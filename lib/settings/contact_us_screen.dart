import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  static const Color primaryNavy = Color(0xFF16487D);
  static const Color backgroundLight = Color(0xFFE8EEF8);
  static const Color cardBg = Color(0xFFF3F6FC);

  // Helper method to safely launch external URLs/Apps
  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

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
            'تواصل معنا',
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
            _buildContactCard(
              icon: Icons.location_on_rounded,
              title: 'العنوان',
              subtitle: 'محافظة بابل - حي نادر - مقابل معمل النسيج',
              // Opens Google Maps with coordinates/search query
              onTap: () => _launchUrl('https://maps.app.goo.gl/VtRyzc3yZ4X6VaXYA'), 
            ),
            _buildContactCard(
              icon: Icons.phone_rounded,
              title: 'رقم الهاتف',
              subtitle: '07850155559',
              // Opens Phone Dialer app directly
              onTap: () => _launchUrl('tel:07850155559'), 
            ),
            _buildContactCard(
              icon: Icons.email_rounded,
              title: 'البريد الإلكتروني',
              subtitle: 'info@ishtaruc.edu.iq',
              // Opens Default Email App
              onTap: () => _launchUrl('mailto:info@ishtaruc.edu.iq'), 
            ),
            _buildContactCard(
              icon: Icons.facebook_rounded,
              title: 'فيسبوك',
              subtitle: 'facebook',
              // Opens Facebook Web or App
              onTap: () => _launchUrl('https://www.facebook.com/ishtar.university/?locale=ar_AR'), 
            ),
            _buildContactCard(
              icon: Icons.camera_alt_rounded,
              title: 'إنستغرام',
              subtitle: 'Instagram',
              // Opens Instagram Web or App
              onTap: () => _launchUrl('https://www.instagram.com/ishtar.university/?hl=ar'), 
            ),
            _buildContactCard(
              icon: Icons.play_arrow_rounded,
              title: 'يوتيوب',
              subtitle: 'YouTube',
              // Opens YouTube Web or App
              onTap: () => _launchUrl('https://www.youtube.com/@ishtaruc'), 
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: primaryNavy,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: primaryNavy.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: primaryNavy,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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