import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:greenpass/features/notification/models/notification_model.dart';
import 'package:greenpass/features/notification/services/notification_service.dart';
import 'package:greenpass/features/notification/services/notification_websocket_service.dart';
import 'package:greenpass/features/report/services/report_service.dart';
import 'package:greenpass/features/report/views/report_view_detail.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<NotificationModel>? _wsSub;
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedFilterIndex = 0; // 0: ยังไม่อ่าน, 1: ทั้งหมด

  // ── Vibrant Wilderness Palette ─────────────────────────────────
  static const Color screenBg = Color(0xFFF3F7F5);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color mintLight = Color(0xFFE8F7F0);
  static const Color mintBorder = Color(0xFFD6EFE2);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _wsSub = NotificationWebSocketService.instance.notificationStream.listen((
      n,
    ) {
      if (!mounted) return;
      setState(() {
        _notifications.insert(0, n);
      });
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _notificationService.getMyNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    // Optimistic UI update
    setState(() {
      final index = _notifications.indexWhere(
        (n) => n.notificationId == notification.notificationId,
      );
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });

    await _notificationService.markAsRead(notification.notificationId);
  }

  Future<void> _markAllAsRead() async {
    final unreadList = _notifications.where((n) => !n.isRead).toList();
    if (unreadList.isEmpty) return;

    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });

    final ids = unreadList.map((n) => n.notificationId);
    await _notificationService.markAllAsRead(ids);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ทำเครื่องหมายว่าอ่านแล้วทั้งหมด'),
          backgroundColor: darkForest,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onNotificationTap(NotificationModel item) async {
    await _markAsRead(item);

    if (!mounted) return;

    if (item.report != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportViewDetail(report: item.report!),
        ),
      );
    } else if (item.reportId != null) {
      try {
        final reports = await ReportService().getMyReport();
        final match =
            reports.where((r) => r.reportId == item.reportId).firstOrNull;
        if (match != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportViewDetail(report: match),
            ),
          );
        }
      } catch (_) {}
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'เมื่อสักครู่';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else {
      try {
        return DateFormat('d MMM yyyy HH:mm', 'th_TH').format(dateTime);
      } catch (_) {
        return DateFormat('d MMM yyyy HH:mm').format(dateTime);
      }
    }
  }

  List<NotificationModel> get _filteredNotifications {
    if (_selectedFilterIndex == 0) {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredNotifications;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context, true),
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
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'การแจ้งเตือน',
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
        centerTitle: true,
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: GestureDetector(
                  onTap: _markAllAsRead,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: mintLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: mintBorder),
                    ),
                    child: const Text(
                      'อ่านทั้งหมด',
                      style: TextStyle(
                        color: darkForest,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: RefreshIndicator(
              color: emeraldTint,
              onRefresh: _loadNotifications,
              child: _buildContent(displayList),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'ยังไม่อ่าน',
            icon: Icons.mark_chat_unread_rounded,
            count: _unreadCount,
            isSelected: _selectedFilterIndex == 0,
            onTap: () => setState(() => _selectedFilterIndex = 0),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'ทั้งหมด',
            icon: Icons.all_inbox_rounded,
            count: _notifications.length,
            isSelected: _selectedFilterIndex == 1,
            onTap: () => setState(() => _selectedFilterIndex = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? darkForest : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? darkForest : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: darkForest.withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : darkForest,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textDark,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.22)
                    : (count > 0 && label == 'ยังไม่อ่าน'
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (count > 0 && label == 'ยังไม่อ่าน'
                          ? const Color(0xFF065F46)
                          : textMuted),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<NotificationModel> list) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(emeraldTint),
          strokeWidth: 3,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('ลองใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkForest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (list.isEmpty) {
      final isUnreadTab = _selectedFilterIndex == 0;
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: mintLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnreadTab
                        ? Icons.mark_email_read_rounded
                        : Icons.notifications_none_rounded,
                    size: 42,
                    color: emeraldTint,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isUnreadTab
                      ? 'ไม่มีการแจ้งเตือนที่ยังไม่อ่าน'
                      : 'ไม่มีการแจ้งเตือน',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isUnreadTab
                      ? 'คุณอ่านการแจ้งเตือนทั้งหมดเรียบร้อยแล้ว'
                      : 'คุณจะได้รับการแจ้งเตือนเมื่อมีการอัปเดตสถานะรายงาน',
                  style: const TextStyle(fontSize: 13, color: textMuted),
                  textAlign: TextAlign.center,
                ),
                if (isUnreadTab && _notifications.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _selectedFilterIndex = 1;
                      });
                    },
                    icon: const Icon(Icons.all_inbox_rounded, size: 16),
                    label: Text(
                      'ดูการแจ้งเตือนทั้งหมด (${_notifications.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkForest,
                      side: const BorderSide(color: mintBorder, width: 1.5),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildNotificationCard(item);
      },
    );
  }

  String _formatNotificationTitle(String rawTitle, String? currentStatus) {
    return NotificationModel.resolveStatusTitle(
      currentStatus,
      defaultTitle: rawTitle,
    );
  }

  _NotificationStatusTheme _getStatusTheme(NotificationModel item) {
    String statusKey = '';
    if (item.currentStatus != null && item.currentStatus!.trim().isNotEmpty) {
      statusKey = item.currentStatus!.trim();
    } else if (item.report?.status != null &&
        item.report!.status.trim().isNotEmpty) {
      statusKey = item.report!.status.trim();
    } else {
      final t = item.title.trim().toLowerCase();
      if (t.contains('เสร็จสิ้น') ||
          t.contains('สำเร็จ') ||
          t.contains('completed')) {
        statusKey = 'COMPLETED';
      } else if (t.contains('ดำเนินการ') || t.contains('inprogress')) {
        statusKey = 'INPROGRESS';
      } else if (t.contains('รับทราบ') ||
          t.contains('รับเรื่อง') ||
          t.contains('acknowledge')) {
        statusKey = 'ACKNOWLEDGE';
      } else if (t.contains('ปฏิเสธ') ||
          t.contains('ไม่รับเรื่อง') ||
          t.contains('reject') ||
          t.contains('cancel')) {
        statusKey = 'REJECTED';
      } else {
        statusKey = 'PENDING';
      }
    }

    final key = statusKey
        .toUpperCase()
        .replaceAll('_', '')
        .replaceAll(' ', '')
        .replaceAll('-', '');

    switch (key) {
      case 'INPROGRESS':
      case 'กำลังดำเนินการ':
      case 'ดำเนินการ':
        return const _NotificationStatusTheme(
          primary: Color(0xFF2563EB), // Blue (น้ำเงิน)
          bgLight: Color(0xFFEFF6FF),
          borderColor: Color(0xFFBFDBFE),
          label: 'กำลังดำเนินการ',
          icon: Icons.engineering_rounded,
        );
      case 'ACKNOWLEDGE':
      case 'ACKNOWLEDGED':
      case 'รับทราบ':
      case 'รับทราบแล้ว':
      case 'รับเรื่องแล้ว':
        return const _NotificationStatusTheme(
          primary: Color(0xFF475569), // Dark Grey (เทาเข้ม - รับทราบ)
          bgLight: Color(0xFFF1F5F9),
          borderColor: Color(0xFFCBD5E1),
          label: 'รับทราบ',
          icon: Icons.assignment_turned_in_rounded,
        );
      case 'COMPLETED':
      case 'RESOLVED':
      case 'CLOSED':
      case 'DONE':
      case 'เสร็จสิ้น':
      case 'แก้ไขแล้ว':
      case 'สำเร็จ':
        return const _NotificationStatusTheme(
          primary: Color(0xFF059669), // Emerald Green (เขียว - สำเร็จ)
          bgLight: Color(0xFFF0FDF4),
          borderColor: Color(0xFFBBF7D0),
          label: 'เสร็จสิ้น',
          icon: Icons.check_circle_rounded,
        );
      case 'REJECTED':
      case 'CANCELLED':
      case 'CANCELED':
      case 'ไม่รับเรื่อง':
      case 'ปฏิเสธ':
        return const _NotificationStatusTheme(
          primary: Color(0xFFDC2626), // Red (แดง)
          bgLight: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFECACA),
          label: 'ไม่รับเรื่อง',
          icon: Icons.cancel_rounded,
        );
      case 'NEEDSINFO':
      case 'รอข้อมูลเพิ่มเติม':
        return const _NotificationStatusTheme(
          primary: Color(0xFFEA580C), // Orange (ส้ม)
          bgLight: Color(0xFFFFF7ED),
          borderColor: Color(0xFFFED7AA),
          label: 'รอข้อมูลเพิ่มเติม',
          icon: Icons.info_outline_rounded,
        );
      case 'PENDING':
      case 'รอตอบรับ':
      case 'รอการตอบรับ':
      default:
        return const _NotificationStatusTheme(
          primary: Color(0xFFD97706), // Amber (ส้มอมเหลือง)
          bgLight: Color(0xFFFFFBEB),
          borderColor: Color(0xFFFDE68A),
          label: 'รอตอบรับ',
          icon: Icons.access_time_rounded,
        );
    }
  }

  Widget _buildNotificationCard(NotificationModel item) {
    final isUnread = !item.isRead;
    final timeStr = _formatDateTime(item.createdAt);
    final parkName = item.report?.parkName ?? '';
    final statusTheme = _getStatusTheme(item);
    final displayTitle = _formatNotificationTitle(item.title, item.currentStatus);
    final typeName = item.reportType ?? item.report?.typeName ?? '';
    final isSevere = typeName.contains('ร้ายแรง') ||
        typeName.toLowerCase().contains('severe') ||
        typeName.toLowerCase().contains('critical');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNotificationTap(item),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          // boxShadow must live outside ClipRRect, otherwise it gets clipped
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isUnread
                    ? statusTheme.primary.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              // Border.all (uniform color) is safe with borderRadius
              decoration: BoxDecoration(
                color: isUnread ? statusTheme.bgLight : Colors.white,
                border: Border.all(
                  color: isUnread
                      ? statusTheme.borderColor
                      : const Color(0xFFEAF3EE),
                  width: 1.0,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left accent bar — colored by status!
                    Container(
                      width: isUnread ? 5.0 : 2.5,
                      color: isUnread
                          ? statusTheme.primary
                          : statusTheme.primary.withValues(alpha: 0.35),
                    ),
                    // Main content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Badge / Icon Container
                            if (parkName.trim().isNotEmpty)
                              _buildSubstringIconBadge(
                                parkName,
                                isUnread: isUnread,
                                statusColor: statusTheme.primary,
                              )
                            else
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isUnread
                                          ? statusTheme.primary.withValues(alpha: 0.12)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: isUnread
                                            ? statusTheme.primary.withValues(alpha: 0.35)
                                            : const Color(0xFFE2E8F0),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Icon(
                                      statusTheme.icon,
                                      color: isUnread
                                          ? statusTheme.primary
                                          : textMuted,
                                      size: 24,
                                    ),
                                  ),
                                  if (isUnread)
                                    Positioned(
                                      top: -3,
                                      right: -3,
                                      child: Container(
                                        width: 13,
                                        height: 13,
                                        decoration: BoxDecoration(
                                          color: statusTheme.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: statusTheme.primary
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                            const SizedBox(width: 12),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header: Title + Status Tag
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          displayTitle,
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: isUnread
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            color: isUnread
                                                ? textDark
                                                : const Color(0xFF475569),
                                          ),
                                        ),
                                      ),
                                      if (isSevere) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFFFECACA),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                size: 11,
                                                color: Color(0xFFDC2626),
                                              ),
                                              SizedBox(width: 2.5),
                                              Text(
                                                'ร้ายแรง',
                                                style: TextStyle(
                                                  color: Color(0xFFDC2626),
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(width: 8),
                                      if (isUnread)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusTheme.primary
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: statusTheme.primary
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: statusTheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                statusTheme.label,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: statusTheme.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.done_all_rounded,
                                                size: 13,
                                                color: Color(0xFF94A3B8),
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                statusTheme.label,
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),

                                  // Message text
                                  Text(
                                    item.message,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isUnread
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                      color: isUnread
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFF64748B),
                                      height: 1.45,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),

                                  // Bottom info (Timestamp + View progress)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 12,
                                            color: isUnread
                                                ? statusTheme.primary
                                                : textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeStr,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: isUnread
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: isUnread
                                                  ? statusTheme.primary
                                                  : textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (item.report != null ||
                                          item.reportId != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isUnread
                                                ? statusTheme.primary
                                                : statusTheme.primary
                                                    .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'ดูความคืบหน้า',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isUnread
                                                      ? Colors.white
                                                      : statusTheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              Icon(
                                                isUnread
                                                    ? Icons.arrow_forward_rounded
                                                    : Icons.chevron_right_rounded,
                                                size: 12,
                                                color: isUnread
                                                    ? Colors.white
                                                    : statusTheme.primary,
                                              ),
                                            ],
                                          ),
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ไอคอน Badge ตัดคำแบบ Vibrant Wilderness พร้อมสถานะอ่าน/ยังไม่อ่าน
  Widget _buildSubstringIconBadge(
    String rawParkName, {
    required bool isUnread,
    required Color statusColor,
  }) {
    String shortName = rawParkName.trim();
    if (shortName.startsWith("อุทยานแห่งชาติ")) {
      shortName = shortName.substring("อุทยานแห่งชาติ".length).trim();
    }
    if (shortName.isEmpty) {
      shortName = rawParkName;
    }

    final name = rawParkName;
    IconData icon;
    List<Color> gradientColors;

    if (name.contains("น้ำตก")) {
      icon = Icons.water_drop_rounded;
      gradientColors = const [Color(0xFF0284C7), Color(0xFF2563EB)];
    } else if (name.contains("เกาะ") ||
        name.contains("ทะเล") ||
        name.contains("หาด") ||
        name.contains("อ่าว") ||
        name.contains("ธารา") ||
        name.contains("หมู่เกาะ")) {
      icon = Icons.waves_rounded;
      gradientColors = const [Color(0xFF00796B), Color(0xFF009688)];
    } else if (name.contains("ดอย") ||
        name.contains("ภู") ||
        name.contains("ยอด")) {
      icon = Icons.filter_hdr_rounded;
      gradientColors = const [Color(0xFF7C3AED), Color(0xFF6D28D9)];
    } else if (name.contains("เขา") ||
        name.contains("ผา") ||
        name.contains("หิน") ||
        name.contains("ถ้ำ")) {
      icon = Icons.landscape_rounded;
      gradientColors = const [Color(0xFFEA580C), Color(0xFFD97706)];
    } else {
      icon = Icons.park_rounded;
      gradientColors = const [Color(0xFF006D43), Color(0xFF00A86B)];
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isUnread
                  ? gradientColors
                  : [
                      gradientColors[0].withValues(alpha: 0.72),
                      gradientColors[1].withValues(alpha: 0.72),
                    ],
            ),
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: gradientColors.first.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  shortName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7.5,
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
        ),
        if (isUnread)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationStatusTheme {
  final Color primary;
  final Color bgLight;
  final Color borderColor;
  final String label;
  final IconData icon;

  const _NotificationStatusTheme({
    required this.primary,
    required this.bgLight,
    required this.borderColor,
    required this.label,
    required this.icon,
  });
}
