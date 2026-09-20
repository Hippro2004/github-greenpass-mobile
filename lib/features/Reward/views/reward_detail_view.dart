import 'package:flutter/material.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/features/reward/dtos/reward_response.dart';
import 'package:greenpass/features/park/views/park_search_view.dart';
import 'package:greenpass/features/stamp/views/travel_book_view.dart';

class RewardDetailView extends StatelessWidget {
  final RewardResponse reward;

  const RewardDetailView({super.key, required this.reward});

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color creamBg = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF2E3B57);
  static const Color goldAccent = Color(0xFFD4A373);
  static const Color warmGold = Color(0xFFB08D57);

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
    final imageUrl = _resolveImageUrl(reward.image);

    return Scaffold(
      backgroundColor: creamBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sliver App Bar with Image ─────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            elevation: 0,
            backgroundColor: forestGreen,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: textDark,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWidget(imageUrl),
                  // Gradient Shade
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  // Floating badge over image
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: goldAccent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            "GreenPass Reward",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Date Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: lightGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: forestGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "เปิดให้รับสิทธิ์",
                                    style: TextStyle(
                                      color: forestGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (reward.rewardAnnouncementDate.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 13,
                                    color: Colors.black45,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    reward.rewardAnnouncementDate,
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          reward.rewardTitle,
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: forestGreen,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "รายละเอียดของรางวัล",
                              style: TextStyle(
                                color: textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          reward.rewardDetails.isNotEmpty
                              ? reward.rewardDetails
                              : "ไม่มีรายละเอียดเพิ่มเติม",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Claim Instructions Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.checklist_rounded,
                              color: warmGold,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "เงื่อนไขและวิธีรับของรางวัล",
                              style: TextStyle(
                                color: textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildStepItem(
                          step: "1",
                          title: "สะสมแสตมป์ท่องเที่ยว",
                          desc:
                              "เดินทางท่องเที่ยวอุทยานแห่งชาติและสแกนรับแสตมป์บันทึกลงใน GreenPass",
                        ),
                        const SizedBox(height: 12),
                        _buildStepItem(
                          step: "2",
                          title: "ติดต่อศูนย์บริการนักท่องเที่ยว",
                          desc:
                              "แจ้งความประสงค์ขอรับของรางวัล ณ จุดบริการในอุทยานแห่งชาติที่ร่วมรายการ",
                        ),
                        const SizedBox(height: 12),
                        _buildStepItem(
                          step: "3",
                          title: "แสดงสมุดแสตมป์ดิจิทัล",
                          desc:
                              "เปิดหน้าสมุดบันทึกแสตมป์ในแอป GreenPass เพื่อยืนยันสิทธิ์กับเจ้าหน้าที่",
                        ),
                        const SizedBox(height: 12),
                        _buildStepItem(
                          step: "4",
                          title: "รับของรางวัลสุดพิเศษ",
                          desc:
                              "รับของที่ระลึกสุดเอ็กซ์คลูซีฟ พร้อมเก็บความประทับใจในการอนุรักษ์ธรรมชาติ",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // CTA Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TravelBookView(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "เปิดสมุดแสตมป์เพื่อดูสิทธิ์",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: forestGreen,
                        elevation: 3,
                        shadowColor: forestGreen.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ParkSearchView(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.park_outlined, color: forestGreen),
                      label: const Text(
                        "ค้นหาอุทยานแห่งชาติ",
                        style: TextStyle(
                          color: forestGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: forestGreen, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String url) {
    if (url.isEmpty) {
      return _buildFallbackBanner();
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildFallbackBanner(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: forestGreen.withValues(alpha: 0.1),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(forestGreen),
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D6A4F), Color(0xFF1B4332), Color(0xFF40916C)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reward.rewardTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String step,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: forestGreen.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            step,
            style: const TextStyle(
              color: forestGreen,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
