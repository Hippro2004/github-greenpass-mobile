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
  int _selectedCategoryIndex = 0;

  // ── Vibrant Wilderness Color Palette (DESIGN.md) ───────────
  static const Color screenBg = Color(0xFFF6FAF7);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color primaryGreen = Color(0xFF006D43);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color mintLight = Color(0xFFE8F7F0);
  static const Color mintBorder = Color(0xFFD6EFE2);
  static const Color textDark = Color(0xFF091E25);
  static const Color textMuted = Color(0xFF64748B);
  static const Color starAmber = Color(0xFFF59E0B);
  static const Color starText = Color(0xFFD97706);
  static const Color bottomBannerBg = Color(0xFF1E293B);

  final List<Map<String, dynamic>> _categories = const [
    {"title": "ทั้งหมด", "icon": Icons.park_rounded, "color": primaryGreen},
    {"title": "ยอดนิยม", "icon": Icons.star_rounded, "color": starAmber},
    {"title": "มรดกโลก", "icon": Icons.account_balance_rounded, "color": Color(0xFF64748B)},
    {"title": "น้ำตก", "icon": Icons.water_drop_rounded, "color": Color(0xFF0284C7)},
    {"title": "ป่าดิบชื้น", "icon": Icons.eco_rounded, "color": Color(0xFF10B981)},
  ];

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
        final matchesKeyword = keyword.isEmpty ||
            park.name.toLowerCase().contains(keyword) ||
            (park.address?.toLowerCase().contains(keyword) ?? false) ||
            (park.description?.toLowerCase().contains(keyword) ?? false);

        if (!matchesKeyword) return false;

        // Category filter
        switch (_selectedCategoryIndex) {
          case 1: // ยอดนิยม
            return true;
          case 2: // มรดกโลก
            return park.name.contains("เขาใหญ่") ||
                park.name.contains("แก่งกระจาน") ||
                (park.description?.contains("มรดกโลก") ?? false);
          case 3: // น้ำตก
            return park.name.contains("เอราวัณ") ||
                park.name.contains("น้ำตก") ||
                (park.description?.contains("น้ำตก") ?? false);
          case 4: // ป่าดิบชื้น
            return park.name.contains("แก่งกระจาน") ||
                park.name.contains("เขาใหญ่") ||
                (park.description?.contains("ป่า") ?? false);
          default:
            return true;
        }
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

            // ── Category Filter Chips ───────────────────────
            _buildCategoryChips(),

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
            hintText: "อุทยาน",
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategoryIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
              _applyFilters();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? darkForest : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected ? darkForest : const Color(0xFFE2E8F0),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: darkForest.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category["icon"] as IconData,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : (category["color"] as Color),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category["title"] as String,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "พบ ${_filteredParks.length} อุทยานแห่งชาติ",
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: mintLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "เรียงตามความนิยม",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkCard(Park park) {
    final styleData = _getParkStyleData(park);

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
            // ── Left Vibrant Emblem Badge ──────────────────
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: styleData.gradientColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: styleData.gradientColors.first.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    styleData.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      styleData.slug,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // ── Middle Information ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tag pill & rating row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: styleData.tagBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          styleData.tagText,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: styleData.tagTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.star_rounded,
                        color: starAmber,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        styleData.rating,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: starText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

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
            "ลองเปลี่ยนคำค้นหา หรือเลือกหมวดหมู่อื่น",
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

  /// Helper to return vibrant theme emblem, slug, tag, rating based on park info
  _ParkStyleData _getParkStyleData(Park park) {
    final name = park.name;

    if (name.contains("เขาใหญ่")) {
      return _ParkStyleData(
        gradientColors: const [Color(0xFF006D43), Color(0xFF00A86B)],
        icon: Icons.park_rounded,
        slug: "KHAO YAI",
        tagText: "มรดกโลก",
        tagBgColor: mintLight,
        tagTextColor: primaryGreen,
        rating: "4.9",
      );
    } else if (name.contains("แก่งกระจาน")) {
      return _ParkStyleData(
        gradientColors: const [Color(0xFF00796B), Color(0xFF009688)],
        icon: Icons.terrain_rounded,
        slug: "KRACHAN",
        tagText: "ป่าดิบชื้น",
        tagBgColor: const Color(0xFFE0F2F1),
        tagTextColor: const Color(0xFF00695C),
        rating: "4.8",
      );
    } else if (name.contains("เอราวัณ")) {
      return _ParkStyleData(
        gradientColors: const [Color(0xFF0284C7), Color(0xFF2563EB)],
        icon: Icons.waves_rounded,
        slug: "ERAWAN",
        tagText: "น้ำตก 7 ชั้น",
        tagBgColor: const Color(0xFFE0F2FE),
        tagTextColor: const Color(0xFF0369A1),
        rating: "4.7",
      );
    } else if (name.contains("ดอยสุเทพ") || name.contains("สุเทพ")) {
      return _ParkStyleData(
        gradientColors: const [Color(0xFFEA580C), Color(0xFFD97706)],
        icon: Icons.landscape_rounded,
        slug: "DOI SUTHEP",
        tagText: "ดอย & วัฒนธรรม",
        tagBgColor: const Color(0xFFFEF3C7),
        tagTextColor: const Color(0xFFB45309),
        rating: "4.8",
      );
    } else if (name.contains("อินทนนท์")) {
      return _ParkStyleData(
        gradientColors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        icon: Icons.filter_hdr_rounded,
        slug: "INTHANON",
        tagText: "จุดสูงสุดแดนสยาม",
        tagBgColor: const Color(0xFFEDE9FE),
        tagTextColor: const Color(0xFF6D28D9),
        rating: "4.9",
      );
    }

    // Dynamic fallback based on park ID
    final paletteIndex = (park.id.abs()) % 5;
    switch (paletteIndex) {
      case 0:
        return _ParkStyleData(
          gradientColors: const [Color(0xFF006D43), Color(0xFF00A86B)],
          icon: Icons.park_rounded,
          slug: _slugify(park.name),
          tagText: park.status ?? "อุทยานธรรมชาติ",
          tagBgColor: mintLight,
          tagTextColor: primaryGreen,
          rating: "4.8",
        );
      case 1:
        return _ParkStyleData(
          gradientColors: const [Color(0xFF00796B), Color(0xFF009688)],
          icon: Icons.terrain_rounded,
          slug: _slugify(park.name),
          tagText: "ทัศนียภาพ",
          tagBgColor: const Color(0xFFE0F2F1),
          tagTextColor: const Color(0xFF00695C),
          rating: "4.7",
        );
      case 2:
        return _ParkStyleData(
          gradientColors: const [Color(0xFF0284C7), Color(0xFF2563EB)],
          icon: Icons.water_drop_rounded,
          slug: _slugify(park.name),
          tagText: "ธรรมชาติสมบูรณ์",
          tagBgColor: const Color(0xFFE0F2FE),
          tagTextColor: const Color(0xFF0369A1),
          rating: "4.8",
        );
      case 3:
        return _ParkStyleData(
          gradientColors: const [Color(0xFFEA580C), Color(0xFFD97706)],
          icon: Icons.landscape_rounded,
          slug: _slugify(park.name),
          tagText: "จุดชมวิว",
          tagBgColor: const Color(0xFFFEF3C7),
          tagTextColor: const Color(0xFFB45309),
          rating: "4.7",
        );
      default:
        return _ParkStyleData(
          gradientColors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
          icon: Icons.filter_hdr_rounded,
          slug: _slugify(park.name),
          tagText: "ไฮไลท์ยอดนิยม",
          tagBgColor: const Color(0xFFEDE9FE),
          tagTextColor: const Color(0xFF6D28D9),
          rating: "4.9",
        );
    }
  }

  String _slugify(String name) {
    final cleaned = name.replaceAll("อุทยานแห่งชาติ", "").trim();
    if (cleaned.isEmpty) return "PARK";
    return cleaned.toUpperCase();
  }
}

class _ParkStyleData {
  final List<Color> gradientColors;
  final IconData icon;
  final String slug;
  final String tagText;
  final Color tagBgColor;
  final Color tagTextColor;
  final String rating;

  _ParkStyleData({
    required this.gradientColors,
    required this.icon,
    required this.slug,
    required this.tagText,
    required this.tagBgColor,
    required this.tagTextColor,
    required this.rating,
  });
}
