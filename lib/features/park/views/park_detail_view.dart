import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenpass/features/park/models/park.dart';

class ParkDetailView extends StatefulWidget {
  final Park park;

  const ParkDetailView({super.key, required this.park});

  @override
  State<ParkDetailView> createState() => _ParkDetailViewState();
}

class _ParkDetailViewState extends State<ParkDetailView> {
  // ── Vibrant Wilderness Color Palette (DESIGN.md) ───────────
  static const Color screenBg = Color(0xFFF6FAF7);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color deepForestHeader = Color(0xFF0F4A36);
  static const Color primaryGreen = Color(0xFF006D43);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color mintLight = Color(0xFFE8F7F0);
  static const Color textDark = Color(0xFF091E25);
  static const Color textMuted = Color(0xFF64748B);
  static const Color emergencyRed = Color(0xFFE11D48);
  static const Color emergencyBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    final park = widget.park;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: _buildAppBar(park),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card ─────────────────────────────────────
            _buildHeroCard(park),

            // ── Section 1: ที่อยู่อุทยาน ──────────────────────────
            _buildAddressCard(park),

            // ── Section 2: เวลาเปิด - ปิดทำการ ────────────────────
            _buildHoursCard(park),

            // ── Section 3: งานอีเว้นท์ประจำฤดูกาล & จุดเข้าชม ──────────
            if (park.eventNote != null ||
                park.isSeasonalPark == true ||
                park.name.contains("เขาใหญ่"))
              _buildEventsCard(park),

