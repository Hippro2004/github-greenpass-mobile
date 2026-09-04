import 'package:flutter/material.dart';
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
  List<ReplyReportResponse> _replies = [];
  bool _isLoading = true;
  String? _error;

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color warmGold = Color(0xFFB7791F);

  @override
  void initState() {
    super.initState();
    _loadReplies();
  }

  Future<void> _loadReplies() async {
    try {
      final response = await _replyReportService.getReplyReport(
        widget.report.reportId,
      );
      if (!mounted) return;
      setState(() {
        _replies = response.result ?? [];
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
    switch (status.trim().toUpperCase()) {
      case 'ACKNOWLEDGED':
        return 'รับเรื่องแล้ว';
      case 'IN_PROGRESS':
        return 'กำลังดำเนินการ';
      case 'RESOLVED':
        return 'แก้ไขแล้ว';
      case 'CLOSED':
        return 'ปิดเรื่องแล้ว';
      case 'REJECTED':
        return 'ไม่รับเรื่อง';
      case 'NEEDS_INFO':
        return 'รอข้อมูลเพิ่มเติม';
      default:
        return 'รอตอบรับ';
    }
  }

  Color _statusColor(String status) {
    switch (status.trim().toUpperCase()) {
      case 'IN_PROGRESS':
        return const Color(0xFF2563EB);
      case 'RESOLVED':
      case 'CLOSED':
        return forestGreen;
      case 'REJECTED':
        return const Color(0xFFDC2626);
      default:
        return warmGold;
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
                  decoration: const BoxDecoration(
                    color: forestGreen,
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
                  Text(
                    reply.currentStatus.isEmpty
                        ? 'อัปเดตรายงาน'
                        : _statusLabel(reply.currentStatus),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
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
    final statusColor = _statusColor(report.status);

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
                    const SizedBox(width: 10),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(report.status),
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
