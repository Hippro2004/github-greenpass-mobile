import 'dart:async';
import 'package:flutter/material.dart';
import 'package:greenpass/core/network/image_helper.dart';
import 'package:greenpass/features/notification/models/notification_model.dart';
import 'package:greenpass/features/notification/services/notification_websocket_service.dart';
import 'package:greenpass/features/report/dtos/reply_report_response.dart';
import 'package:greenpass/features/report/dtos/report_response.dart';
import 'package:greenpass/features/report/services/reply_report_service.dart';

class ReportViewDetail extends StatefulWidget {
  const ReportViewDetail({super.key, required this.report});

  final ReportResponse report;

  @override
  State<ReportViewDetail> createState() => _ReportViewDetailState();
}

class _ReportViewDetailState extends State<ReportViewDetail> {
  final ReplyReportService _replyReportService = ReplyReportService();
  StreamSubscription<NotificationModel>? _wsSub;
  List<ReplyReportResponse> _replies = [];
  late String _currentStatus;
  bool _isLoading = true;
  String? _error;

  // ── Vibrant Wilderness Palette ─────────────────────────────────
  static const Color screenBg = Color(0xFFF3F7F5);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color mintLight = Color(0xFFE8F7F0);
  static const Color mintBorder = Color(0xFFD6EFE2);
  static const Color mintPillBg = Color(0xFFD1FAE5);
  static const Color mintDark = Color(0xFF065F46);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.report.status;
    _loadReplies();

    _wsSub = NotificationWebSocketService.instance.notificationStream.listen((
      notif,
    ) {
      if (!mounted) return;
      if (notif.reportId == widget.report.reportId ||
          (notif.report != null &&
              notif.report!.reportId == widget.report.reportId)) {
        setState(() {
          if (notif.report?.status != null && notif.report!.status.isNotEmpty) {
            _currentStatus = notif.report!.status;
          }
        });
        _loadReplies();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notif.message),
            backgroundColor: darkForest,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadReplies() async {
    try {
      final replies = await _replyReportService.getReplyReport(
        widget.report.reportId,
      );
      if (!mounted) return;
      setState(() {
        _replies = replies;
        if (_replies.isNotEmpty) {
          final latestStatus = _replies.last.currentStatus;
          if (latestStatus.trim().isNotEmpty) {
            _currentStatus = latestStatus;
          }
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'ไม่สามารถโหลดประวัติการดำเนินการได้';
        _isLoading = false;
      });
    }
  }

  String _statusLabel(String status) {
    final s = status
        .trim()
        .toUpperCase()
        .replaceAll('_', '')
        .replaceAll(' ', '')
        .replaceAll('-', '');
    switch (s) {
      case 'ACKNOWLEDGED':
      case 'รับเรื่องแล้ว':
        return 'รับเรื่องแล้ว';
      case 'INPROGRESS':
      case 'กำลังดำเนินการ':
        return 'กำลังดำเนินการ';
      case 'COMPLETED':
      case 'RESOLVED':
      case 'CLOSED':
      case 'DONE':
      case 'แก้ไขแล้ว':
      case 'เสร็จสิ้น':
      case 'ปิดเรื่องแล้ว':
        return 'เสร็จสิ้น';
      case 'REJECTED':
      case 'CANCELLED':
      case 'CANCELED':
      case 'ไม่รับเรื่อง':
        return 'ไม่รับเรื่อง';
      case 'NEEDSINFO':
      case 'รอข้อมูลเพิ่มเติม':
        return 'รอข้อมูลเพิ่มเติม';
      case 'PENDING':
      case 'รอตอบรับ':
      case 'รอการตอบรับ':
        return 'รอตอบรับ';
      default:
        if (status.trim().isNotEmpty) {
          return status.trim();
        }
        return 'รอตอบรับ';
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
      case 'INPROGRESS':
      case 'กำลังดำเนินการ':
        return const Color(0xFF2563EB); // Blue
      case 'COMPLETED':
      case 'RESOLVED':
      case 'CLOSED':
      case 'DONE':
      case 'แก้ไขแล้ว':
      case 'เสร็จสิ้น':
      case 'ปิดเรื่องแล้ว':
        return const Color(0xFF059669); // Emerald Green
      case 'ACKNOWLEDGED':
      case 'รับเรื่องแล้ว':
        return const Color(0xFF0284C7); // Sky Blue
      case 'REJECTED':
      case 'CANCELLED':
      case 'CANCELED':
      case 'ไม่รับเรื่อง':
        return const Color(0xFFDC2626); // Red
      case 'NEEDSINFO':
      case 'รอข้อมูลเพิ่มเติม':
        return const Color(0xFFEA580C); // Orange
      case 'PENDING':
      case 'รอตอบรับ':
      case 'รอการตอบรับ':
      default:
        return const Color(0xFFD97706); // Amber
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final statusColor = _statusColor(_currentStatus);
    final statusLabel = _statusLabel(_currentStatus);

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
          'รายละเอียดรายงาน',
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Main Report Details Card ────────────────────────
          _buildMainReportCard(report, statusColor, statusLabel),

          const SizedBox(height: 20),

          // ── Section Title: Timeline Header ──────────────────
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: mintLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: darkForest,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ความคืบหน้าการดำเนินการ',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const Spacer(),
              if (_replies.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: mintPillBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_replies.length} อัปเดต',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: mintDark,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Progress Timeline Container ─────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEAF3EE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(emeraldTint),
                        strokeWidth: 3,
                      ),
                    ),
                  )
                : _error != null
                ? _buildErrorView()
                : _replies.isEmpty
                ? _buildEmptyTimelineView()
                : Column(
                    children: [
                      for (var i = 0; i < _replies.length; i++)
                        _buildTimelineItem(_replies[i], i == _replies.length - 1),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// การ์ดแสดงข้อมูลรายงานหลัก
  Widget _buildMainReportCard(
    ReportResponse report,
    Color statusColor,
    String statusLabel,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAF3EE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // แท็กประเภท และ ป้ายสถานะปัจจุบัน
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: mintLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 13,
                      color: darkForest,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'รายงานเหตุการณ์',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: darkForest,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // หัวข้อรายงาน
          Text(
            report.name,
            style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.w800,
              color: textDark,
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 10),

          // รายละเอียดเนื้อหา
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEF2F6)),
            ),
            child: Text(
              report.description.trim().isNotEmpty
                  ? report.description
                  : 'ไม่มีรายละเอียดเพิ่มเติม',
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: Color(0xFF334155),
              ),
            ),
          ),

