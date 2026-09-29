import 'package:flutter/material.dart';
import 'package:greenpass/features/user/views/login_view.dart';
import 'package:greenpass/features/user/views/register_step_2_view.dart';

class RegisterStep1View extends StatefulWidget {
  const RegisterStep1View({super.key});

  @override
  State<RegisterStep1View> createState() => _RegisterStep1ViewState();
}

class _RegisterStep1ViewState extends State<RegisterStep1View> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isLoading = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  DateTime? _savedBirthDate;
  int? _savedGender;
  bool _savedIsForeigner = false;
  String _savedDistrict = '';
  String _savedSubDistrict = '';
  String _savedProvince = '';
  String _savedZipcode = '';

  late final TextEditingController _usernameController;
  late final TextEditingController _firstnameController;
  late final TextEditingController _lastnameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
    _usernameController = TextEditingController();
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (formkey.currentState!.validate()) {
      final data = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) => RegisterStep2View(
            username: _usernameController.text.trim(),
            firstname: _firstnameController.text.trim(),
            lastname: _lastnameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            savedBirthDate: _savedBirthDate,
            savedGender: _savedGender,
            savedIsForeigner: _savedIsForeigner,
            savedDistrict: _savedDistrict,
            savedSubDistrict: _savedSubDistrict,
            savedProvince: _savedProvince,
            savedZipcode: _savedZipcode,
          ),
        ),
      );
      if (data != null) {
        setState(() {
          _savedBirthDate = data['birthDate'];
          _savedGender = data['gender'];
          _savedIsForeigner = data['isForeigner'] ?? false;
          _savedDistrict = data['district'] ?? '';
          _savedSubDistrict = data['subDistrict'] ?? '';
          _savedProvince = data['province'] ?? '';
          _savedZipcode = data['zipcode'] ?? '';
        });
      }
    } else {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
    }
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
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginView()),
              ),
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
              "สมัครสมาชิก",
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
                  "1 / 2",
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title and progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "สร้างบัญชีใหม่",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "กรอกข้อมูลบัญชีเพื่อเริ่มต้นใช้งาน GreenPass",
                      style: TextStyle(fontSize: 13, color: textMuted),
                    ),
                    const SizedBox(height: 12),
                    // Progress Indicator
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 6,
                          decoration: BoxDecoration(
                            color: darkForest,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 10,
                          height: 6,
                          decoration: BoxDecoration(
                            color: mintBorder,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Form Card
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
                  autovalidateMode: _autovalidateMode,
                  child: Column(
                    children: [
                      // Username
                      _AuthInputField(
                        controller: _usernameController,
                        label: "ชื่อผู้ใช้งาน",
                        hint: "กรอกชื่อผู้ใช้งาน",
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "กรุณากรอกชื่อผู้ใช้งาน";
                          } else if (value.trim().contains(
                            RegExp(r'[^a-zA-Z0-9]'),
                          )) {
                            return "ชื่อผู้ใช้งานต้องเป็นตัวอักษรภาษาอังกฤษและตัวเลขเท่านั้น";
                          } else if (value.trim().length < 4 ||
                              value.trim().length > 50) {
                            return "ชื่อผู้ใช้งานต้องมีจำนวน 4-50 ตัวอักษร";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Firstname & Lastname
                      _AuthInputField(
                        controller: _firstnameController,
                        label: "ชื่อจริง",
                        hint: "ชื่อจริง",
                        icon: Icons.badge_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "กรุณากรอกชื่อ";
                          } else if (value.trim().length < 4 ||
                              value.trim().length > 50) {
                            return "ชื่อจริงต้องมีจำนวน 4 - 50 ตัวอักษร";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      _AuthInputField(
                        controller: _lastnameController,
                        label: "นามสกุล",
                        hint: "นามสกุล",
                        icon: Icons.badge_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "กรุณากรอกนามสกุล";
                          } else if (value.trim().length < 4 ||
                              value.trim().length > 50) {
                            return "นามสกุลต้องมีจำนวน 4 - 50 ตัวอักษร";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Email
                      _AuthInputField(
                        controller: _emailController,
                        label: "อีเมล",
                        hint: "example@email.com",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "กรุณากรอกอีเมล";
                          }
                          if (!RegExp(
                            r'^[\w.-]+@[\w.-]+\.\w+$',
                          ).hasMatch(value.trim())) {
                            return "รูปแบบอีเมลไม่ถูกต้อง";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Phone
                      _AuthInputField(
                        controller: _phoneController,
                        label: "หมายเลขโทรศัพท์",
                        hint: "08xxxxxxxx (10 หลัก)",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "กรุณากรอกหมายเลขโทรศัพท์";
                          } else if (value.trim().length != 10) {
                            return "กรุณากรอกหมายเลข 10 หลัก";
                          } else if (!RegExp(
                            r'^[0-9]+$',
                          ).hasMatch(value.trim())) {
                            return "กรุณากรอกเฉพาะตัวเลข";
                          } else if (!value.trim().startsWith('09') &&
                              !value.trim().startsWith('08') &&
                              !value.trim().startsWith('06')) {
                            return "กรุณากรอกหมายเลขขึ้นต้นด้วย 09, 08, หรือ 06";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password
                      _AuthInputField(
                        controller: _passwordController,
                        label: "รหัสผ่าน",
                        hint: "รหัสผ่านอย่างน้อย 4 ตัวอักษร",
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscurePassword,
                        onToggleObscure: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณากรอกรหัสผ่าน";
                          } else if (value.trim().length < 4 ||
                              value.trim().length > 50) {
                            return "รหัสผ่านต้องมีจำนวน 4 - 50 ตัวอักษร";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirm Password
                      _AuthInputField(
                        controller: _confirmPasswordController,
                        label: "ยืนยันรหัสผ่าน",
                        hint: "กรอกรหัสผ่านอีกครั้ง",
                        icon: Icons.lock_outline_rounded,
                        obscure: _obscureConfirmPassword,
                        onToggleObscure: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณากรอกยืนยันรหัสผ่าน";
                          }
                          if (value != _passwordController.text) {
                            return "รหัสผ่านทั้งสองช่องไม่ตรงกัน";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Next Button
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
                  onPressed: _handleNext,
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
                      Text(
                        "ถัดไป (ข้อมูลส่วนตัว)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Back to Login Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "มีบัญชีอยู่แล้ว? ",
                    style: TextStyle(color: textMuted, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginView()),
                    ),
                    child: const Text(
                      "เข้าสู่ระบบ",
                      style: TextStyle(
                        color: darkForest,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: darkForest,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AuthInputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
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
      obscureText: widget.obscure,
      keyboardType: widget.keyboardType,
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
        suffixIcon: widget.onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  widget.obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 19,
                ),
                onPressed: widget.onToggleObscure,
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
