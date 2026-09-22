import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenpass/features/notification/models/notification_model.dart';
import 'package:greenpass/features/report/views/report_view_detail.dart';
import 'package:greenpass/main.dart';

/// In-app heads-up notification banner floating at the top of the screen
/// ("ข้อความบนหัว") that automatically disappears after a few seconds,
/// with touch-to-view report and swipe-up to dismiss capabilities.
class TopNotificationBanner {
  static OverlayEntry? _currentEntry;
  static _TopNotificationBannerWidgetState? _currentState;

  static void show({
    BuildContext? context,
    required NotificationModel notification,
    Duration duration = const Duration(seconds: 4),
  }) {
    // If an existing banner is showing, dismiss it smoothly
    dismissImmediate();

    final targetContext = context ?? rootNavigatorKey.currentContext;
    if (targetContext == null) return;

    final overlay = Overlay.of(targetContext, rootOverlay: true);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _TopNotificationBannerWidget(
        key: UniqueKey(),
        notification: notification,
        duration: duration,
        onStateCreated: (state) => _currentState = state,
        onDismiss: () {
          _removeEntry(entry);
        },
        onTap: () {
          _removeEntry(entry);
          if (notification.report != null) {
            final navContext = rootNavigatorKey.currentContext ?? targetContext;
            Navigator.of(navContext, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => ReportViewDetail(report: notification.report!),
              ),
            );
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static void dismiss() {
    if (_currentState != null && _currentState!.mounted) {
      _currentState!.animateOut();
    } else {
      dismissImmediate();
    }
  }

  static void dismissImmediate() {
    if (_currentEntry != null) {
      try {
        _currentEntry?.remove();
      } catch (_) {}
      _currentEntry = null;
      _currentState = null;
    }
  }

  static void _removeEntry(OverlayEntry entry) {
    if (_currentEntry == entry) {
      _currentEntry = null;
      _currentState = null;
    }
    try {
      entry.remove();
    } catch (_) {}
  }
}

class _TopNotificationBannerWidget extends StatefulWidget {
  final NotificationModel notification;
  final Duration duration;
  final void Function(_TopNotificationBannerWidgetState) onStateCreated;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _TopNotificationBannerWidget({
    super.key,
    required this.notification,
    required this.duration,
    required this.onStateCreated,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_TopNotificationBannerWidget> createState() =>
      _TopNotificationBannerWidgetState();
}

class _TopNotificationBannerWidgetState
    extends State<_TopNotificationBannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    widget.onStateCreated(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();

    _autoDismissTimer = Timer(widget.duration, () {
      animateOut();
    });
  }

  void animateOut() {
    if (_isExiting || !mounted) return;
    _isExiting = true;
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  void _handleTap() {
    if (_isExiting || !mounted) return;
    _isExiting = true;
    _autoDismissTimer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onTap();
      }
    });
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReport = widget.notification.report != null ||
        widget.notification.reportId != null ||
        widget.notification.title.contains("รายงาน") ||
        widget.notification.message.contains("รายงาน") ||
        widget.notification.message.contains("ตอบกลับ") ||
        widget.notification.title.contains("ตอบกลับ");

    final isWarning = !isReport &&
        (widget.notification.title.contains("เตือน") ||
            widget.notification.message.contains("ซ้ำ") ||
            widget.notification.message.contains("ไม่สามารถ") ||
            widget.notification.message.contains("หมดอายุ"));

    Color borderColor;
    Color shadowColor;
    List<Color> badgeGradient;
    IconData badgeIcon;
    String tagLabel;
    Color tagBg;
    Color tagColor;

    if (isReport) {
      borderColor = const Color(0xFFA7F3D0); // mint border
      shadowColor = const Color(0xFF064E3B);
      badgeGradient = const [Color(0xFF064E3B), Color(0xFF047857)];
      badgeIcon = Icons.reply_rounded;
      tagLabel = "อุทยานตอบกลับรายงาน";
      tagBg = const Color(0xFFE8F7F0);
      tagColor = const Color(0xFF064E3B);
    } else if (isWarning) {
      borderColor = const Color(0xFFFED7AA);
      shadowColor = const Color(0xFFB45309);
      badgeGradient = const [Color(0xFFD97706), Color(0xFFF59E0B)];
      badgeIcon = Icons.warning_amber_rounded;
      tagLabel = "แจ้งเตือนการสแกน";
      tagBg = const Color(0xFFFEF3C7);
      tagColor = const Color(0xFFB45309);
    } else {
      borderColor = const Color(0xFFCBD5E1);
      shadowColor = const Color(0xFF065F46);
      badgeGradient = const [Color(0xFF15803D), Color(0xFF047857)];
      badgeIcon = Icons.notifications_active_rounded;
      tagLabel = "การแจ้งเตือน";
      tagBg = const Color(0xFFE8F5EE);
      tagColor = const Color(0xFF065F46);
    }

    final titleText = widget.notification.title.isNotEmpty
        ? widget.notification.title
        : (isReport
            ? "มีความคืบหน้าในรายงานปัญหา"
            : (isWarning ? "แจ้งเตือนการสแกน" : "การแจ้งเตือน"));

    final topPadding = MediaQuery.of(context).padding.top + 8;

    return Positioned(
      top: topPadding,
      left: 14,
      right: 14,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              if ((details.primaryDelta ?? 0) < -6) {
                animateOut();
              }
            },
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) < -60) {
                animateOut();
              }
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _handleTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge Icon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: badgeGradient,
                            ),
                            borderRadius: BorderRadius.circular(13),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    badgeGradient.first.withValues(alpha: 0.28),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(badgeIcon, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        // Text Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tagBg,
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Text(
                                      tagLabel,
                                      style: TextStyle(
                                        color: tagColor,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    "เมื่อสักครู่",
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                titleText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.notification.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  height: 1.35,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              if (isReport) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      "แตะเพื่อดูรายงาน",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: badgeGradient.first,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 14,
                                      color: badgeGradient.first,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Close button
                        GestureDetector(
                          onTap: animateOut,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Colors.grey.shade400,
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
        ),
      ),
    );
  }
}
