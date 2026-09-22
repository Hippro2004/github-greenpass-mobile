import 'dart:async';
// import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greenpass/core/network/image_helper.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/announcement/dtos/announcement_response.dart';
import 'package:greenpass/features/announcement/services/announcement_service.dart';
import 'package:greenpass/features/announcement/views/announcement_detail_view.dart';
import 'package:greenpass/features/user/views/more_view.dart';
import 'package:greenpass/features/announcement/views/announcement_view.dart';
// import 'package:greenpass/features/park/models/park.dart';
// import 'package:greenpass/features/park/services/park_service.dart';
import 'package:greenpass/features/park/views/park_search_view.dart';
import 'package:greenpass/features/report/views/report_view.dart';
import 'package:greenpass/features/stamp/views/show_qr_view.dart';
import 'package:greenpass/features/stamp/views/travel_book_view.dart';
import 'package:greenpass/features/notification/services/notification_service.dart';
import 'package:greenpass/features/notification/views/notification_view.dart';
import 'package:greenpass/features/notification/models/notification_model.dart';
import 'package:greenpass/features/notification/services/notification_websocket_service.dart';
import 'package:greenpass/features/notification/widgets/top_notification_banner.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late final TextEditingController locationGPSController;
  final AnnoucementService _announcementService = AnnoucementService();
  // final ParkService _parkService = ParkService();
  final PageController _announcementController = PageController();
  Timer? _announcementTimer;
  List<AnnouncementResponse> _announcements = [];
  bool _announcementLoading = true;
  String? _announcementError;
  bool _locationLoading = true;
  String? _locationError;
  int _announcementIndex = 0;
  int _currentIndex = 0;

  final NotificationService _notificationService = NotificationService();
  int _unreadNotificationCount = 0;

  List<Widget> get _page => [_buildHomePage(), const AnnouncementView()];

  // ── ธีมสีเดียวกับหน้า Login ────────────────────────────
  static const Color indigo = Color(0xFF53658F);
  static const Color softBlue = Color(0xFF7B9BC2);
  static const Color forestGreen = Color(0xFF5F927A);
  static const Color lightGreen = Color(0xFFC9E2D3);
  static const Color creamBg = Color(0xFFF5F7FB);
  static const Color softBrown = Color(0xFF8D806D);
  static const Color darkGreen = Color(0xFF2E3B57);
  static const Color midGreen = Color(0xFF7194B8);
  static const Color cardGreen = Color(0xFFE8F1EC);

  @override
  void initState() {
    super.initState();
    locationGPSController = TextEditingController(text: "ที่อยู่ปัจจุบัน");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnnouncements();
      _loadCurrentLocation();
      _loadUnreadNotifications();
      _initWebSocketNotifications();
    });
  }

  StreamSubscription<NotificationModel>? _notificationSub;

  void _initWebSocketNotifications() {
    final username = Session.currentUser?.username;
    if (username == null || username.isEmpty) return;

    _notificationSub?.cancel();
    NotificationWebSocketService.instance.connect(username: username);

    _notificationSub = NotificationWebSocketService.instance.notificationStream
        .listen((notification) {
          if (!mounted) return;
          setState(() {
            _unreadNotificationCount += 1;
          });
          _showRealtimeNotificationPopup(notification);
        });
  }

  void _showRealtimeNotificationPopup(NotificationModel notification) {
    if (!mounted) return;

    TopNotificationBanner.show(
      context: context,
      notification: notification,
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final notifications = await _notificationService.getMyNotifications();
      if (!mounted) return;
      setState(() {
        _unreadNotificationCount = notifications.where((n) => !n.isRead).length;
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    NotificationWebSocketService.instance.disconnect();
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
      final announcements = await _announcementService.getAllAnnouncements();
      if (!mounted) return;
      final sortedAnnouncements = List<AnnouncementResponse>.from(announcements)
        ..sort((first, second) {
          final firstDate = DateTime.tryParse(first.postDate);
          final secondDate = DateTime.tryParse(second.postDate);
          if (firstDate != null && secondDate != null) {
            return secondDate.compareTo(firstDate);
          }
          return second.postDate.compareTo(first.postDate);
        });
      setState(() {
        _announcements = sortedAnnouncements.take(4).toList();
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
            ? "ตำแหน่งปัจจุบัน"
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

  // ── ปิดส่วนค้นหาอุทยานใกล้ที่สุดไว้ชั่วคราว ──
  /*
  Future<Park?> _findNearestPark(double latitude, double longitude) async {
    try {
      final parks = await _parkService.searchParks('');
      if (parks.isEmpty) return null;

      Park? nearestPark;
      double? nearestDistance;

      for (final park in parks) {
        final coordinates = _parseCoordinates(park.location);
        if (coordinates == null) continue;

        final distanceKm = _distanceInKm(
          latitude,
          longitude,
          coordinates.$1,
          coordinates.$2,
        );

        if (nearestDistance == null || distanceKm < nearestDistance) {
          nearestDistance = distanceKm;
          nearestPark = park;
        }
      }

      return nearestPark;
    } catch (_) {
      return null;
    }
  }

  (double, double)? _parseCoordinates(String? rawLocation) {
    if (rawLocation == null || rawLocation.trim().isEmpty) return null;

    final cleaned = rawLocation.replaceAll(RegExp(r'[^0-9.,\-]'), ' ');
    final numbers = cleaned
        .split(RegExp(r'\s+'))
        .where((value) => value.isNotEmpty)
        .map((value) => value.replaceAll(',', '.'))
        .map(double.tryParse)
        .whereType<double>()
        .toList();

    if (numbers.length < 2) return null;

    final first = numbers[0];
    final second = numbers[1];

    final lat = first.abs() <= 90 ? first : second;
    final lng = first.abs() <= 90 ? second : first;
    return (lat, lng);
  }

  double _distanceInKm(double lat1, double lon1, double lat2, double lon2) {
    const radius = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.asin(math.sqrt(a));
    return radius * c;
  }

  double _toRadians(double value) => value * math.pi / 180;
  */

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

  Future<void> _refreshHome() async {
    await Future.wait([
      _loadAnnouncements(),
      _loadCurrentLocation(),
      _loadUnreadNotifications(),
    ]);
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
          selectedItemColor: indigo,
          unselectedItemColor: Colors.black38,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: "สำรวจ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign_rounded),
              label: "ดูข่าวสาร",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(decoration: BoxDecoration(color: creamBg)),
        ),
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
        SafeArea(
          child: RefreshIndicator(
            color: forestGreen,
            backgroundColor: Colors.white,
            onRefresh: _refreshHome,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 18),
                  // _buildHeroSection(),
                  // const SizedBox(height: 18),
                  _buildLocationPill(),
                  const SizedBox(height: 18),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _buildMenuButton(
                        icon: Icons.explore_rounded,
                        label: "ค้นหาอุทยาน",
                        accentColor: Colors.white,
                        tileColor: const Color(0xFF2D6A4F),
                        iconBgColor: Colors.white.withValues(alpha: 0.16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ParkSearchView(),
                          ),
                        ),
                      ),
                      _buildMenuButton(
                        icon: Icons.auto_stories_rounded,
                        label: "สมุดบันทึก",
                        accentColor: const Color.fromARGB(255, 255, 255, 255),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF064E3B),
                            Color(0xFF0F5A3E),
                            Color(0xFF78350F),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF064E3B,
                            ).withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        iconBgColor: Colors.white.withValues(alpha: 0.16),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TravelBookView(),
                          ),
                        ),
                      ),
                      _buildMenuButton(
                        icon: Icons.qr_code_2_rounded,
                        label: "รับแสตมป์",
                        accentColor: Colors.white,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFD97706,
                            ).withValues(alpha: 0.28),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        iconBgColor: Colors.white.withValues(alpha: 0.20),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StampQrView(),
                          ),
                        ),
                      ),
                      _buildMenuButton(
                        icon: Icons.warning_amber_rounded,
                        label: "รายงาน",
                        accentColor: const Color(0xFF2D6A4F),
                        tileColor: const Color(0xFFEAF3F5),
                        iconBgColor: const Color(0xFFEAF3F5),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ReportView()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildWideButton(
                    icon: Icons.warning_amber_rounded,
                    label: "เหตุฉุกเฉิน",
                    accentColor: Colors.white,
                    tileColor: const Color(0xFFD94C5F),
                    onTap: () {},
                  ),
                  const SizedBox(height: 22),
                  _buildSectionTitle(),
                  const SizedBox(height: 12),
                  _buildAnnouncementCarousel(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final userProfileImage = Session.currentUser?.profileImage;
    final userProfileImageUrl = resolveImageUrl(userProfileImage);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MoreView()),
                  );
                  if (mounted) setState(() {});
                },
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8F5E9),
                          border: Border.all(
                            color: forestGreen.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: forestGreen.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: userProfileImageUrl.isNotEmpty
                              ? Image.network(
                                  userProfileImageUrl,
                                  width: 46,
                                  height: 46,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: forestGreen,
                                          size: 26,
                                        ),
                                      ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: forestGreen,
                                    size: 26,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'สวัสดี,',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              'คุณ ${Session.currentUser?.firstname ?? ''}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildNotificationBell(),
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final refreshed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationView()),
          );
          if (refreshed == true || mounted) {
            _loadUnreadNotifications();
          }
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: darkGreen,
                size: 26,
              ),
              if (_unreadNotificationCount > 0)
                Positioned(
                  top: 14,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD94C5F),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        _unreadNotificationCount > 99
                            ? '99+'
                            : '$_unreadNotificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=900&q=80',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: forestGreen),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.18),
                      Colors.black.withOpacity(0.34),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'จุดหมายปลายทาง',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ค้นพบความงาม\nของธรรมชาติ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnnouncementView(),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.28),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'ดูประกาศ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 12,
                            ),
                          ],
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
    );
  }

  Widget _buildLocationPill() {
    return InkWell(
      onTap: _loadCurrentLocation,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 18,
                color: forestGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _locationLoading
                  ? const Text(
                      'กำลังหาตำแหน่งปัจจุบัน...',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    )
                  : Text(
                      locationGPSController.text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.refresh_rounded, size: 18, color: forestGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ข่าวสารล่าสุด',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnnouncementView()),
          ),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Text(
            'ดูทั้งหมด',
            style: TextStyle(
              color: forestGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
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
                        fontWeight: FontWeight.w500,
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
                                fontWeight: FontWeight.w500,
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
    Color? accentColor,
    Color? tileColor,
    Color? iconBgColor,
    Gradient? gradient,
    List<BoxShadow>? boxShadow,
  }) {
    final buttonColor = isRed
        ? const Color(0xFFB35D47)
        : (tileColor ?? Colors.white);
    final iconColor = accentColor ?? Colors.white;
    final iconBackground =
        iconBgColor ??
        (gradient != null
            ? Colors.white.withValues(alpha: 0.18)
            : (buttonColor == const Color(0xFFEAF3F5)
                  ? const Color(0xFFEAF3F5)
                  : Colors.white.withValues(alpha: 0.18)));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: gradient == null ? buttonColor : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow:
                boxShadow ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color:
                      buttonColor == const Color(0xFFEAF3F5) && gradient == null
                      ? const Color(0xFF2D6A4F)
                      : Colors.white,
                  height: 1.2,
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
    Color? accentColor,
    Color? tileColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD85863), Color(0xFFB72E4C)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB72E4C).withOpacity(0.25),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor ?? Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
