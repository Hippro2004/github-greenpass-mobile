import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:greenpass/features/notification/models/notification_model.dart';
import 'package:greenpass/features/notification/services/notification_service.dart';
import 'package:greenpass/features/notification/services/notification_websocket_service.dart';
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
  int _selectedFilterIndex = 0; // 0: ทั้งหมด, 1: ยังไม่อ่าน

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color creamBg = Color(0xFFF5F7FB);
  static const Color textDark = Color(0xFF2E3B57);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _wsSub = NotificationWebSocketService.instance.notificationStream.listen((n) {
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
      final response = await _notificationService.getMyNotifications();
      if (!mounted) return;

      if (response.success && response.result != null) {
        setState(() {
          _notifications = response.result!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message.isNotEmpty
              ? response.message
              : 'ไม่สามารถโหลดการแจ้งเตือนได้';
          _isLoading = false;
        });
      }
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

    for (final n in unreadList) {
      await _notificationService.markAsRead(n.notificationId);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ทำเครื่องหมายว่าอ่านแล้วทั้งหมด'),
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
    if (_selectedFilterIndex == 1) {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications;
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredNotifications;

    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'การแจ้งเตือน',
          style: TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'อ่านทั้งหมด',
                style: TextStyle(
                  color: forestGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
              color: forestGreen,
              onRefresh: _loadNotifications,
              child: _buildContent(displayList),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'ทั้งหมด',
            count: _notifications.length,
            isSelected: _selectedFilterIndex == 0,
            onTap: () => setState(() => _selectedFilterIndex = 0),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'ยังไม่อ่าน',
            count: _unreadCount,
            isSelected: _selectedFilterIndex == 1,
            onTap: () => setState(() => _selectedFilterIndex = 1),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? forestGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(List<NotificationModel> list) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: forestGreen),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('ลองใหม่'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: forestGreen,
                  foregroundColor: Colors.white,
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

    if (list.isEmpty) {
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
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ไม่มีการแจ้งเตือน',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedFilterIndex == 1
                      ? 'คุณอ่านการแจ้งเตือนทั้งหมดแล้ว'
                      : 'คุณจะได้รับการแจ้งเตือนเมื่อมีการอัปเดตสถานะรายงาน',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildNotificationCard(item);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel item) {
    final isUnread = !item.isRead;
    final timeStr = _formatDateTime(item.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onNotificationTap(item),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread ? forestGreen.withValues(alpha: 0.25) : Colors.grey.shade200,
              width: isUnread ? 1.2 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isUnread ? 0.05 : 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isUnread ? lightGreen : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.report != null ? Icons.assignment_outlined : Icons.notifications_active_outlined,
                  color: isUnread ? forestGreen : Colors.grey.shade600,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              color: isUnread ? textDark : Colors.black87,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: forestGreen,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isUnread ? Colors.black87 : Colors.grey.shade600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        if (item.report != null)
                          Row(
                            children: [
                              Text(
                                'ดูรายงาน',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: forestGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: forestGreen,
                              ),
                            ],
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
    );
  }
}
