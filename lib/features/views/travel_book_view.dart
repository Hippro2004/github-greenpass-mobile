import 'package:flutter/material.dart';
import 'package:greenpass/dtos/stamp_response.dart';
import 'package:greenpass/features/models/stamp.dart';
import 'package:greenpass/features/services/stamp_service.dart';
import 'package:greenpass/features/views/book_stamp_details.dart';

class TravelBookView extends StatefulWidget {
  const TravelBookView({super.key});

  @override
  State<TravelBookView> createState() => _TravelBookViewState();
}

class _TravelBookViewState extends State<TravelBookView> {
  final StampService _stampService = StampService();
  List<StampResponse> _stamps = [];
  bool _isLoading = true;
  String? _error;

  // ── ธีมม่วง เฉพาะหน้าสมุดบันทึกการเดินทาง ──────────────
  static const Color deepPurple = Color(0xFF4A2E83);
  static const Color midPurple = Color(0xFF7C4DCC);
  static const Color lightPurple = Color(0xFFB79CED);
  static const Color lavenderBg = Color(0xFFF6F3FB);
  static const Color cardLavender = Color(0xFFEEE6FB);
  static const Color mutedGold = Color(0xFFB08D57);

  Map<int, List<StampResponse>> get _stampsByPark {
    final grouped = <int, List<StampResponse>>{};
    for (final stamp in _stamps) {
      grouped.putIfAbsent(stamp.parkId, () => []).add(stamp);
    }
    return grouped;
  }

  List<StampResponse> get _parks {
    return _stampsByPark.values.map((stamps) => stamps.first).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadStamps();
  }

  Future<void> _loadStamps() async {
    try {
      final stamps = await _stampService.getMyStamps();
      if (!mounted) return;
      setState(() {
        _stamps = stamps.result ?? [];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "ไม่สามารถโหลดข้อมูลแสตมป์ได้ กรุณาลองอีกครั้ง";
        _isLoading = false;
      });
    }
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
        title: const Text(
          "สมุดบันทึกการเดินทาง",
          style: TextStyle(
            color: deepPurple,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── ลายตกแต่งพื้นหลังโทนม่วง ────────────────
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lightPurple.withOpacity(0.16),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: deepPurple.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: -10,
            child: Icon(
              Icons.auto_stories,
              size: 70,
              color: deepPurple.withOpacity(0.05),
            ),
          ),

          _isLoading
              ? Center(
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
                            color: Colors.black.withOpacity(0.05),
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
                              color: Colors.red.withOpacity(0.08),
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
                              onPressed: _loadStamps,
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
              : _stamps.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: lightPurple.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_stories_outlined,
                          size: 48,
                          color: deepPurple.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "ยังไม่มีแสตมป์",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "เริ่มต้นการเดินทางและรับแสตมป์แรกของคุณ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
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
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [deepPurple, midPurple],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: deepPurple.withOpacity(0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.collections_bookmark_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "สะสมแล้ว ${_parks.length} อุทยาน",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "เข้าเยี่ยมชมทั้งหมด ${_stamps.length} ครั้ง",
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
                          padding: const EdgeInsets.only(bottom: 8),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemCount: _parks.length,
                          itemBuilder: (context, index) {
                            final stamp = _parks[index];
                            return _buildParkCard(
                              stamp,
                              _stampsByPark[stamp.parkId]!.length,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildParkCard(StampResponse stamp, int visitCount) {
    final parkName = stamp.parkName.trim().isNotEmpty
        ? stamp.parkName
        : "อุทยาน #${stamp.parkId}";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookStampDetails(
                stamp: Stamp(
                  stamp.stampId,
                  null,
                  stamp.stampDate,
                  stamp.parkId,
                  stamp.parkName,
                  0,
                ),
              ),
            ),
          );
        },
        child: Container(
          height: 86,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: deepPurple.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildPlaceholder(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "อุทยาน",
                        style: TextStyle(
                          fontSize: 10,
                          color: deepPurple.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        parkName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_walk_outlined,
                            size: 14,
                            color: mutedGold.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "เข้าเยี่ยมชม $visitCount ครั้ง",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: lightPurple.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: deepPurple,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardLavender, lightPurple.withOpacity(0.35)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_stories,
          color: deepPurple.withOpacity(0.6),
          size: 30,
        ),
      ),
    );
  }
}
