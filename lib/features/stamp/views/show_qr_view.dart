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
  int _totalSeconds = 1;

  // ── ธีมสีเดียวกับหน้า Login / MainView ───────────────
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

      final expireAt = DateTime.fromMillisecondsSinceEpoch(
        qrResponse.result!.expireAt,
      );
      final secondsLeft = expireAt.difference(DateTime.now()).inSeconds;

      setState(() {
        _qrResponse = qrResponse.result;
        _secondsLeft = secondsLeft;
        _totalSeconds = secondsLeft > 0 ? secondsLeft : 1;
        _isLoading = false;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_secondsLeft > 0) {
            _secondsLeft--;
          } else {
            timer.cancel();
            _loadQr();
          }
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

  Color get _timerColor => _secondsLeft > 120
      ? forestGreen
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
            child: const Icon(Icons.arrow_back, color: forestGreen, size: 18),
          ),
        ),
        title: const Text(
          "รับแสตมป์",
          style: TextStyle(
            color: forestGreen,
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
                color: lightGreen.withOpacity(0.12),
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
                color: forestGreen.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 10,
            child: Icon(
              Icons.eco,
              size: 50,
              color: forestGreen.withOpacity(0.06),
            ),
          ),

          Center(
            child: _isLoading
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(forestGreen),
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
                            color: Colors.black.withOpacity(0.05),
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
                              color: Colors.red.withOpacity(0.08),
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
                                backgroundColor: forestGreen,
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
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
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
                                    colors: [darkGreen, midGreen, forestGreen],
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
                              const SizedBox(height: 16),

                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardGreen,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Image.memory(
                                  base64Decode(_qrResponse!.qrBase64),
                                  width: 260,
                                  height: 260,
                                  gaplessPlayback: true,
                                ),
                              ),
                              const SizedBox(height: 18),

                              Text(
                                "${Session.currentUser!.firstname} ${Session.currentUser!.lastname}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _timerColor.withOpacity(0.1),
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
                                      "หมดอายุใน ${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _timerColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

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
