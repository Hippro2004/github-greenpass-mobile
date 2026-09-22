import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/core/network/image_helper.dart';
import 'package:greenpass/features/stamp/dtos/stamp_response.dart';
import 'package:greenpass/features/stamp/services/stamp_service.dart';

class BookStampDetails extends StatefulWidget {
  final StampResponse stamp;

  const BookStampDetails({super.key, required this.stamp});

  @override
  State<BookStampDetails> createState() => _BookStampDetailsState();
}

class _BookStampDetailsState extends State<BookStampDetails> {
  final StampService _stampService = StampService();
  List<StampResponse> _histories = [];

  bool _isLoading = true;
  String? _error;

  // ── Vibrant Wilderness Theme Palette (ตามแบบ screen.png) ───────────
  static const Color screenBg = Color(0xFFF3F7F5);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color midForest = Color(0xFF0F5A3E);
  static const Color warmEarth = Color(0xFF78350F);

  static const Color mintLight = Color(0xFFE2F7ED);
  static const Color mintPillBg = Color(0xFFD1FAE5);
  static const Color mintDark = Color(0xFF065F46);
  static const Color mintAction = Color(0xFFE8F7F0);
  static const Color iconGreen = Color(0xFF059669);

  static const Color amberBadge = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color amberDark = Color(0xFF92400E);
  static const Color amberIcon = Color(0xFFD97706);

  static const Color roseLight = Color(0xFFFFE4E6);
  static const Color roseIcon = Color(0xFFE11D48);

