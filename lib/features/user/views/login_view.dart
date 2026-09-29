import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/core/network/image_helper.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/home_view.dart';
import 'package:greenpass/features/user/dtos/login_request.dart';
import 'package:greenpass/features/user/services/user_service.dart';
import 'package:greenpass/features/user/views/register_step_1_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final UserSevice userSevice = UserSevice();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool isLoading = false;
  bool _rememberMe = false;

  late final TextEditingController usernameController;
  late final TextEditingController passwordController;

  // ── Vibrant Wilderness Palette ─────────────────────────────────
  static const Color screenBg = Color(0xFFF3F7F5);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color midForest = Color(0xFF0F5A3E);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color mintBorder = Color(0xFFD6EFE2);
  static const Color mintPillBg = Color(0xFFD1FAE5);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      setState(() => isLoading = true);
      final user = await userSevice.login(
        LoginRequest(
          username: usernameController.text.trim(),
          password: passwordController.text,
        ),
      );
      Session.currentUser = user;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("เข้าสู่ระบบสำเร็จ ยินดีต้อนรับ"),
            ],
          ),
          backgroundColor: darkForest,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainView()),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final statusCode = e.response?.statusCode;
      String message;
      if (statusCode == 401) {
        message = "รหัสผ่านไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง";
      } else if (statusCode == 404) {
        message = "ไม่พบชื่อผู้ใช้งานนี้ในระบบ";
      } else {
        message = "เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      body: Stack(
        children: [
          // ── Background Ambient Elements ──────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: emeraldTint.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mintPillBg.withValues(alpha: 0.5),
              ),
            ),
          ),

          // ── Main Content ──────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Logo & Title Hero
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: mintBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: emeraldTint.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            resolveImageUrl('/logo/logo.png'),
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) => Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [darkForest, midForest],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.forest_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "GreenPass",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: emeraldTint,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "สมุดเดินทางและบริการอุทยานแห่งชาติ",
                      style: TextStyle(
                        fontSize: 13,
                        color: textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Login Card Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: mintBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "เข้าสู่ระบบ",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "กรอกข้อมูลบัญชีเพื่อเข้าสู่ระบบ GreenPass",
                              style: TextStyle(
                                fontSize: 13,
                                color: textMuted,
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Username
                            _AuthInputField(
                              controller: usernameController,
                              label: "ชื่อผู้ใช้งาน",
                              hint: "กรอกชื่อผู้ใช้งาน",
                              icon: Icons.person_outline_rounded,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? "กรุณากรอกชื่อผู้ใช้งาน"
                                  : null,
                            ),
                            const SizedBox(height: 14),

                            // Password
                            _AuthInputField(
                              controller: passwordController,
                              label: "รหัสผ่าน",
                              hint: "กรอกรหัสผ่านของคุณ",
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? "กรุณากรอกรหัสผ่าน"
                                  : null,
                            ),
                            const SizedBox(height: 12),

                            // Remember Me & Forgot Password
                            Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) =>
                                        setState(() => _rememberMe = v ?? false),
                                    activeColor: darkForest,
                                    checkColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _rememberMe = !_rememberMe,
                                  ),
                                  child: const Text(
                                    "จดจำฉันไว้",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textDark,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "กรุณาติดต่อเจ้าหน้าที่เพื่อรีเซ็ตรหัสผ่าน",
                                        ),
                                        backgroundColor: darkForest,
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    "ลืมรหัสผ่าน?",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: darkForest,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),

                            // Login Button
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
                                    color: darkForest.withValues(alpha: 0.28),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleLogin,
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
                                      "เข้าสู่ระบบ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register Link Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "ยังไม่มีบัญชีสมาชิก? ",
                          style: TextStyle(
                            color: textMuted,
                            fontSize: 13,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterStep1View(),
                            ),
                          ),
                          child: const Text(
                            "สมัครสมาชิกใหม่",
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
                  ],
                ),
              ),
            ),
          ),

          // ── Loading Overlay ───────────────────────────────────
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
                        "กำลังเข้าสู่ระบบ...",
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
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;

  const _AuthInputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
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
          size: 20,
        ),
        suffixIcon: widget.onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  widget.obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 20,
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
