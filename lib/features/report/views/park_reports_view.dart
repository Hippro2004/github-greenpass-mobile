import 'package:flutter/material.dart';
import 'package:greenpass/features/report/dtos/report_response.dart';
import 'package:greenpass/features/report/views/report_view_detail.dart';

class ParkReportsView extends StatelessWidget {
  const ParkReportsView({
    super.key,
    required this.parkName,
    required this.reports,
  });

  final String parkName;
  final List<ReportResponse> reports;

  // ── Vibrant Wilderness Palette ─────────────────────────────────
  static const Color screenBg = Color(0xFFF3F7F5);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color midForest = Color(0xFF0F5A3E);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color mintLight = Color(0xFFE8F7F0);
  static const Color mintBorder = Color(0xFFD6EFE2);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  List<ReportResponse> get _sortedReports {
    final list = List<ReportResponse>.from(reports);
    list.sort((a, b) {
      final timeA =
          a.reportTime.trim().isNotEmpty ? a.reportTime.trim() : "00:00:00";
      final timeB =
          b.reportTime.trim().isNotEmpty ? b.reportTime.trim() : "00:00:00";
      final dtA =
          DateTime.tryParse('${a.reportDate} $timeA') ??
          DateTime.tryParse(a.reportDate) ??
          DateTime(1970);
      final dtB =
          DateTime.tryParse('${b.reportDate} $timeB') ??
          DateTime.tryParse(b.reportDate) ??
          DateTime(1970);
      final cmp = dtB.compareTo(dtA);
      if (cmp != 0) return cmp;
      return b.reportId.compareTo(a.reportId);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedReports;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: mintLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: mintBorder),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: darkForest,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "รายงานอุทยาน",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          // ── Park Hero Banner ────────────────────────────────
          _buildParkHeroBanner(sorted.length),

          const SizedBox(height: 18),

          // ── Section Title ───────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "รายการแจ้งเรื่อง",
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  "${sorted.length} เรื่อง",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Report Cards List ───────────────────────────────
          if (sorted.isEmpty)
            _buildEmptyState()
          else
            ...sorted.map((report) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildReportCard(context, report),
                )),
        ],
      ),
    );
  }

  /// การ์ดแบนเนอร์สรุปข้อมูลอุทยานด้านบน
  Widget _buildParkHeroBanner(int totalCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF064E3B), Color(0xFF0B5D41), Color(0xFF043828)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: darkForest.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSubstringIconBadge(parkName),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "NATIONAL PARK REPORT",
                    style: TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  parkName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  "มีประวัติแจ้งเรื่อง $totalCount รายการ",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
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

  /// การ์ดรายการรายงานแต่ละชิ้น
  Widget _buildReportCard(BuildContext context, ReportResponse report) {
    final statusColor = _statusColor(report.status);
    final statusLabel = _statusLabel(report.status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReportViewDetail(report: report)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEAF3EE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // หัวเรื่อง + ป้ายสถานะ
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      report.name,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
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
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (report.description.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  report.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF475569),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // วันที่ เวลา และปุ่ม Chevron
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          report.reportDate,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (report.reportTime.trim().isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            report.reportTime,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Spacer(),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: mintLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: darkForest,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ไอคอน Badge ตัดคำแบบ Vibrant Wilderness
  Widget _buildSubstringIconBadge(String rawParkName) {
    String shortName = rawParkName.trim();
    if (shortName.startsWith("อุทยานแห่งชาติ")) {
      shortName = shortName.substring("อุทยานแห่งชาติ".length).trim();
    }
    if (shortName.isEmpty) {
      shortName = rawParkName;
    }

    final name = rawParkName;
    IconData icon;
    List<Color> gradientColors;

    if (name.contains("น้ำตก")) {
      icon = Icons.water_drop_rounded;
      gradientColors = const [Color(0xFF0284C7), Color(0xFF2563EB)];
    } else if (name.contains("เกาะ") ||
        name.contains("ทะเล") ||
        name.contains("หาด") ||
        name.contains("อ่าว") ||
        name.contains("ธารา") ||
        name.contains("หมู่เกาะ")) {
      icon = Icons.waves_rounded;
      gradientColors = const [Color(0xFF00796B), Color(0xFF009688)];
    } else if (name.contains("ดอย") ||
        name.contains("ภู") ||
        name.contains("ยอด")) {
      icon = Icons.filter_hdr_rounded;
      gradientColors = const [Color(0xFF7C3AED), Color(0xFF6D28D9)];
    } else if (name.contains("เขา") ||
        name.contains("ผา") ||
        name.contains("หิน") ||
        name.contains("ถ้ำ")) {
      icon = Icons.landscape_rounded;
      gradientColors = const [Color(0xFFEA580C), Color(0xFFD97706)];
    } else {
      icon = Icons.park_rounded;
      gradientColors = const [Color(0xFF006D43), Color(0xFF00A86B)];
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Text(
              shortName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8.5,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: mintLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                size: 48,
                color: emeraldTint,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "ยังไม่มีรายงานในอุทยานนี้",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "รายงานที่คุณแจ้งไว้จะแสดงที่นี่",
              style: TextStyle(fontSize: 13, color: textMuted),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    final s = status
        .trim()
        .toUpperCase()
        .replaceAll('_', '')
        .replaceAll(' ', '')
        .replaceAll('-', '');
    switch (s) {
      case "ACKNOWLEDGED":
      case "รับเรื่องแล้ว":
        return "รับเรื่องแล้ว";
      case "INPROGRESS":
      case "กำลังดำเนินการ":
        return "กำลังดำเนินการ";
      case "COMPLETED":
      case "RESOLVED":
      case "CLOSED":
      case "DONE":
      case "แก้ไขแล้ว":
      case "เสร็จสิ้น":
      case "ปิดเรื่องแล้ว":
        return "เสร็จสิ้น";
      case "REJECTED":
      case "CANCELLED":
      case "CANCELED":
      case "ไม่รับเรื่อง":
        return "ไม่รับเรื่อง";
      case "NEEDSINFO":
      case "รอข้อมูลเพิ่มเติม":
        return "รอข้อมูลเพิ่มเติม";
      case "PENDING":
      case "รอตอบรับ":
      case "รอการตอบรับ":
        return "รอตอบรับ";
      default:
        if (status.trim().isNotEmpty) {
          return status.trim();
        }
        return "รอตอบรับ";
    }
  }

  Color _statusColor(String status) {
    final s = status
        .trim()
        .toUpperCase()
        .replaceAll('_', '')
        .replaceAll(' ', '')
        .replaceAll('-', '');
    switch (s) {
      case "INPROGRESS":
      case "กำลังดำเนินการ":
        return const Color(0xFF2563EB); // Blue
      case "COMPLETED":
      case "RESOLVED":
      case "CLOSED":
      case "DONE":
      case "แก้ไขแล้ว":
      case "เสร็จสิ้น":
      case "ปิดเรื่องแล้ว":
        return const Color(0xFF059669); // Emerald
      case "ACKNOWLEDGED":
      case "รับเรื่องแล้ว":
        return const Color(0xFF0284C7); // Sky blue
      case "REJECTED":
      case "CANCELLED":
      case "CANCELED":
      case "ไม่รับเรื่อง":
        return const Color(0xFFDC2626); // Red
      case "NEEDSINFO":
      case "รอข้อมูลเพิ่มเติม":
        return const Color(0xFFEA580C); // Amber/Orange
      case "PENDING":
      case "รอตอบรับ":
      case "รอการตอบรับ":
      default:
        return const Color(0xFFD97706); // Amber
    }
  }
}
