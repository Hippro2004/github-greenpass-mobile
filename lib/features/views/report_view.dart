import 'package:flutter/material.dart';
import 'package:greenpass/dtos/report_response.dart';
import 'package:greenpass/features/services/report_service.dart';
import 'package:greenpass/features/views/add_report_view.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final ReportService _reportService = ReportService();
  bool _isLoading = true;
  List<ReportResponse> _reports = [];
  String? _error;

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color leafGreen = Color(0xFF52B788);
  static const Color softGreen = Color(0xFFD8F3DC);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color warmGold = Color(0xFFB7791F);

  int get _parkCount => _reports.map((report) => report.parkId).toSet().length;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await _reportService.getMyReport();
      if (!mounted) return;
      setState(() {
        _reports = reports.result!;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "ไม่สามารถโหลดข้อมูลได้";
        _isLoading = false;
      });
    }
  }

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
        title: const Text(
          "รายงานของฉัน",
          style: TextStyle(color: forestGreen, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final reportAdded = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddReportView()),
          );
          if (reportAdded == true) {
            await _loadReports();
          }
        },
        backgroundColor: forestGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(forestGreen),
              ),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadReports,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forestGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text("ลองใหม่"),
                  ),
                ],
              ),
            )
          : _reports.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.report_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "ยังไม่มีรายงาน",
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "รายงานของคุณจะแสดงที่นี่",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [forestGreen, leafGreen],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: forestGreen.withOpacity(0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.fact_check_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "รายงานจาก $_parkCount อุทยาน",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "รายงานทั้งหมด ${_reports.length} รายการ",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.75),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.separated(
                      itemCount: _reports.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildReportCard(_reports[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildReportCard(ReportResponse report) {
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: softGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.report_outlined, color: forestGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.parkName.trim().isEmpty
                      ? "อุทยาน #${report.parkId}"
                      : report.parkName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: forestGreen,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  report.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 11,
                      color: warmGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.reportDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStatusProgress(report.status),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: softGreen, shape: BoxShape.circle),
            child: const Icon(Icons.chevron_right, color: forestGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusProgress(String status) {
    final statusColor = _statusColor(status);

    return Row(
      children: [
        Icon(_statusIcon(status), size: 14, color: statusColor),
        const SizedBox(width: 4),
        Text(
          _statusLabel(status),
          style: TextStyle(
            color: statusColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _statusLabel(String status) {
    switch (status.trim().toUpperCase()) {
      case "ACKNOWLEDGED":
        return "รับเรื่องแล้ว";
      case "IN_PROGRESS":
        return "กำลังดำเนินการ";
      case "RESOLVED":
        return "แก้ไขแล้ว";
      case "CLOSED":
        return "ปิดเรื่องแล้ว";
      case "REJECTED":
        return "ไม่รับเรื่อง";
      case "NEEDS_INFO":
        return "รอข้อมูลเพิ่มเติม";
      default:
        return "รอตอบรับ";
    }
  }

  Color _statusColor(String status) {
    switch (status.trim().toUpperCase()) {
      case "IN_PROGRESS":
        return const Color(0xFF2563EB);
      case "RESOLVED":
      case "CLOSED":
        return forestGreen;
      case "REJECTED":
        return const Color(0xFFDC2626);
      case "NEEDS_INFO":
        return warmGold;
      default:
        return warmGold;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.trim().toUpperCase()) {
      case "ACKNOWLEDGED":
        return Icons.mark_email_read_outlined;
      case "IN_PROGRESS":
        return Icons.engineering_outlined;
      case "RESOLVED":
        return Icons.task_alt_outlined;
      case "CLOSED":
        return Icons.verified_outlined;
      case "REJECTED":
        return Icons.block_outlined;
      case "NEEDS_INFO":
        return Icons.help_outline;
      default:
        return Icons.hourglass_empty_outlined;
    }
  }
}