            // ── Section 4: เกี่ยวกับอุทยาน ────────────────────────
            _buildAboutCard(park),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Park park) {
    return AppBar(
      backgroundColor: deepForestHeader,
      elevation: 0,
      centerTitle: true,
      leading: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
      title: Text(
        park.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// สร้างไอคอน Badge อัตโนมัติโดยการตัดคำ (substring) จากชื่ออุทยาน เหมือนหน้าค้นหา
  Widget _buildSubstringIconBadge(Park park) {
    // 1. ตัดคำว่า "อุทยานแห่งชาติ" ออกด้วย substring
    String shortName = park.name;
    if (shortName.startsWith("อุทยานแห่งชาติ")) {
      shortName = shortName.substring("อุทยานแห่งชาติ".length).trim();
    }
    if (shortName.isEmpty) {
      shortName = park.name;
    }

    // 2. วิเคราะห์คำในชื่ออุทยาน (substring) เพื่อเลือกประเภทไอคอนและคู่สีกราเดียนต์
    final name = park.name;
    IconData icon;
    List<Color> gradientColors;

    if (name.contains("น้ำตก")) {
      icon = Icons.water_drop_rounded;
      gradientColors = const [
        Color(0xFF0284C7),
        Color(0xFF2563EB),
      ]; // สีฟ้าสายน้ำตก
    } else if (name.contains("เกาะ") ||
        name.contains("ทะเล") ||
        name.contains("หาด") ||
        name.contains("อ่าว") ||
        name.contains("ธารา") ||
        name.contains("หมู่เกาะ")) {
      icon = Icons.waves_rounded;
      gradientColors = const [
        Color(0xFF00796B),
        Color(0xFF009688),
      ]; // สีเขียวอมฟ้าทางทะเล
    } else if (name.contains("ดอย") ||
        name.contains("ภู") ||
        name.contains("ยอด")) {
      icon = Icons.filter_hdr_rounded;
      gradientColors = const [
        Color(0xFF7C3AED),
        Color(0xFF6D28D9),
      ]; // สีม่วงยอดดอย
    } else if (name.contains("เขา") ||
        name.contains("ผา") ||
        name.contains("หิน") ||
        name.contains("ถ้ำ")) {
      icon = Icons.landscape_rounded;
      gradientColors = const [
        Color(0xFFEA580C),
        Color(0xFFD97706),
      ]; // สีส้มทิวเขา
    } else {
      icon = Icons.park_rounded;
      gradientColors = const [
        Color(0xFF006D43),
        Color(0xFF00A86B),
      ]; // สีเขียวป่าไม้ธรรมชาติ
    }

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              shortName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(Park park) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Park Badge (same as search view)
              _buildSubstringIconBadge(park),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      park.name,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: emeraldTint,
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            park.location ?? "อุทยานแห่งชาติ",
                            style: const TextStyle(
                              color: textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Badge: Open Hours today
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: mintLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD6EFE2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: emeraldTint,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "เปิดบริการวันนี้ ${park.openTime ?? '06:00'} - ${park.closeTime ?? '18:00'}",
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Park park) {
    return _buildCardContainer(
      iconContainerColor: const Color(0xFFD1FAE5),
      iconColor: emeraldTint,
      icon: Icons.location_on_outlined,
      title: "ข้อมูลที่อยู่อุทยาน",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            park.address ?? "-",
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.navigation_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text("เปิดแผนที่นำทางไปยัง ${park.name}"),
                            ),
                          ],
                        ),
                        backgroundColor: darkForest,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: mintLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFB7E4C7)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, color: primaryGreen, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "เปิดแผนที่นำทาง (Google Maps)",
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  if (park.address != null) {
                    Clipboard.setData(ClipboardData(text: park.address!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(
                              Icons.copy_rounded,
                              color: emeraldTint,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text("คัดลอกที่อยู่อุทยานแล้ว"),
                          ],
                        ),
                        backgroundColor: darkForest,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoursCard(Park park) {
    Color statusColor;
    String statusText;
    Color statusBg;

    if (park.isTemporaryClosed == true) {
      statusColor = emergencyRed;
      statusBg = emergencyBg;
      statusText = "ปิดชั่วคราว";
    } else if (park.isSeasonalPark == true) {
      statusColor = const Color(0xFFD97706);
      statusBg = const Color(0xFFFEF3C7);
      statusText = "เปิดตามฤดูกาล";
    } else {
      statusColor = const Color(0xFF065F46);
      statusBg = mintLight;
      statusText = "เปิดทำการ";
    }

    return _buildCardContainer(
      iconContainerColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFD97706),
      icon: Icons.access_time_rounded,
      title: "เวลาเปิด - ปิด\nทำการ",
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: statusBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 11.5,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "เปิดบริการทุกวัน",
                style: TextStyle(
                  fontSize: 12.5,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${park.openTime ?? '06:00:00'} - ${park.closeTime ?? '18:00:00'} น.",
                style: const TextStyle(
                  fontSize: 13.5,
                  color: textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 13.5,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  park.eventNote ??
                      "ด่านตรวจปิดรับนักท่องเที่ยวขึ้นเขาหลังเวลา 18:00 น.",
                  style: const TextStyle(fontSize: 11, color: textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsCard(Park park) {
    final isKhaoYai = park.name.contains("เขาใหญ่");

    return _buildCardContainer(
      iconContainerColor: const Color(0xFFE0F2FE),
      iconColor: const Color(0xFF0284C7),
      icon: Icons.calendar_today_outlined,
      title: "งานอีเว้นท์ประจำฤดูกาล & จุดเข้าชม",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (park.eventNote != null)
            Text(
              park.eventNote!,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            )
          else if (isKhaoYai)
            const Text(
              "ด่านศาลเจ้าพ่อเขาใหญ่ (กม.23 ฝั่งปากช่อง) & ด่านเนินหอม (กม.41 ฝั่งปราจีนบุรี)",
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(Park park) {
    final description =
        park.description != null && park.description!.trim().isNotEmpty
        ? park.description!
        : (park.name.contains("เขาใหญ่")
              ? "อุทยานแห่งชาติเขาใหญ่ เป็นอุทยานแห่งชาติแห่งแรกของประเทศไทย จัดตั้งขึ้นเมื่อปี พ.ศ. 2505 และได้รับการยกย่องเป็นมรดกโลกทางธรรมชาติ อุดมสมบูรณ์ด้วยผืนป่าดงพญาเย็น-เขาใหญ่ แหล่งต้นน้ำลำธารสำคัญและที่อยู่อาศัยของสัตว์ป่านานาชนิด"
              : "ข้อมูลประวัติและความเป็นมาของอุทยานแห่งชาตินี้ เป็นแหล่งอนุรักษ์ทรัพยากรธรรมชาติและสิ่งแวดล้อมที่สำคัญ");

    return _buildCardContainer(
      iconContainerColor: mintLight,
      iconColor: emeraldTint,
      icon: Icons.menu_book_outlined,
      title: "เกี่ยวกับอุทยาน",
      child: Text(
        description,
        style: const TextStyle(
          fontSize: 12.5,
          color: Color(0xFF475569),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCardContainer({
    required Color iconContainerColor,
    required Color iconColor,
    required IconData icon,
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAF3EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconContainerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