  static const Color tealIcon = Color(0xFF0D9488);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);

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
      return "$d ${_formatTime(t)}";
    }
    if (d.isNotEmpty) return d;
    return _formatTime(t);
  }

  List<StampResponse> get _allVisits {
    if (_histories.isEmpty) {
      return [widget.stamp];
    }
    return _histories;
  }

  StampResponse get _firstStamp {
    final visits = _allVisits;
    final sorted = List<StampResponse>.from(visits)
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

  StampResponse get _latestStamp {
    final visits = _allVisits;
    final sorted = List<StampResponse>.from(visits)
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

  List<StampResponse> get _sortedHistories {
    final visits = _allVisits;
    final sorted = List<StampResponse>.from(visits)
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
      final loadedHistories = histories;
      final mergedHistories = loadedHistories.map((history) {
        if (history.stampId != widget.stamp.stampId) return history;

        return history.copyWith(
          parkName: history.parkName.trim().isEmpty
              ? widget.stamp.parkName
              : history.parkName,
          parkRangerName: history.parkRangerName.trim().isEmpty
              ? widget.stamp.parkRangerName
              : history.parkRangerName,
          signature: history.signature.trim().isEmpty
              ? widget.stamp.signature
              : history.signature,
        );
      }).toList();
      final hasSelectedStamp = mergedHistories.any(
        (history) => history.stampId == widget.stamp.stampId,
      );
      setState(() {
        _histories = hasSelectedStamp
            ? mergedHistories
            : [...mergedHistories, widget.stamp];
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

  // String _getParkSubtitle(String parkName) {
  //   if (parkName.contains("เขาใหญ่")) {
  //     return "Khao Yai National Park • World Heritage Site";
  //   }
  //   return "$parkName • Thailand National Park";
  // }

  void _showSignatureDialog(
    BuildContext context,
    String signaturePath,
    String rangerName,
  ) {
    final resolvedUrl = resolveImageUrl(
      signaturePath,
      defaultCategory: 'signatures',
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "ตราประทับและลายมือชื่อ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: screenBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: resolvedUrl.trim().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: InteractiveViewer(
                          maxScale: 3.5,
                          child: CachedNetworkImage(
                            imageUrl: resolvedUrl,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: iconGreen,
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.draw_outlined,
                                    size: 48,
                                    color: Colors.black26,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "ไม่สามารถโหลดรูปลายมือชื่อได้",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.draw_outlined,
                              size: 48,
                              color: Colors.black26,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "ไม่มีข้อมูลลายมือชื่อ",
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: mintLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: darkForest,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rangerName.trim().isNotEmpty
                          ? "เจ้าหน้าที่: $rangerName"
                          : "เจ้าหน้าที่อุทยานแห่งชาติ",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: darkForest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStampHeroHeader(String parkTitle) {
    final heroSignature = _latestStamp.signature.trim().isNotEmpty
        ? _latestStamp.signature
        : widget.stamp.signature;
    final heroRanger = _latestStamp.parkRangerName.trim().isNotEmpty
        ? _latestStamp.parkRangerName
        : widget.stamp.parkRangerName;
    final hasSignature = heroSignature.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkForest, midForest, warmEarth],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: darkForest.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Watermark Star
            Positioned(
              right: -30,
              top: 10,
              child: Transform.rotate(
                angle: -0.15,
                child: Icon(
                  Icons.star_rounded,
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular Stamp Badge
                  GestureDetector(
                    onTap: hasSignature
                        ? () => _showSignatureDialog(
                            context,
                            heroSignature,
                            heroRanger,
                          )
                        : null,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF063A27),
                            border: Border.all(
                              color: const Color(
                                0xFF22C55E,
                              ).withValues(alpha: 0.35),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            painter: const DashedCirclePainter(
                              color: Color(0xFFFBBF24),
                              strokeWidth: 2,
                              dashes: 22,
                            ),
                            child: Center(
                              child: ClipOval(
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: hasSignature
                                      ? CachedNetworkImage(
                                          imageUrl: resolveImageUrl(
                                            heroSignature,
                                            defaultCategory: 'signatures',
                                          ),
                                          fit: BoxFit.contain,
                                          placeholder: (_, _) => const Center(
                                            child: Icon(
                                              Icons.park_rounded,
                                              color: Color(0xFFFCD34D),
                                              size: 44,
                                            ),
                                          ),
                                          errorWidget: (_, _, _) =>
                                              const Center(
                                            child: Icon(
                                              Icons.park_rounded,
                                              color: Color(0xFFFCD34D),
                                              size: 44,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.park_rounded,
                                          color: Color(0xFFFCD34D),
                                          size: 44,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(
                              color: amberBadge,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Color(0xFF0F172A),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pill: OFFICIAL PASSPORT STAMP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          "OFFICIAL PASSPORT STAMP",
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Park Title
                  Text(
                    parkTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),

                  // Subtitle
                  // Text(
                  //   _getParkSubtitle(parkTitle),
                  //   style: TextStyle(
                  //     color: const Color(0xFFE2E8F0).withValues(alpha: 0.85),
                  //     fontSize: 12.5,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parkTitle = widget.stamp.parkName.isNotEmpty
        ? widget.stamp.parkName
        : "อุทยาน #${widget.stamp.parkId}";

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
        title: Text(
          parkTitle,
          style: const TextStyle(
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
                  Icons.verified_user_outlined,
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
                          onPressed: _loadStampDetails,
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
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ส่วนหัว Stamp Hero Header ตาม screen.png
                  _buildStampHeroHeader(parkTitle),
                  const SizedBox(height: 18),

                  // การ์ดข้อมูล Stamp 4 แถวตาม screen.png
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildRowItem(
                          icon: Icons.park_rounded,
                          iconBg: mintLight,
                          iconColor: iconGreen,
                          label: "อุทยาน",
                          valueWidget: Text(
                            parkTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const Divider(
                          height: 24,
                          thickness: 0.8,
                          color: Color(0xFFF1F5F9),
                        ),
                        _buildRowItem(
                          icon: Icons.calendar_today_rounded,
                          iconBg: amberLight,
                          iconColor: amberIcon,
                          label: "ประทับครั้งแรก",
                          valueWidget: Text(
                            _formatDateTime(
                              _firstStamp.stampDate,
                              _firstStamp.time,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        const Divider(
                          height: 24,
                          thickness: 0.8,
                          color: Color(0xFFF1F5F9),
                        ),
                        _buildRowItem(
                          icon: Icons.access_time_rounded,
                          iconBg: mintPillBg,
                          iconColor: tealIcon,
                          label: "ประทับล่าสุด",
                          valueWidget: Text(
                            _formatDateTime(
                              _latestStamp.stampDate,
                              _latestStamp.time,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        const Divider(
                          height: 24,
                          thickness: 0.8,
                          color: Color(0xFFF1F5F9),
                        ),
                        _buildRowItem(
                          icon: Icons.location_on_rounded,
                          iconBg: roseLight,
                          iconColor: roseIcon,
                          label: "จำนวนการประทับ",
                          valueWidget: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: mintPillBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${_allVisits.length} ครั้ง",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: mintDark,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ส่วนหัวข้อ: ประวัติการเยี่ยมชม
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "ประวัติการเยี่ยมชม",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: mintPillBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${_sortedHistories.length} รายการ",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: mintDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // รายการการ์ดประวัติการเข้าชม
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sortedHistories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final history = _sortedHistories[index];
                      final visitNumber = _sortedHistories.length - index;

                      return Container(
                        padding: const EdgeInsets.all(16),
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: amberBadge,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: amberBadge.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "#$visitNumber",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "วันที่ประทับ",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
                                            color: Color(0xFF10B981),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            history.stampDate.isNotEmpty
                                                ? history.stampDate
                                                : "-",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: textPrimary,
                                              fontWeight: FontWeight.w800,
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
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: amberLight,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFFDE68A),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.access_time_filled_rounded,
                                          size: 13,
                                          color: amberIcon,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _formatTime(history.time),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: amberDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            if (history.parkRangerName.trim().isNotEmpty ||
                                history.signature.trim().isNotEmpty) ...[
                              const Divider(
                                height: 22,
                                thickness: 0.8,
                                color: Color(0xFFF1F5F9),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF0FDF4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_outline_rounded,
                                      color: Color(0xFF10B981),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "เจ้าหน้าที่",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          history.parkRangerName.trim().isEmpty
                                              ? "-"
                                              : history.parkRangerName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => _showSignatureDialog(
                                      context,
                                      history.signature,
                                      history.parkRangerName,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: mintAction,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(0xFFA7F3D0),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            size: 14,
                                            color: iconGreen,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "ตราประทับ",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: mintDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  Widget _buildRowItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required Widget valueWidget,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 19),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: valueWidget,
            ),
          ),
        ),
      ],
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashes;
  final double gapRatio;

  const DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashes = 22,
    this.gapRatio = 0.35,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const totalAngle = 2 * 3.141592653589793;
    final dashAngle = (totalAngle / dashes) * (1 - gapRatio);
    final gapAngle = (totalAngle / dashes) * gapRatio;

    for (int i = 0; i < dashes; i++) {
      final startAngle = i * (dashAngle + gapAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashes != dashes;
  }
}
