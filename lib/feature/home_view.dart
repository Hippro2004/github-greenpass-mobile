import 'package:flutter/material.dart';
import 'package:greenpass/core/session.dart';
import 'package:greenpass/feature/more_view.dart';
import 'package:greenpass/feature/park_search_view.dart';
import 'package:greenpass/feature/report_view.dart';
import 'package:greenpass/feature/show_qr_view.dart';
import 'package:greenpass/feature/travel_book_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late final TextEditingController locationGPSController;
  int _currentIndex = 0;

  List<Widget> get _page => [_buildHomePage(), MoreView()];

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color creamBg = Color(0xFFF8F5F0);
  // static const Color softBrown = Color(0xFF8B6F47);
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: forestGreen,
        unselectedItemColor: Colors.black38,
        backgroundColor: Colors.white,
        elevation: 8,
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
    );
  }

  Widget _buildHomePage() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lightGreen.withOpacity(0.2),
            ),
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
              color: forestGreen.withOpacity(0.08),
            ),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: forestGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "สวัสดี,",
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                        Text(
                          "คุณ ${Session.currentUser!.firstname}", // ← เปลี่ยนเป็น Session.currentUser?.firstname
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: forestGreen,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: locationGPSController,
                  readOnly: true,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                    MaterialPageRoute(builder: (_) => const StampQrView()),
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
                        MaterialPageRoute(builder: (_) => const ReportView()),
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

                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ข่าวสาร",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // dot indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            3,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
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
                ),
                const SizedBox(height: 8),
              ],
            ),
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
