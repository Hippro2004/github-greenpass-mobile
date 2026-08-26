import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/announcement/dtos/announcement_response.dart';
import 'package:greenpass/features/announcement/services/announcement_service.dart';
import 'package:greenpass/features/announcement/views/announcement_detail_view.dart';
import 'package:greenpass/features/views/more_view.dart';
import 'package:greenpass/features/announcement/views/announcement_view.dart';
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
  final AnnoucementService _announcementService = AnnoucementService();
  final PageController _announcementController = PageController();
  Timer? _announcementTimer;
  List<AnnouncementResponse> _announcements = [];
  bool _announcementLoading = true;
  String? _announcementError;
  bool _locationLoading = true;
  String? _locationError;
  int _announcementIndex = 0;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnnouncements();
      _loadCurrentLocation();
    });
  }

  @override
  void dispose() {
    locationGPSController.dispose();
    _announcementTimer?.cancel();
    _announcementController.dispose();
    super.dispose();
  }

  Future<void> _loadAnnouncements() async {
    if (!mounted) return;
    setState(() {
      _announcementLoading = true;
      _announcementError = null;
    });
    try {
      final response = await _announcementService.getAllAnnouncements();
      if (!mounted) return;
      final announcements = List<AnnouncementResponse>.from(
        response.result ?? const <AnnouncementResponse>[],
      );
      announcements.sort((first, second) {
        final firstDate = DateTime.tryParse(first.postDate);
        final secondDate = DateTime.tryParse(second.postDate);
        if (firstDate != null && secondDate != null) {
          return secondDate.compareTo(firstDate);
        }
        return second.postDate.compareTo(first.postDate);
      });
      setState(() {
        _announcements = announcements.take(4).toList();
        _announcementLoading = false;
      });
      _startAnnouncementRotation();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _announcements = [];
        _announcementLoading = false;
        _announcementError = error.toString();
      });
    }
  }

  Future<void> _loadCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _locationLoading = true;
      _locationError = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationServiceDisabledException();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const PermissionDeniedException("ไม่ได้รับอนุญาตให้ใช้ตำแหน่ง");
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      String address = "";
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        final place = placemarks.isNotEmpty ? placemarks.first : null;
        final district = place?.subAdministrativeArea ?? place?.locality;
        final subdistrict = place?.subLocality;
        final province = place?.administrativeArea;
        address = [
          if (district != null && district.trim().isNotEmpty)
            "อำเภอ/เขต $district",
          if (subdistrict != null && subdistrict.trim().isNotEmpty)
            "ตำบล $subdistrict",
          if (province != null && province.trim().isNotEmpty)
            "จังหวัด $province",
        ].join(", ");

        if (address.isEmpty && place != null) {
          address = [
            place.name,
            place.locality,
            place.administrativeArea,
            place.postalCode,
          ].where((part) => part != null && part.trim().isNotEmpty).join(", ");
        }
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        locationGPSController.text = address.isEmpty
            ? "ตำแหน่งปัจจุบัน (${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)})"
            : address;
        _locationLoading = false;
      });
    } on LocationServiceDisabledException {
      _setLocationError("กรุณาเปิด GPS แล้วลองใหม่");
    } on PermissionDeniedException catch (error) {
      _setLocationError(error.message ?? "ไม่ได้รับอนุญาตให้ใช้ตำแหน่ง");
    } catch (_) {
      _setLocationError("ไม่สามารถอ่านตำแหน่งปัจจุบันได้");
    }
  }

  void _setLocationError(String message) {
    if (!mounted) return;
    setState(() {
      locationGPSController.text = message;
      _locationError = message;
      _locationLoading = false;
    });
  }

  void _startAnnouncementRotation() {
    _announcementTimer?.cancel();
    if (_announcements.length < 2) return;
    _announcementTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_announcementController.hasClients) return;
      _announcementIndex = (_announcementIndex + 1) % _announcements.length;
      _announcementController.animateToPage(
        _announcementIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
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
                        onTap: _loadCurrentLocation,
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
                          suffixIcon: _locationLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        forestGreen,
                                      ),
                                    ),
                                  ),
                                )
                              : IconButton(
                                  tooltip: "อัปเดตตำแหน่ง",
                                  onPressed: _loadCurrentLocation,
                                  icon: Icon(
                                    _locationError == null
                                        ? Icons.my_location_outlined
                                        : Icons.refresh,
                                    color: forestGreen,
                                  ),
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

                      _buildAnnouncementCarousel(),
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

  Widget _buildAnnouncementCarousel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
      child: _announcementLoading
          ? Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(forestGreen),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "กำลังโหลดข่าวสาร...",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            )
          : _announcementError != null
          ? InkWell(
              onTap: _loadAnnouncements,
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 18, color: softBrown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "โหลดข่าวสารไม่สำเร็จ แตะเพื่อลองใหม่",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : _announcements.isEmpty
          ? Row(
              children: [
                Icon(Icons.campaign_outlined, size: 18, color: softBrown),
                const SizedBox(width: 8),
                Text(
                  "ยังไม่มีข่าวสาร",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.campaign_outlined, size: 16, color: softBrown),
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
                const SizedBox(height: 10),
                SizedBox(
                  height: 74,
                  child: PageView.builder(
                    controller: _announcementController,
                    itemCount: _announcements.length,
                    onPageChanged: (index) =>
                        setState(() => _announcementIndex = index),
                    itemBuilder: (context, index) {
                      final announcement = _announcements[index];
                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnnouncementDetailView(
                              announcementId: announcement.announcementId,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              announcement.parkName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: forestGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              announcement.announcementTitle.trim().isEmpty
                                  ? "ประกาศจากอุทยาน"
                                  : announcement.announcementTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (_announcements.length > 1) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _announcements.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == _announcementIndex ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _announcementIndex
                              ? forestGreen
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
