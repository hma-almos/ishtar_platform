import 'package:flutter/material.dart';

class ApplicationChannelsScreen extends StatefulWidget {
  final String title;

  const ApplicationChannelsScreen({
    super.key,
    this.title = 'قنوات التقديم',
  });

  @override
  State<ApplicationChannelsScreen> createState() =>
      _ApplicationChannelsScreenState();
}

class _ApplicationChannelsScreenState
    extends State<ApplicationChannelsScreen> {
  // Sample Data List with Icons and Status Tags
  final List<_ChannelItem> _channels = [
    _ChannelItem(
      title: 'ذوي الشهداء',
      icon: Icons.military_tech_rounded,
      tag: 'فئة خاصة',
      description:
          'تشمل هذه القناة فئات ذوي شهداء ضحايا جرائم حزب البعث المنحل، وذوي شهداء الحشد الشعبي، وذوي شهداء العمليات الإرهابية.',
    ),
    _ChannelItem(
      title: 'القبول المركزي',
      icon: Icons.account_balance_rounded,
      tag: 'القناة العامة',
      description:
          'القناة الرئيسية للقبول في الكليات والمعاهد الحكومية بناءً على المجموع ومعدل الطالب في السادس الإعدادي.',
    ),
    _ChannelItem(
      title: 'التعليم الحكومي الخاص (الموازي)',
      icon: Icons.payments_rounded,
      tag: 'بأجور دراسية',
      description:
          'تتيح للطلبة التقديم على الكليات بمعدل أقل بنقاط محددة مقابل أجور دراسية تخفض حسب الضوابط والتعليمات الوزارية.',
    ),
    _ChannelItem(
      title: 'قناة النخبة',
      icon: Icons.star_rounded,
      tag: 'المعدلات العالية',
      description:
          'تستهدف الطلبة أصحاب المعدلات العالية للقبول في كليات المجموعة الطبية والتربية والقانون وفق الشروط المحددة.',
    ),
    _ChannelItem(
      title: 'قبول الموظفين المتميزين',
      icon: Icons.badge_rounded,
      tag: 'للكوادر الوظيفية',
      description:
          'خاصة بالمواطنين الموظفين في مؤسسات الدولة الراغبين بإكمال دراستهم الجامعية وفق الضوابط والترشيح الرسمي.',
    ),
    _ChannelItem(
      title: 'المعلمين المجازين دراسياً',
      icon: Icons.school_rounded,
      tag: 'الكوادر التربوية',
      description:
          'قناة مخصصة للكوادر التدريسية والمعلمين الراغبين بالحصول على شهادة البكالوريوس أثناء الخدمة.',
    ),
    _ChannelItem(
      title: 'قناة العشرة الأوائل من خريجي المعاهد والمهني',
      icon: Icons.emoji_events_rounded,
      tag: 'للمتفوقين',
      description:
          'تسمح للطلبة المتفوقين الأوائل على المعاهد والتعليم المهني بالالتحاق بالكليات المناظرة لاختصاصاتهم.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1B4980);
    const Color backgroundColor = Color(0xFFE3EBF5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // --- TOP HEADER ---
            Container(
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 6,
                bottom: 16,
                left: 12,
                right: 12,
              ),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  // Screen Title
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),

                  const SizedBox(width: 48), // Spacer balance
                ],
              ),
            ),

            // --- STYLIZED EXPANDABLE CARDS LIST ---
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _channels.length,
                itemBuilder: (context, index) {
                  final item = _channels[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Theme(
                      // Remove ExpansionTile borders
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        childrenPadding: const EdgeInsets.only(
                          right: 14,
                          left: 14,
                          bottom: 14,
                        ),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F1FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: primaryColor,
                          size: 26,
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F9FC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE1E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Badge Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.tag,
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Channel Description
                                Text(
                                  item.description,
                                  style: const TextStyle(
                                    color: Color(0xFF4A6B94),
                                    fontSize: 13,
                                    fontFamily: 'Cairo',
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Model
class _ChannelItem {
  final String title;
  final String description;
  final IconData icon;
  final String tag;

  _ChannelItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.tag,
  });
}