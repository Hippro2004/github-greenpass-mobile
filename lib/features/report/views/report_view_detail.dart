import 'dart:async';
import 'package:flutter/material.dart';
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

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color warmGold = Color(0xFFB7791F);

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
            backgroundColor: forestGreen,
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
        return forestGreen; // Green
      case 'ACKNOWLEDGED':
      case 'รับเรื่องแล้ว':
        return const Color(0xFF0284C7); // Sky blue
      case 'REJECTED':
      case 'CANCELLED':
      case 'CANCELED':
      case 'ไม่รับเรื่อง':
        return const Color(0xFFDC2626); // Red
      case 'NEEDSINFO':
      case 'รอข้อมูลเพิ่มเติม':
        return const Color(0xFFD97706); // Orange
      case 'PENDING':
      case 'รอตอบรับ':
      case 'รอการตอบรับ':
      default:
        return warmGold; // Gold/Amber
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: warmGold),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _replyItem(ReplyReportResponse reply, bool isLast) {
    final statusColor = _statusColor(reply.currentStatus);
    final statusLabel = _statusLabel(reply.currentStatus);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: Colors.grey.shade200),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${reply.updateDate} ${reply.updateTime}'.trim(),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  if (reply.progress.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      reply.progress,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  if (reply.parkRangerName?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: 6),
                    Text(
                      'ผู้ดำเนินการ: ${reply.parkRangerName}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final statusColor = _statusColor(_currentStatus);

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
        title: const Text(
          'รายละเอียดรายงาน',
          style: TextStyle(color: forestGreen, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        report.name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(_currentStatus),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  report.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Divider(height: 28),
                _infoRow(Icons.forest_outlined, 'อุทยาน', report.parkName),
                const SizedBox(height: 14),
                _infoRow(
                  Icons.calendar_today_outlined,
                  'วันที่แจ้ง',
                  '${report.reportDate} ${report.reportTime}'.trim(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'ความคืบหน้าการดำเนินการ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(color: forestGreen),
                    ),
                  )
                : _error != null
                ? _errorView()
                : _replies.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'ยังไม่มีการอัปเดต',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < _replies.length; i++)
                        _replyItem(_replies[i], i == _replies.length - 1),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _errorView() => Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
      children: [
        Text(_error!, style: const TextStyle(color: Colors.red)),
        TextButton(onPressed: _loadReplies, child: const Text('ลองใหม่')),
      ],
    ),
  );
}
