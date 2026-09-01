import 'package:flutter/material.dart';
import 'package:greenpass/features/stamp/models/stamp.dart';
import 'package:greenpass/features/stamp/services/stamp_service.dart';

class BookStampDetails extends StatefulWidget {
  final Stamp stamp;

  const BookStampDetails({super.key, required this.stamp});

  @override
  State<BookStampDetails> createState() => _BookStampDetailsState();
}

class _BookStampDetailsState extends State<BookStampDetails> {
  final StampService _stampService = StampService();
  List<Stamp> _histories = [];

  bool _isLoading = true;
  String? _error;

  static const Color deepPurple = Color(0xFF4A2E83);
  static const Color midPurple = Color(0xFF7C4DCC);
  static const Color lightPurple = Color(0xFFB79CED);
  static const Color lavenderBg = Color(0xFFF6F3FB);
  static const Color cardLavender = Color(0xFFEEE6FB);

  String _formatTime(String time) {
    final trimmed = time.trim();
    if (trimmed.isEmpty) return "-";
    if (trimmed.endsWith("น.") || trimmed.toLowerCase().contains("m")) {
      return trimmed;
    }
    return "$trimmed น.";
  }

  String _formatDateTime(String date, String time) {
    final d = date.trim();
    final t = time.trim();
    if (d.isEmpty && t.isEmpty) return "-";
    if (d.isNotEmpty && t.isNotEmpty) {
      return "$d  ${_formatTime(t)}";
    }
    if (d.isNotEmpty) return d;
    return _formatTime(t);
  }

  List<Stamp> get _allVisits {
    if (_histories.isEmpty) {
      return [widget.stamp];
    }
    return _histories;
  }

  Stamp get _firstStamp {
    final visits = _allVisits;
    final sorted = List<Stamp>.from(visits)
      ..sort((a, b) {
        final timeA = a.time.trim().isNotEmpty ? a.time.trim() : "00:00:00";
        final timeB = b.time.trim().isNotEmpty ? b.time.trim() : "00:00:00";
        final dtA =
            DateTime.tryParse('${a.stampDate} $timeA') ??
            DateTime.tryParse(a.stampDate) ??
            DateTime(1970);
        final dtB =
            DateTime.tryParse('${b.stampDate} $timeB') ??
            DateTime.tryParse(b.stampDate) ??
            DateTime(1970);
        return dtA.compareTo(dtB);
      });
    return sorted.first;
  }

  Stamp get _latestStamp {
    final visits = _allVisits;
    final sorted = List<Stamp>.from(visits)
      ..sort((a, b) {
        final timeA = a.time.trim().isNotEmpty ? a.time.trim() : "00:00:00";
        final timeB = b.time.trim().isNotEmpty ? b.time.trim() : "00:00:00";
        final dtA =
            DateTime.tryParse('${a.stampDate} $timeA') ??
            DateTime.tryParse(a.stampDate) ??
            DateTime(1970);
        final dtB =
            DateTime.tryParse('${b.stampDate} $timeB') ??
            DateTime.tryParse(b.stampDate) ??
            DateTime(1970);
        return dtA.compareTo(dtB);
      });
    return sorted.last;
  }

  List<Stamp> get _sortedHistories {
    final visits = _allVisits;
    final sorted = List<Stamp>.from(visits)
      ..sort((a, b) {
        final timeA = a.time.trim().isNotEmpty ? a.time.trim() : "00:00:00";
        final timeB = b.time.trim().isNotEmpty ? b.time.trim() : "00:00:00";
        final dtA =
            DateTime.tryParse('${a.stampDate} $timeA') ??
            DateTime.tryParse(a.stampDate) ??
            DateTime(1970);
        final dtB =
            DateTime.tryParse('${b.stampDate} $timeB') ??
            DateTime.tryParse(b.stampDate) ??
            DateTime(1970);
        return dtB.compareTo(dtA); // ล่าสุดขึ้นก่อน
      });
    return sorted;
  }

  Future<void> _loadStampDetails() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final histories = await _stampService.getStampDetails(
        widget.stamp.parkId,
      );
      if (!mounted) return;
      setState(() {
        _histories = histories.result ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "ไม่สามารถโหลดข้อมูลได้\n$e";
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _loadStampDetails();
    super.initState();
  }

  Widget _buildPlaceholderHeader() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [deepPurple, midPurple],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: deepPurple.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.auto_stories,
              size: 110,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.forest_outlined,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.stamp.parkName.isNotEmpty
                      ? widget.stamp.parkName
                      : "อุทยาน #${widget.stamp.parkId}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parkTitle = widget.stamp.parkName.isNotEmpty
        ? widget.stamp.parkName
        : "อุทยาน #${widget.stamp.parkId}";

    return Scaffold(
      backgroundColor: lavenderBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(Icons.arrow_back, color: deepPurple, size: 18),
          ),
        ),
        title: Text(
          parkTitle,
          style: const TextStyle(
            color: deepPurple,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(deepPurple),
                strokeWidth: 3,
              ),
            )
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          onPressed: _loadStampDetails,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text("ลองใหม่"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: deepPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // รูป stamp หรือ ส่วนหัวอุทยาน
                  if (widget.stamp.stampImage != null &&
                      widget.stamp.stampImage!.trim().isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/${widget.stamp.stampImage}',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderHeader(),
                      ),
                    )
                  else
                    _buildPlaceholderHeader(),
                  const SizedBox(height: 16),

                  // การ์ดข้อมูล stamp
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: deepPurple.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.forest_outlined,
                          "อุทยาน",
                          parkTitle,
                        ),
                        const Divider(height: 18),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          "ประทับครั้งแรก",
                          _formatDateTime(
                            _firstStamp.stampDate,
                            _firstStamp.time,
                          ),
                        ),
                        const Divider(height: 18),
                        _buildInfoRow(
                          Icons.update_outlined,
                          "ประทับล่าสุด",
                          _formatDateTime(
                            _latestStamp.stampDate,
                            _latestStamp.time,
                          ),
                        ),
                        const Divider(height: 18),
                        _buildInfoRow(
                          Icons.pin_drop_outlined,
                          "จำนวนการประทับ",
                          "${_allVisits.length} ครั้ง",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ส่วนประวัติการประทับ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "ประวัติการเข้าเยี่ยมชม",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: deepPurple,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: lightPurple.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_sortedHistories.length} รายการ",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sortedHistories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final history = _sortedHistories[index];
                      final visitNumber = _sortedHistories.length - index;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: deepPurple.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: cardLavender,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "#$visitNumber",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: deepPurple,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "วันที่ประทับ",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 13,
                                        color: deepPurple,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        history.stampDate.isNotEmpty
                                            ? history.stampDate
                                            : "-",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (history.time.trim().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: lightPurple.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: lightPurple.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time_filled,
                                      size: 13,
                                      color: midPurple,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      _formatTime(history.time),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: deepPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: deepPurple, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: deepPurple.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