          // ภาพประกอบ (ถ้ามี)
          if (report.image != null && report.image!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                resolveImageUrl(report.image, defaultCategory: 'reports'),
                width: double.infinity,
                height: 210,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          // ข้อมูลอุทยาน + วันเวลาแจ้ง
          Row(
            children: [
              _buildSubstringIconBadge(report.parkName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.parkName.trim().isNotEmpty
                          ? report.parkName
                          : 'อุทยาน #${report.parkId}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${report.reportDate} ${report.reportTime}'.trim(),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ไอเท็มแสดงในไทม์ไลน์ความคืบหน้า
  Widget _buildTimelineItem(ReplyReportResponse reply, bool isLast) {
    final statusColor = _statusColor(reply.currentStatus);
    final statusLabel = _statusLabel(reply.currentStatus);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // กราฟฟิกจุดและเส้นเชื่อมไทม์ไลน์
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // กล่องข้อมูลความคืบหน้า
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${reply.updateDate} ${reply.updateTime}'.trim(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  if (reply.progress.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEDF2F7)),
                      ),
                      child: Text(
                        reply.progress,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],

                  if (reply.parkRangerName?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          size: 13,
                          color: emeraldTint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'เจ้าหน้าที่ผู้รับผิดชอบ: ${reply.parkRangerName}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              shortName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 7.5,
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

  Widget _buildEmptyTimelineView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: mintLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 36,
              color: emeraldTint,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'อยู่ระหว่างดำเนินการ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'เจ้าหน้าที่กำลังตรวจสอบและจะรายงานความคืบหน้าที่นี่',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Text(
            _error!,
            style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _loadReplies,
            icon: const Icon(Icons.refresh, size: 16, color: darkForest),
            label: const Text(
              'ลองใหม่',
              style: TextStyle(color: darkForest, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
