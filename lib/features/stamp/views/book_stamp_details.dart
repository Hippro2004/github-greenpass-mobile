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
  static const Color lavenderBg = Color(0xFFF6F3FB);

  String get _latestVisitDate {
    final dates = [
      widget.stamp.stampDate,
      ..._histories.map((stamp) => stamp.stampDate),
    ].where((date) => date.trim().isNotEmpty).toList();
    if (dates.isEmpty) return "-";

    dates.sort((first, second) {
      final firstDate = DateTime.tryParse(first);
      final secondDate = DateTime.tryParse(second);
      if (firstDate != null && secondDate != null) {
        return firstDate.compareTo(secondDate);
      }
      return first.compareTo(second);
    });
    return dates.last;
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
        _error = "ไม่สามารถโหลดข้อมูลได้";
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _loadStampDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lavenderBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: deepPurple),
        ),
        title: Text(
          widget.stamp.parkName,
          style: const TextStyle(
            color: deepPurple,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(deepPurple),
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
                    onPressed: _loadStampDetails, // ← แก้ตรงนี้
                    style: ElevatedButton.styleFrom(
                      backgroundColor: deepPurple,
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // รูป stamp
                  if (widget.stamp.stampImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/${widget.stamp.stampImage}',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ข้อมูล stamp
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Icons.forest_outlined,
                          "อุทยาน",
                          widget.stamp.parkName,
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.calendar_today_outlined,
                          "ประทับครั้งแรก",
                          widget.stamp.stampDate,
                        ),
                        const Divider(),
                        _buildInfoRow(
                          Icons.update_outlined,
                          "ประทับล่าสุด",
                          _latestVisitDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ประวัติการประทับ
                  const Text(
                    "ประวัติการเข้าเยี่ยมชม",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _histories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final history = _histories[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: midPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                history.stampDate,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: deepPurple, size: 18),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: deepPurple.withOpacity(0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              // fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
