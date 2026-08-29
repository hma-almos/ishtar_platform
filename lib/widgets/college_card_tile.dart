import 'package:flutter/material.dart';
import 'package:ishtar_platform/Service/api_service.dart';
import 'package:ishtar_platform/models/college_model.dart'; // Adjust path if needed

class CollegeCardTile extends StatelessWidget {
  final CollegeModel college;
  final StudyShift selectedShift;
  final double? userGpa;
  final VoidCallback? onTap;

  const CollegeCardTile({
    super.key,
    required this.college,
    required this.selectedShift,
    this.userGpa,
    this.onTap,
  });

  String _formatCurrency(int amount) {
    if (amount == 0) return 'الدراسة مجانية';
    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = amount.toString().replaceAllMapped(
          regExp,
          (Match m) => '${m[1]},',
        );
    return '$formatted د.ع';
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1B4980);

    // Extract shift info for the currently selected study shift
    final shiftInfo = college.getShift(selectedShift);
    final double gpa = shiftInfo?.requiredGpa ?? 0.0;
    final int cost = shiftInfo?.cost ?? 0;
    final String title = college.name;
    final String subtitle = '${college.universityName} • ${college.city}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. GPA Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'المعدل',
                      style: TextStyle(
                        fontSize: 10,
                        color: primaryColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      '%$gpa',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 2. Middle Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F2C4D),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis, // Prevents horizontal & vertical text spillover
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          cost > 0
                              ? Icons.payments_outlined
                              : Icons.verified_rounded,
                          color: cost > 0 ? Colors.green : primaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatCurrency(cost),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: cost > 0 ? Colors.green : primaryColor,
                            fontFamily: 'Cairo',
                            overflow: TextOverflow.ellipsis, // Prevents horizontal & vertical text spillover

                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 3. College Building Icon / Logo
              buildLogo(ApiService().baseUrl+college.logoUrl, primaryColor,48),
            ],
          ),
        ),
      ),
    );
  }
  static Widget buildLogo(String? url, Color primaryColor,double size) {
  final bool hasUrl = url != null && url.isNotEmpty;

  if (hasUrl) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(size, primaryColor),
      ),
    );
  }

  return _buildFallbackIcon(size, primaryColor);
}

// Helper method for the bordered fallback icon container
static Widget _buildFallbackIcon(double size, Color primaryColor) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4F8),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFD0DBE8), width: 1),
    ),
    child: Icon(
      Icons.account_balance_rounded,
      color: primaryColor,
      size: 26,
    ),
  );
}
}