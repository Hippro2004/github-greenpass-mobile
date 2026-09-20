import 'package:flutter/material.dart';
import 'package:greenpass/features/park/models/park.dart';
import 'package:greenpass/features/park/services/park_service.dart';
import 'package:greenpass/features/park/views/park_detail_view.dart';

class ParkSearchView extends StatefulWidget {
  const ParkSearchView({super.key, this.onParkSelected});

  final ValueChanged<Park>? onParkSelected;

  @override
  State<ParkSearchView> createState() => _ParkSearchViewState();
}

class _ParkSearchViewState extends State<ParkSearchView> {
  final ParkService _parkService = ParkService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Park> _allParks = [];
  List<Park> _filteredParks = [];
  bool _isLoading = false;

  // ── Vibrant Wilderness Color Palette (DESIGN.md) ───────────
  static const Color screenBg = Color(0xFFF6FAF7);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color primaryGreen = Color(0xFF006D43);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color mintLight = Color(0xFFE8F7F0);
  static const Color mintBorder = Color(0xFFD6EFE2);
  static const Color textDark = Color(0xFF091E25);
  static const Color textMuted = Color(0xFF64748B);
  static const Color bottomBannerBg = Color(0xFF1E293B);

  @override
  void initState() {
    super.initState();
    _loadAllParks();
    _searchController.addListener(_applyFilters);
  }

  void _applyFilters() {
    final keyword = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredParks = _allParks.where((park) {
        return keyword.isEmpty ||
            park.name.toLowerCase().contains(keyword) ||
            (park.address?.toLowerCase().contains(keyword) ?? false) ||
            (park.description?.toLowerCase().contains(keyword) ?? false);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadAllParks() async {
    setState(() => _isLoading = true);
    try {
      final parks = await _parkService.searchParks('');
      if (!mounted) return;
      setState(() {
        _allParks = parks;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top App Bar ─────────────────────────────────
            _buildTopAppBar(),

            // ── Search Bar ──────────────────────────────────
            _buildSearchBar(),

            // ── Results Summary Header ──────────────────────
            _buildSummaryRow(),

            // ── Park Cards List ─────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                        strokeWidth: 3,
                      ),
                    )
                  : _filteredParks.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: _filteredParks.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final park = _filteredParks[index];
                            return _buildParkCard(park);
                          },
                        ),
            ),

            // ── Bottom Online Reservation Banner ────────────
            _buildBottomBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left back button
          GestureDetector(
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

          // Center title with vibrant green dot
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "ค้นหาอุทยาน",
                style: TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: emeraldTint,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          // Right map button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.map_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text("ระบบแผนที่อุทยานแบบอินเทอร์แอคทีฟ"),
                    ],
                  ),
                  backgroundColor: darkForest,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: mintLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: mintBorder),
              ),
              child: const Icon(
                Icons.map_outlined,
                color: darkForest,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: mintBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textDark,
          ),
          decoration: InputDecoration(
            hintText: "ค้นหาชื่ออุทยาน...",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: emeraldTint,
              size: 24,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _applyFilters();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "พบ ${_filteredParks.length} อุทยานแห่งชาติ",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _applyFilters();
              },
              child: const Text(
                "ล้างการค้นหา",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: emeraldTint,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParkCard(Park park) {
    String? statusTag;
    Color statusBg = mintLight;
    Color statusColor = primaryGreen;

    if (park.isTemporaryClosed == true) {
      statusTag = "ปิดชั่วคราว";
      statusBg = const Color(0xFFFEE2E2);
      statusColor = const Color(0xFFE11D48);
    } else if (park.isSeasonalPark == true) {
      statusTag = "เปิดตามฤดูกาล";
      statusBg = const Color(0xFFFEF3C7);
      statusColor = const Color(0xFFD97706);
    } else if (park.status != null && park.status!.isNotEmpty) {
      statusTag = park.status!;
    }

    return GestureDetector(
      onTap: () {
        if (widget.onParkSelected != null) {
          widget.onParkSelected!(park);
          Navigator.pop(context);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ParkDetailView(park: park)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // ── Left Park Photo or Clean Placeholder ─────────
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 68,
                height: 68,
                color: mintLight,
                child: park.image != null
                    ? Image.asset(
                        'assets/images/${park.image}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, exception, stackTrace) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),

            const SizedBox(width: 14),

            // ── Middle Information ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status Tag (if any)
                  if (statusTag != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusTag,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],

                  // Park Title
                  Text(
                    park.name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Location snippet
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12.5,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          park.address ?? (park.location ?? '-'),
                          style: const TextStyle(
                            fontSize: 11,
                            color: textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Right Mint Circular Chevron ────────────────
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: mintLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: primaryGreen,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.park_rounded,
        color: primaryGreen,
        size: 32,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: mintLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forest_rounded,
              size: 46,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "ไม่พบอุทยานที่ค้นหา",
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "ลองเปลี่ยนคำค้นหาใหม่อีกครั้ง",
            style: TextStyle(color: textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBanner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bottomBannerBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),

            const Expanded(
              child: Text(
                "เปิดระบบจองบ้านพักออนไลน์",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "เช็คคิว",
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 3),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF34D399),
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
