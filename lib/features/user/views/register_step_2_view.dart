import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/core/services/translation_service.dart';
import 'package:greenpass/core/widgets/auto_translated_text.dart';
import 'package:greenpass/features/user/dtos/register_request.dart';
import 'package:greenpass/features/user/services/user_service.dart';
import 'package:greenpass/features/user/views/login_view.dart';
import 'package:intl/intl.dart';

class RegisterStep2View extends StatefulWidget {
  final String username, firstname, lastname, email, phone, password;
  final DateTime? savedBirthDate;
  final int? savedGender;
  final bool savedIsForeigner;
  final String savedDistrict, savedSubDistrict, savedProvince, savedZipcode;

  const RegisterStep2View({
    super.key,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.password,
    this.savedBirthDate,
    this.savedGender,
    this.savedIsForeigner = false,
    this.savedDistrict = '',
    this.savedSubDistrict = '',
    this.savedProvince = '',
    this.savedZipcode = '',
  });

  @override
  State<RegisterStep2View> createState() => _RegisterStep2ViewState();
}

class _RegisterStep2ViewState extends State<RegisterStep2View> {
  final UserSevice userservice = UserSevice();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  bool isLoading = false;
  int? gender;
  bool isForeigner = false;
  bool _genderHasError = false;

  final DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  late final TextEditingController birthDateController;
  late final TextEditingController districtController;
  late final TextEditingController subDistrictController;
  late final TextEditingController provinceController;
  late final TextEditingController zipcodeController;

  // ── Vibrant Wilderness Palette ─────────────────────────────────
  static const Color screenBg = Color(0xFFF3F7F5);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color midForest = Color(0xFF0F5A3E);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color mintLight = Color(0xFFE8F7F0);
  static const Color mintBorder = Color(0xFFD6EFE2);
  static const Color mintPillBg = Color(0xFFD1FAE5);
  static const Color mintDark = Color(0xFF065F46);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    birthDateController = TextEditingController();
    districtController = TextEditingController();
    subDistrictController = TextEditingController();
    provinceController = TextEditingController();
    zipcodeController = TextEditingController();

