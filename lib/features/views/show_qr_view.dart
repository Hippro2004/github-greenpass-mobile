import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/dtos/qr_response.dart';
import 'package:greenpass/features/views/stamp_service.dart';

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

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color creamBg = Color(0xFFF8F5F0);

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
          icon: const Icon(Icons.arrow_back, color: forestGreen),
        ),
        title: const Text(
          "รับแสตมป์",
          style: TextStyle(color: forestGreen, fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(forestGreen),
              )
            : _error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _loadQr();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: forestGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("ลองใหม่"),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.memory(
                            base64Decode(_qrResponse!.qrBase64),
                            width: 350,
                            height: 350,
                            gaplessPlayback: true,
                          ),

                          Text(
                            "${Session.currentUser!.firstname} ${Session.currentUser!.lastname}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: _secondsLeft > 120
                                    ? forestGreen
                                    : _secondsLeft > 60
                                    ? Colors.orange
                                    : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "หมดอายุใน ${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _secondsLeft > 120
                                      ? forestGreen
                                      : _secondsLeft > 60
                                      ? Colors.orange
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "แสดง QR Code นี้ให้เจ้าหน้าที่สแกน",
                      style: TextStyle(fontSize: 13, color: Colors.black45),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
