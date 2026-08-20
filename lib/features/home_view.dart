import 'package:flutter/material.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/views/more_view.dart';
import 'package:greenpass/features/views/announcement_view.dart';
import 'package:greenpass/features/views/park_search_view.dart';
import 'package:greenpass/features/views/report_view.dart';
import 'package:greenpass/features/views/show_qr_view.dart';
import 'package:greenpass/features/views/travel_book_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late final TextEditingController locationGPSController;
  int _currentIndex = 0;

  List<Widget> get _page => [_buildHomePage(), MoreView()];

  // ── ธีมสีเดียวกับหน้า Login ────────────────────────────
  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color softBrown = Color(0xFF8B6F47);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color midGreen = Color(0xFF40916C);
  static const Color cardGreen = Color(0xFFE8F5EE);

  @override
  void initState() {
    super.initState();
    locationGPSController = TextEditingController(text: "ที่อยู่ปัจจุบัน");
  }

  @override
  void dispose() {
    locationGPSController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: _page[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: forestGreen,
          unselectedItemColor: Colors.black38,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "หน้าแรก",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: "เพิ่มเติม",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Stack(
      children: [
        // ── ลายตกแต่งพื้นหลัง ให้เข้าธีมเดียวกับหน้า Login
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lightGreen.withOpacity(0.15),
            ),
          ),
        ),
        Positioned(
          top: 30,
          right: 10,
          child: Icon(
            Icons.forest,
            size: 90,
            color: Colors.white.withOpacity(0.07),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: forestGreen.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: 140,
          right: -30,
          child: Icon(
            Icons.eco,
            size: 60,
            color: forestGreen.withOpacity(0.06),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // ── การ์ด gradient ด้านบน (ต่างจาก Login ตรงที่เป็นการ์ดโค้งมนลอย ไม่ใช่พื้นหลังเต็มจอ)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [darkGreen, midGreen, forestGreen],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: forestGreen.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "สวัสดี,",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.75),
                            ),
                          ),
                          Text(
                            "คุณ ${Session.currentUser!.firstname}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.2,
                        ),
                      ),
                      child: IconButton(
                        tooltip: "ประกาศ",
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnnouncementView(),
                          ),
                        ),
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: locationGPSController,
                        readOnly: true,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.location_on_rounded,
                            color: forestGreen,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: cardGreen,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _buildMenuButton(
                            icon: Icons.search,
                            label: "ค้นหาอุทยาน",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ParkSearchView(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildMenuButton(
                            icon: Icons.menu_book_outlined,
                            label: "สมุดบันทึก\nการเดินทาง",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TravelBookView(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildWideButton(
                        icon: Icons.collections_bookmark_outlined,
                        label: "รับแสตมป์",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StampQrView(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          _buildMenuButton(
                            icon: Icons.flag_outlined,
                            label: "รายงาน",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ReportView(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildMenuButton(
                            icon: Icons.warning_amber_rounded,
                            label: "เหตุฉุกเฉิน",
                            onTap: () {},
                            isRed: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.campaign_outlined,
                                  size: 16,
                                  color: softBrown,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "ข่าวสาร",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (i) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: i == 0 ? 16 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: i == 0
                                        ? forestGreen
                                        : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isRed = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isRed ? const Color(0xFFE53935) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isRed ? null : Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: isRed
                    ? Colors.red.withOpacity(0.2)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isRed ? Colors.white : forestGreen, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isRed ? Colors.white : Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: forestGreen, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