    if (widget.savedBirthDate != null) {
      birthDateController.text = dateFormat.format(widget.savedBirthDate!);
    }
    gender = widget.savedGender;
    isForeigner = widget.savedIsForeigner;
    districtController.text = widget.savedDistrict;
    subDistrictController.text = widget.savedSubDistrict;
    provinceController.text = widget.savedProvince;
    zipcodeController.text = widget.savedZipcode;
  }

  @override
  void dispose() {
    birthDateController.dispose();
    districtController.dispose();
    subDistrictController.dispose();
    provinceController.dispose();
    zipcodeController.dispose();
    super.dispose();
  }

  void _handlePop() {
    DateTime? parsedDate;
    if (birthDateController.text.isNotEmpty) {
      try {
        parsedDate = dateFormat.parse(birthDateController.text);
      } catch (_) {}
    }

    Navigator.of(context).pop({
      'birthDate': parsedDate,
      'gender': gender,
      'isForeigner': isForeigner,
      'district': isForeigner ? '' : districtController.text,
      'subDistrict': isForeigner ? '' : subDistrictController.text,
      'province': isForeigner ? '' : provinceController.text,
      'zipcode': isForeigner ? '' : zipcodeController.text,
    });
  }

  Future<void> _handleRegister() async {
    setState(() {
      _genderHasError = gender == null;
    });

    if (!formkey.currentState!.validate() || gender == null) {
      setState(() {
        autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    try {
      setState(() => isLoading = true);
      await userservice.register(
        RegisterRequest(
          username: widget.username,
          firstname: widget.firstname,
          lastname: widget.lastname,
          email: widget.email,
          phone: widget.phone,
          dateOfBirth: birthDateController.text,
          gender: gender!,
          isForeigner: isForeigner,
          distrcict: isForeigner ? '' : districtController.text.trim(),
          subDistrict: isForeigner ? '' : subDistrictController.text.trim(),
          province: isForeigner ? '' : provinceController.text.trim(),
          zipcode: isForeigner ? '' : zipcodeController.text.trim(),
          password: widget.password,
        ),
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: mintPillBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: mintBorder),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: darkForest,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "สมัครสมาชิกสำเร็จ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "ยินดีต้อนรับสู่ระบบ GreenPass\nสามารถเข้าสู่ระบบเพื่อเริ่มใช้งานได้ทันที",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: textMuted, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginView()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkForest,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "เข้าสู่ระบบ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final serverMsg =
          e.response?.data?["message"]?.toString() ??
          "เกิดข้อผิดพลาดในการสมัครสมาชิก กรุณาลองใหม่อีกครั้ง";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(serverMsg)),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("เกิดข้อผิดพลาด: $e"),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildGenderCard({
    required int value,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = gender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          gender = value;
          _genderHasError = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? mintLight.withValues(alpha: 0.6)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? darkForest : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? textDark : textMuted,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle_rounded,
                color: darkForest,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: _handlePop,
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
              "ข้อมูลส่วนตัว",
              style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
          const LanguageSwitchButton(),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: mintPillBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "2 / 2",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: mintDark,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Title & Progress Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ข้อมูลส่วนตัวและที่อยู่",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "ระบุข้อมูลเพิ่มเติมสำหรับการสะสมตราประทับและบริการ",
                          style: TextStyle(fontSize: 13, color: textMuted),
                        ),
                        const SizedBox(height: 12),
                        // Progress Indicator
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 6,
                              decoration: BoxDecoration(
                                color: emeraldTint,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 44,
                              height: 6,
                              decoration: BoxDecoration(
                                color: darkForest,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Form Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: mintBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: formkey,
                      autovalidateMode: autovalidateMode,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Birth Date
                          _AuthInputField(
                            controller: birthDateController,
                            label: "วันเกิด (พ.ศ./ค.ศ.)",
                            hint: "เลือกวันเกิดของคุณ",
                            icon: Icons.calendar_today_outlined,
                            onTap: () async {
                              final initialDate =
                                  DateTime.tryParse(birthDateController.text) ??
                                  DateTime(2000, 1, 1);
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: initialDate,
                                firstDate: DateTime(1920),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: darkForest,
                                        onPrimary: Colors.white,
                                        onSurface: textDark,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  birthDateController.text = dateFormat.format(
                                    picked,
                                  );
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "กรุณาเลือกวันเกิด";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          // Gender Selection
                          const Text(
                            "เพศ",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGenderCard(
                                  value: 0,
                                  label: "ชาย",
                                  icon: Icons.male_rounded,
                                  activeColor: const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGenderCard(
                                  value: 1,
                                  label: "หญิง",
                                  icon: Icons.female_rounded,
                                  activeColor: const Color(0xFFEC4899),
                                ),
                              ),
                            ],
                          ),
                          if (_genderHasError)
                            const Padding(
                              padding: EdgeInsets.only(left: 4, top: 6),
                              child: Text(
                                "กรุณาเลือกเพศ",
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Foreigner Checkbox
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isForeigner = !isForeigner;
                                TranslationService.instance.switchLanguage(
                                  isForeigner ? 'en' : 'th',
                                );
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isForeigner
                                    ? mintLight.withValues(alpha: 0.5)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isForeigner
                                      ? darkForest
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.public_rounded,
                                    color: isForeigner
                                        ? darkForest
                                        : Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      "ชาวต่างชาติ (Foreigner)",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: textDark,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: isForeigner,
                                      onChanged: (v) {
                                        final val = v ?? false;
                                        setState(() {
                                          isForeigner = val;
                                          TranslationService.instance
                                              .switchLanguage(
                                                val ? 'en' : 'th',
                                              );
                                        });
                                      },
                                      activeColor: darkForest,
                                      checkColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Address Group Title & Fields (เฉพาะกรณีไม่ใช่ชาวต่างชาติ เหมือนหน้า Edit Profile)
                          if (!isForeigner) ...[
                            const SizedBox(height: 22),
                            const Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: darkForest,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "ข้อมูลที่อยู่",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            _AuthInputField(
                              controller: districtController,
                              label: "อำเภอ/เขต",
                              hint: "อำเภอ/เขต",
                              icon: Icons.domain_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "กรุณาระบุอำเภอ";
                                } else if (value.trim().length < 4 ||
                                    value.trim().length > 20) {
                                  return "อำเภอต้องมีจำนวน 4 - 20 ตัวอักษร";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            _AuthInputField(
                              controller: subDistrictController,
                              label: "ตำบล/แขวง",
                              hint: "ตำบล/แขวง",
                              icon: Icons.home_work_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "กรุณาระบุตำบล";
                                } else if (value.trim().length < 4 ||
                                    value.trim().length > 20) {
                                  return "ตำบลต้องมีจำนวน 4 - 20 ตัวอักษร";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Province
                            _AuthInputField(
                              controller: provinceController,
                              label: "จังหวัด",
                              hint: "ระบุจังหวัดที่อยู่",
                              icon: Icons.map_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "กรุณาระบุจังหวัด";
                                } else if (value.trim().length < 4 ||
                                    value.trim().length > 20) {
                                  return "จังหวัดต้องมีจำนวน 4 - 20 ตัวอักษร";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Zipcode
                            _AuthInputField(
                              controller: zipcodeController,
                              label: "รหัสไปรษณีย์",
                              hint: "รหัสไปรษณีย์ 5 หลัก",
                              icon: Icons.local_post_office_outlined,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "กรุณากรอกรหัสไปรษณีย์";
                                }
                                if (value.trim().length != 5) {
                                  return "รหัสไปรษณีย์ต้องมี 5 หลัก";
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [darkForest, midForest],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: darkForest.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "ยืนยันการสมัครสมาชิก",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: mintBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(emeraldTint),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "กำลังบันทึกข้อมูลการสมัครสมาชิก...",
                        style: TextStyle(
                          color: textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Standardized Modern Auth Input Field ───────────────────────────
class _AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final Future<void> Function()? onTap;
  final String? Function(String?)? validator;

  const _AuthInputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.onTap,
    this.validator,
  });

  @override
  State<_AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<_AuthInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  static const Color darkForest = Color(0xFF064E3B);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color textDark = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      readOnly: widget.onTap != null,
      onTap: widget.onTap,
      validator: widget.validator,
      style: const TextStyle(
        fontSize: 14,
        color: textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: _isFocused ? darkForest : const Color(0xFF64748B),
          fontSize: 13,
          fontWeight: _isFocused ? FontWeight.w600 : FontWeight.normal,
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(
          widget.icon,
          color: _isFocused ? darkForest : Colors.grey.shade400,
          size: 19,
        ),
        suffixIcon: widget.onTap != null
            ? Icon(
                Icons.calendar_month_rounded,
                color: Colors.grey.shade400,
                size: 19,
              )
            : null,
        filled: true,
        fillColor: _isFocused
            ? const Color(0xFFE8F7F0).withValues(alpha: 0.35)
            : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: emeraldTint, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
