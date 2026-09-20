import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/stamp/dtos/qr_response.dart';
import 'package:greenpass/features/stamp/services/stamp_service.dart';

class StampQrView extends StatefulWidget {
  const StampQrView({super.key});

  @override
  State<StampQrView> createState() => _StampQrViewState();
}

class _StampQrViewState extends State<StampQrView> {
  final StampService _stampService = StampService();
  bool _isLoading = true;
  String? _error;

  QrResponse? _qrResponse;
  Timer? _timer;
  int _secondsLeft = 0;

  // ── Vibrant Wilderness Theme Palette (ตามแบบ DESIGN.md / screen.png) ───────────
  static const Color screenBg = Color(0xFFF3F7F5);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color midForest = Color(0xFF0F5A3E);
  static const Color warmEarth = Color(0xFF78350F);

  static const Color mintLight = Color(0xFFE2F7ED);
  static const Color mintAction = Color(0xFFE8F7F0);
  static const Color iconGreen = Color(0xFF059669);

  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color amberDark = Color(0xFF92400E);

  static const Color textPrimary = Color(0xFF0F2E23);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _loadQr();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQr() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _timer?.cancel();

    try {
      final qrResponse = await _stampService.getQr();
      if (!mounted) return;

      final secondsLeft = qrResponse.expiresInSeconds > 0
          ? qrResponse.expiresInSeconds
          : 300;

      setState(() {
        _qrResponse = qrResponse;
        _secondsLeft = secondsLeft;
        _isLoading = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsLeft <= 1) {
          setState(() {
            _secondsLeft = 0;
          });
          timer.cancel();
          return;
        }

        setState(() {
          _secondsLeft--;
        });
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "ไม่สามารถโหลด QR Code ได้";
        _isLoading = false;
      });
    }
  }

  bool get _isExpired => _secondsLeft <= 0;

  Color get _timerColor => _isExpired
      ? Colors.red
      : _secondsLeft > 120
      ? amberDark
      : _secondsLeft > 60
      ? Colors.orange
      : Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: mintAction,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF134E39),
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        title: const Text(
          "รับแสตมป์",
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ── ลายตกแต่งพื้นหลัง ให้เข้าธีมเดียวกับหน้าอื่น
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mintLight.withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconGreen.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 10,
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 50,
              color: iconGreen.withValues(alpha: 0.06),
            ),
          ),

          Center(
            child: _isLoading
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(iconGreen),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "กำลังสร้าง QR Code...",
                        style: TextStyle(color: Colors.black45, fontSize: 13),
                      ),
                    ],
                  )
                : _error != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton.icon(
                              onPressed: _loadQr,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text("ลองใหม่"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: iconGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // แถบหัวการ์ด gradient เล็กๆ ให้เข้าธีม
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [darkForest, midForest, warmEarth],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.qr_code_2_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "OFFICIAL PASSPORT STAMP",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: screenBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Opacity(
                                  opacity: _isExpired ? 0.35 : 1.0,
                                  child: Image.memory(
                                    base64Decode(_qrResponse!.qrBase64),
                                    width: 220,
                                    height: 220,
                                    gaplessPlayback: true,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              Text(
                                "${Session.currentUser?.firstname ?? ''} ${Session.currentUser?.lastname ?? ''}"
                                    .trim(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _isExpired
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : amberLight,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: _isExpired
                                        ? Colors.red.withValues(alpha: 0.25)
                                        : const Color(0xFFFDE68A),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.access_time_filled_rounded,
                                      color: _timerColor,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isExpired
                                          ? "หมดอายุแล้ว"
                                          : "หมดอายุใน ${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: _timerColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isExpired) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _loadQr,
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text("สร้าง QR ใหม่"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: iconGreen,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: iconGreen,
                              ),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "แสดง QR Code นี้ให้เจ้าหน้าที่สแกน",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
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
    );
  }
}
