import 'package:flutter/material.dart';
import 'package:ishtar_platform/settings/about_us_screen.dart';
import 'package:ishtar_platform/settings/contact_us_screen.dart';

class StyledSettingsBody extends StatelessWidget {
  const StyledSettingsBody({Key? key}) : super(key: key);

  static const Color primaryNavy = Color(0xFF16487D);
  static const Color backgroundLight = Color(0xFFE8EEF8);
  static const Color cardBg = Color(0xFFF3F6FC);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: backgroundLight,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          children: [
            _buildSettingsTile(
              icon: Icons.phone_in_talk_rounded,
              title: 'تواصل معنا',
              onTap: () =>Navigator.push(context, MaterialPageRoute(builder:(context) =>  ContactUsScreen())),
            ),
            _buildSettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'من نحن',
              onTap: ()=>Navigator.push(context, MaterialPageRoute(builder:(context) =>  AboutUsScreen())),
            ),
            // _buildSettingsTile(
            //   icon: Icons.help_outline_rounded,
            //   title: 'اسئلة شائعة',
            //   onTap: () {},
            // ),
            // const SizedBox(height: 12),
            // _buildSettingsTile(
            //   icon: Icons.logout_rounded,
            //   title: 'تسجيل الخروج',
            //   isDestructive: true,
            //   onTap: () {},
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final Color itemColor = isDestructive ? Colors.redAccent : primaryNavy;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
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
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          title: Text(
            title,
            style: TextStyle(
              color: itemColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: itemColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: itemColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}