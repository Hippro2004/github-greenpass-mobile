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

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color warmGold = Color(0xFFB7791F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: forestGreen),
        ),
        title: Text(
          parkName,
          style: const TextStyle(
            color: forestGreen,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) => _buildReportCard(context, reports[index]),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, ReportResponse report) {
    final statusColor = _statusColor(report.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReportViewDetail(report: report)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 13, color: warmGold),
                const SizedBox(width: 5),
                Text(
                  report.reportDate,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const SizedBox(width: 10),
                Icon(Icons.access_time, size: 13, color: warmGold),
                const SizedBox(width: 5),
                Text(
                  report.reportTime,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                const Spacer(),
                Icon(Icons.circle, size: 9, color: statusColor),
                const SizedBox(width: 5),
                Text(
                  _statusLabel(report.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
        return forestGreen; // Green
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
        return const Color(0xFFD97706); // Orange
      case "PENDING":
      case "รอตอบรับ":
      case "รอการตอบรับ":
      default:
        return warmGold; // Gold/Amber
    }
  }
}
