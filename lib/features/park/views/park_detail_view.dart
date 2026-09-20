import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenpass/features/park/models/park.dart';
import 'package:greenpass/features/stamp/views/show_qr_view.dart';

class ParkDetailView extends StatefulWidget {
  final Park park;

  const ParkDetailView({super.key, required this.park});

  @override
  State<ParkDetailView> createState() => _ParkDetailViewState();
}

class _ParkDetailViewState extends State<ParkDetailView> {
  bool _isFavorite = false;

  // ── Vibrant Wilderness Color Palette (DESIGN.md) ───────────
  static const Color screenBg = Color(0xFFF6FAF7);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color deepForestHeader = Color(0xFF0F4A36);
  static const Color primaryGreen = Color(0xFF006D43);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color paleEmerald = Color(0xFF78FBB6);
  static const Color mintLight = Color(0xFFE8F7F0);
  static const Color textDark = Color(0xFF091E25);
  static const Color textMuted = Color(0xFF64748B);
  static const Color starAmber = Color(0xFFF59E0B);
  static const Color emergencyRed = Color(0xFFE11D48);
  static const Color emergencyBg = Color(0xFFFEE2E2);
  static const Color emergencyBorder = Color(0xFFFECDD3);

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

            const SizedBox(height: 100), // Space for bottom action bar
          ],
        ),
      ),
      bottomSheet: _buildBottomActionBar(park),
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
      actions: [
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                        color: starAmber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isFavorite
                            ? "บันทึก ${park.name} ในรายการโปรดแล้ว"
                            : "นำออกจากรายการโปรดแล้ว",
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
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: _isFavorite ? starAmber : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: "${park.name}\n${park.address ?? ''}"));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: emeraldTint, size: 18),
                      SizedBox(width: 8),
                      Text("คัดลอกข้อมูลอุทยานสำหรับแชร์แล้ว"),
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
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(Park park) {
    final isWorldHeritage = park.name.contains("เขาใหญ่") ||
        park.name.contains("แก่งกระจาน") ||
        (park.description?.contains("มรดกโลก") ?? false);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF064E3B),
            Color(0xFF0B5D41),
            Color(0xFF043828),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkForest.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Park Image / Icon Squircle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF003820),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: emeraldTint, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: park.image != null
                      ? Image.asset(
                          'assets/images/${park.image}',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, exception, stackTrace) => const Center(
                            child: Icon(
                              Icons.park_rounded,
                              color: emeraldTint,
                              size: 34,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.park_rounded,
                            color: emeraldTint,
                            size: 34,
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      park.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: paleEmerald,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            park.location ?? "อุทยานแห่งชาติ",
                            style: const TextStyle(
                              color: paleEmerald,
                              fontSize: 11.5,
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

          // Badge 1: World Heritage or Park Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isWorldHeritage
                    ? starAmber.withValues(alpha: 0.35)
                    : emeraldTint.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isWorldHeritage ? Icons.star_rounded : Icons.eco_rounded,
                  color: isWorldHeritage ? starAmber : emeraldTint,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  isWorldHeritage
                      ? "มรดกโลกทางธรรมชาติ (UNESCO)"
                      : (park.status ?? "อุทยานแห่งชาติ"),
                  style: TextStyle(
                    color: isWorldHeritage
                        ? const Color(0xFFFDE047)
                        : const Color(0xFFD1FAE5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Badge 2: Open Hours today
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "เปิดบริการวันนี้ ${park.openTime ?? '06:00'} - ${park.closeTime ?? '18:00'}",
                  style: const TextStyle(
                    color: Color(0xFFD1FAE5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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
                            const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text("เปิดแผนที่นำทางไปยัง ${park.name}")),
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
                    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
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
                            Icon(Icons.copy_rounded, color: emeraldTint, size: 18),
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
                  park.eventNote ?? "ด่านตรวจปิดรับนักท่องเที่ยวขึ้นเขาหลังเวลา 18:00 น.",
                  style: const TextStyle(
                    fontSize: 11,
                    color: textMuted,
                  ),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: isKhaoYai
                ? [
                    _buildTagChip("🔭 ส่องสัตว์กลางคืน (Night Safari)", mintLight, primaryGreen),
                    _buildTagChip("🛶 เส้นทางผากล้วยไม้", mintLight, primaryGreen),
                    _buildTagChip("⛺ ลานกางเต็นท์ลำตะคอง", const Color(0xFFFEF3C7), const Color(0xFF92400E)),
                  ]
                : [
                    if (park.isSeasonalPark == true)
                      _buildTagChip(
                        "📅 เปิด ${park.seasonOpenDate ?? ''} - ${park.seasonCloseDate ?? ''}",
                        const Color(0xFFFEF3C7),
                        const Color(0xFF92400E),
                      ),
                    _buildTagChip("🌿 จุดท่องเที่ยวธรรมชาติ", mintLight, primaryGreen),
                    _buildTagChip("📷 จุดชมทัศนียภาพ", const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAboutCard(Park park) {
    final description = park.description != null && park.description!.trim().isNotEmpty
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

  Widget _buildBottomActionBar(Park park) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Left: ฉุกเฉิน
            GestureDetector(
              onTap: () => _showEmergencyModal(context, park),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: emergencyBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: emergencyBorder),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone_in_talk_rounded,
                      color: emergencyRed,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "ฉุกเฉิน",
                      style: TextStyle(
                        color: emergencyRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Right: ประทับตราอุทยาน (E-Stamp)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StampQrView(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryGreen, emeraldTint],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "ประทับตราอุทยาน (E-Stamp)",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyModal(BuildContext context, Park park) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: emergencyBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_in_talk_rounded, color: emergencyRed, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "เบอร์โทรฉุกเฉิน",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildEmergencyItem(
                  title: "สายด่วนกรมอุทยานแห่งชาติฯ",
                  number: "1362",
                  subtitle: "บริการตลอด 24 ชั่วโมง",
                ),
                const Divider(height: 16),
                _buildEmergencyItem(
                  title: "ตำรวจท่องเที่ยว",
                  number: "1155",
                  subtitle: "แจ้งเหตุด่วนช่วยเหลือนักท่องเที่ยว",
                ),
                const Divider(height: 16),
                _buildEmergencyItem(
                  title: "สถาบันการแพทย์ฉุกเฉินแห่งชาติ (สพฉ.)",
                  number: "1669",
                  subtitle: "อุบัติเหตุฉุกเฉินและกู้ชีพ",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyItem({
    required String title,
    required String number,
    required String subtitle,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: textMuted),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: number));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("คัดลอกเบอร์ $number แล้ว"),
                backgroundColor: darkForest,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: emergencyBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone, size: 14, color: emergencyRed),
                const SizedBox(width: 4),
                Text(
                  number,
                  style: const TextStyle(
                    color: emergencyRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
