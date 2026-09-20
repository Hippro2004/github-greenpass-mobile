import 'package:flutter/material.dart';
import 'package:greenpass/features/stamp/dtos/stamp_response.dart';
import 'package:greenpass/features/stamp/services/stamp_service.dart';
import 'package:greenpass/features/stamp/views/book_stamp_details.dart';

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

  // ── Vibrant Wilderness Theme Palette (ตามแบบ DESIGN.md / screen.png) ───────────
  static const Color screenBg = Color(0xFFF3F7F5);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color midForest = Color(0xFF0F5A3E);
  static const Color warmEarth = Color(0xFF78350F);

  static const Color mintPillBg = Color(0xFFD1FAE5);
  static const Color mintDark = Color(0xFF065F46);
  static const Color mintAction = Color(0xFFE8F7F0);
  static const Color iconGreen = Color(0xFF059669);

  static const Color amberIcon = Color(0xFFD97706);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

  static int _compareStampsDesc(StampResponse a, StampResponse b) {
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
    final cmp = dtB.compareTo(dtA);
    if (cmp != 0) return cmp;
    return b.stampId.compareTo(a.stampId);
  }

  Map<int, List<StampResponse>> get _stampsByPark {
    final grouped = <int, List<StampResponse>>{};
    for (final stamp in _stamps) {
      grouped.putIfAbsent(stamp.parkId, () => []).add(stamp);
    }
    for (final list in grouped.values) {
      list.sort(_compareStampsDesc);
    }
    return grouped;
  }

  List<StampResponse> get _parks {
    final parkList =
        _stampsByPark.values.map((stamps) => stamps.first).toList();
    parkList.sort(_compareStampsDesc);
    return parkList;
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
        _stamps = stamps;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "ไม่สามารถโหลดข้อมูลแสตมป์ได้ กรุณาลองอีกครั้ง\n$e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: mintAction,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF134E39),
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "สมุดบันทึกการเดินทาง",
          style: TextStyle(
            color: Color(0xFF0F2E23),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: mintAction,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF134E39),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(iconGreen),
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
                          onPressed: _loadStamps,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text("ลองใหม่"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: iconGreen,
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
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: mintAction,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Icon(
                      Icons.park_outlined,
                      size: 52,
                      color: iconGreen,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "ยังไม่มีแสตมป์",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "เริ่มต้นการเดินทางและรับแสตมป์แรกของคุณ",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero Stats Banner ─────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [darkForest, midForest, warmEarth],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: darkForest.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -25,
                            top: -10,
                            child: Transform.rotate(
                              angle: -0.15,
                              child: Icon(
                                Icons.star_rounded,
                                size: 150,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF063A27),
                                    border: Border.all(
                                      color: const Color(0xFF22C55E)
                                          .withValues(alpha: 0.4),
                                      width: 2.5,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.park_rounded,
                                      color: Color(0xFFFCD34D),
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "OFFICIAL PASSPORT",
                                          style: TextStyle(
                                            color: Color(0xFFE2E8F0),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.9,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "สะสมแล้ว ${_parks.length} อุทยาน",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "เข้าเยี่ยมชมทั้งหมด ${_stamps.length} ครั้ง",
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section Title ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "อุทยานที่คุณได้ประทับตรา",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: mintPillBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${_parks.length} แห่ง",
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: mintDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Park Cards List ────────────────────────────
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 12),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
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
    );
  }

  Widget _buildParkCard(StampResponse stamp, int visitCount) {
    final parkName = stamp.parkName.trim().isNotEmpty
        ? stamp.parkName
        : "อุทยาน #${stamp.parkId}";

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookStampDetails(stamp: stamp),
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

              // Title and visits
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
                        color: mintPillBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "อุทยานแห่งชาติ",
                        style: TextStyle(
                          fontSize: 10,
                          color: mintDark,
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
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_walk_rounded,
                          size: 14,
                          color: amberIcon,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "เข้าเยี่ยมชม $visitCount ครั้ง",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
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
                  color: mintAction,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: mintDark,
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
      width: 68,
      height: 68,
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
          Icon(icon, color: Colors.white, size: 28),
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
