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

  // ── ธีมสีเดียวกับไอคอน รับแสตมป์ (0xFF8A5A3B) ───────────────
  static const Color primaryBrown = Color(0xFF8A5A3B);
  static const Color lightBrown = Color(0xFFD4A373);
  static const Color creamBg = Color(0xFFFAF7F2);
  static const Color softBrown = Color(0xFF8A5A3B);
  static const Color darkBrown = Color(0xFF5D3823);
  static const Color midBrown = Color(0xFFA56F4E);
  static const Color cardBrown = Color(0xFFF7EFE8);

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
      ? primaryBrown
      : _secondsLeft > 60
      ? Colors.orange
      : Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(Icons.arrow_back, color: primaryBrown, size: 18),
          ),
        ),
        title: const Text(
          "รับแสตมป์",
          style: TextStyle(
            color: primaryBrown,
            fontWeight: FontWeight.w600,
            fontSize: 17,
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
                color: lightBrown.withValues(alpha: 0.12),
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
                color: primaryBrown.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 10,
            child: Icon(
              Icons.bookmark_rounded,
              size: 50,
              color: primaryBrown.withValues(alpha: 0.06),
            ),
          ),

          Center(
            child: _isLoading
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(primaryBrown),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text(
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
                                backgroundColor: primaryBrown,
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
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
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
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [darkBrown, midBrown, primaryBrown],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.qr_code_2,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "GreenPass Stamp",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardBrown,
                                  borderRadius: BorderRadius.circular(18),
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
                              const SizedBox(height: 14),

                              Text(
                                "${Session.currentUser?.firstname ?? ''} ${Session.currentUser?.lastname ?? ''}"
                                    .trim(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _timerColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      color: _timerColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _isExpired
                                          ? "หมดอายุแล้ว"
                                          : "หมดอายุใน ${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _timerColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isExpired) ...[
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _loadQr,
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text("สร้าง QR ใหม่"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBrown,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
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
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 15,
                                color: softBrown,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "แสดง QR Code นี้ให้เจ้าหน้าที่สแกน",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.black54,
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
