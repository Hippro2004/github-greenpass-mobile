import 'dart:async';
import 'package:flutter/material.dart';
import 'package:greenpass/features/report/dtos/report_response.dart';
import 'package:greenpass/features/report/services/report_service.dart';
import 'package:greenpass/features/report/views/add_report_view.dart';
import 'package:greenpass/features/report/views/park_reports_view.dart';
import 'package:greenpass/features/notification/services/notification_websocket_service.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final ReportService _reportService = ReportService();
  StreamSubscription? _wsSub;
  bool _isLoading = true;
  List<ReportResponse> _reports = [];
  String? _error;

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color leafGreen = Color(0xFF52B788);
  static const Color softGreen = Color(0xFFD8F3DC);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color warmGold = Color(0xFFB7791F);

  Map<int, List<ReportResponse>> get _reportsByPark {
    final grouped = <int, List<ReportResponse>>{};
    for (final report in _reports) {
      grouped.putIfAbsent(report.parkId, () => []).add(report);
    }
    return grouped;
  }

  List<ReportResponse> get _parks {
    return _reportsByPark.values.map((reports) => reports.first).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadReports();
    _wsSub = NotificationWebSocketService.instance.notificationStream.listen((
      _,
    ) {
      if (!mounted) return;
      _loadReports();
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadReports() async {
    try {
      final reports = await _reportService.getMyReport();
      if (!mounted) return;
      setState(() {
        _reports = reports;
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
                          color: forestGreen.withValues(alpha: 0.25),
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
                                "รายงานจาก ${_parks.length} อุทยาน",
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
                                  color: Colors.white.withValues(alpha: 0.75),
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
                      itemCount: _parks.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final parkReport = _parks[index];
                        return _buildParkCard(
                          parkReport,
                          _reportsByPark[parkReport.parkId]!,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildParkCard(
    ReportResponse report,
    List<ReportResponse> parkReports,
  ) {
    final parkName = report.parkName.trim().isEmpty
        ? "อุทยาน #${report.parkId}"
        : report.parkName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ParkReportsView(parkName: parkName, reports: parkReports),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Badge/Thumbnail (Substring Icon Badge)
              _buildSubstringIconBadge(parkName),
              const SizedBox(width: 14),

              // Title and reports count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: softGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "อุทยานแห่งชาติ",
                        style: TextStyle(
                          fontSize: 10,
                          color: forestGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      parkName,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.description_outlined,
                          size: 14,
                          color: warmGold,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "มีรายงาน ${parkReports.length} รายการ",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Chevron right button
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: softGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: forestGreen,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// สร้างไอคอน Badge อัตโนมัติโดยการตัดคำ (substring) จากชื่ออุทยาน
  Widget _buildSubstringIconBadge(String rawParkName) {
    // 1. ตัดคำว่า "อุทยานแห่งชาติ" ออกด้วย substring
    String shortName = rawParkName.trim();
    if (shortName.startsWith("อุทยานแห่งชาติ")) {
      shortName = shortName.substring("อุทยานแห่งชาติ".length).trim();
    }
    if (shortName.isEmpty) {
      shortName = rawParkName;
    }

    // 2. วิเคราะห์คำในชื่ออุทยาน (substring) เพื่อเลือกประเภทไอคอนและคู่สีกราเดียนต์
    final name = rawParkName;
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
      width: 64,
      height: 64,
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
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              shortName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
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
}
