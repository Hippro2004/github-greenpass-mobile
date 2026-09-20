import 'package:flutter/material.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/features/reward/dtos/reward_response.dart';
import 'package:greenpass/features/reward/services/reward_service.dart';
import 'package:greenpass/features/reward/views/reward_detail_view.dart';
import 'package:greenpass/features/stamp/services/stamp_service.dart';
import 'package:greenpass/features/stamp/views/travel_book_view.dart';

class RewardView extends StatefulWidget {
  const RewardView({super.key});

  @override
  State<RewardView> createState() => _RewardViewState();
}

class _RewardViewState extends State<RewardView> {
  final RewardService _rewardService = RewardService();
  final StampService _stampService = StampService();
  final TextEditingController _searchController = TextEditingController();

  List<RewardResponse> _allRewards = [];
  List<RewardResponse> _filteredRewards = [];
  int _userStampCount = 0;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: ทั้งหมด, 1: ล่าสุด

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color creamBg = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF2E3B57);
  static const Color goldAccent = Color(0xFFD4A373);

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
      _applyFilter();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rewardsFuture = _rewardService.getAllRewards();
      final stampsFuture = _stampService.getMyStamps();

      final results = await Future.wait<dynamic>([rewardsFuture, stampsFuture]);
      final rewards = results[0];
      final stamps = results[1];

      if (!mounted) return;

      setState(() {
        _allRewards = rewards;
        _userStampCount = stamps.length;
        _isLoading = false;
        _applyFilter();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "ไม่สามารถโหลดข้อมูลของรางวัลได้ กรุณาลองใหม่อีกครั้ง";
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    List<RewardResponse> list = List.from(_allRewards);

    if (_searchQuery.isNotEmpty) {
      list = list.where((r) {
        final title = r.rewardTitle.toLowerCase();
        final details = r.rewardDetails.toLowerCase();
        return title.contains(_searchQuery) || details.contains(_searchQuery);
      }).toList();
    }

    if (_selectedFilter == 1) {
      // Sort by newest announcement date
      list.sort(
        (a, b) => b.rewardAnnouncementDate.compareTo(a.rewardAnnouncementDate),
      );
    }

    _filteredRewards = list;
  }

  String _resolveImageUrl(String image) {
    if (image.isEmpty) return '';
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    final rawBase = DioClient.dio.options.baseUrl;
    final origin = rawBase.replaceAll('/api/v1', '');
    return '$origin/images/$image';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ของรางวัล",
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "สมุดแสตมป์",
            icon: const Icon(
              Icons.menu_book_rounded,
              color: forestGreen,
              size: 22,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TravelBookView()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: forestGreen,
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Stamp Progress Header Banner ───────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _buildPassportSummaryBanner(),
              ),
            ),

            // ── Search & Filter Row ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 12),
                    _buildFilterChips(),
                  ],
                ),
              ),
            ),

            // ── Main Content Area ──────────────────────────────
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: forestGreen),
                      SizedBox(height: 16),
                      Text(
                        "กำลังโหลดข้อมูลของรางวัล...",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(),
              )
            else if (_filteredRewards.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = _filteredRewards[index];
                    return _buildRewardCard(item);
                  }, childCount: _filteredRewards.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportSummaryBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: forestGreen.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(
              Icons.stars_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.card_giftcard_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "แลกรับของรางวัล GreenPass",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "สะสมแสตมป์ท่องเที่ยวเพื่อแลกของที่ระลึกสุดพิเศษ",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFFFFD166),
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "แสตมป์สะสม: $_userStampCount ดวง",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TravelBookView(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "สมุดแสตมป์",
                                style: TextStyle(
                                  color: forestGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: forestGreen,
                                size: 14,
                              ),
                            ],
                          ),
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "ค้นหาของรางวัล...",
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.black45,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: Colors.black45,
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ["ทั้งหมด (${_allRewards.length})", "ประกาศล่าสุด"];
    return Row(
      children: List.generate(filters.length, (index) {
        final isSelected = _selectedFilter == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(filters[index]),
            selected: isSelected,
            onSelected: (val) {
              if (val) {
                setState(() {
                  _selectedFilter = index;
                  _applyFilter();
                });
              }
            },
            selectedColor: forestGreen,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : textDark,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? forestGreen : Colors.grey.shade200,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRewardCard(RewardResponse item) {
    final imageUrl = _resolveImageUrl(item.image);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RewardDetailView(reward: item)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 95,
                    height: 95,
                    color: creamBg,
                    child: _buildThumbnail(imageUrl, item.rewardTitle),
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status / Category tag
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "ของรางวัลพิเศษ",
                              style: TextStyle(
                                color: forestGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (item.rewardAnnouncementDate.isNotEmpty)
                            Text(
                              item.rewardAnnouncementDate,
                              style: const TextStyle(
                                color: Colors.black38,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        item.rewardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Details preview
                      Text(
                        item.rewardDetails.isNotEmpty
                            ? item.rewardDetails
                            : "ดูรายละเอียดและวิธีรับของรางวัล",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Claim Info
                      const Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: forestGreen,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "รับได้ที่ศูนย์บริการนักท่องเที่ยว",
                            style: TextStyle(
                              color: forestGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String url, String title) {
    if (url.isEmpty) {
      return _buildFallbackThumbnail();
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildFallbackThumbnail(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: forestGreen,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackThumbnail() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.card_giftcard_rounded, color: forestGreen, size: 36),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: forestGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 56,
                color: forestGreen,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "ไม่พบรายการของรางวัล",
              style: TextStyle(
                color: textDark,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? "ไม่พบของรางวัลที่ตรงกับ \"$_searchQuery\""
                  : "ยังไม่มีรายการของรางวัลที่เปิดให้รับในขณะนี้",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.refresh_rounded, color: forestGreen),
                label: const Text(
                  "ล้างการค้นหา",
                  style: TextStyle(color: forestGreen),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _errorMessage ?? "เกิดข้อผิดพลาดในการโหลดข้อมูล",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textDark,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text(
                "ลองใหม่อีกครั้ง",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: forestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
