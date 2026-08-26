import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/user/dtos/login_request.dart';
import 'package:greenpass/features/user/services/user_service.dart';
import 'package:greenpass/features/home_view.dart';
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

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color softBrown = Color(0xFF8B6F47);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color midGreen = Color(0xFF40916C);

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: isLoading
          ? Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(forestGreen),
                        strokeWidth: 3,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "กำลังเข้าสู่ระบบ...",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                // ── ส่วนบน gradient เขียว
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.45,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [darkGreen, midGreen, forestGreen],
                      ),
                    ),
                  ),
                ),

                // ── ส่วนล่าง cream
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.55,
                  child: Container(color: creamBg),
                ),

                // ── ลายตกแต่ง
                Positioned(
                  top: 40,
                  right: -20,
                  child: Icon(
                    Icons.forest,
                    size: 120,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  top: 80,
                  left: -30,
                  child: Icon(
                    Icons.park,
                    size: 160,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 40,
                  child: Icon(
                    Icons.eco,
                    size: 60,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: forestGreen.withOpacity(0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  right: -60,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightGreen.withOpacity(0.1),
                    ),
                  ),
                ),

                // ── เนื้อหาหลัก
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header
                        SizedBox(
                          height: size.height * 0.32,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.forest,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "GreenPass",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "สมุดเดินทางอุทยานแห่งชาติ",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "ยินดีต้อนรับ",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Text(
                                  "เข้าสู่ระบบเพื่อเริ่มต้นการเดินทาง",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // username
                                _AnimatedTextField(
                                  controller: usernameController,
                                  label: "ชื่อผู้ใช้งาน",
                                  hint: "กรอกชื่อผู้ใช้งาน",
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "กรุณากรอกชื่อผู้ใช้งาน";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // password
                                _AnimatedTextField(
                                  controller: passwordController,
                                  label: "รหัสผ่าน",
                                  hint: "กรอกรหัสผ่าน",
                                  icon: Icons.lock_outline,
                                  obscure: _obscurePassword,
                                  onToggleObscure: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty)
                                      return "กรุณากรอกรหัสผ่าน";
                                    if (!(value.length >= 4 &&
                                        value.length <= 16)) {
                                      return "ต้องมีความยาวตั้งเเต่ 4 - 16 ตัวอักษร";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 4),

                                // Remember me + ลืมรหัสผ่าน
                                Row(
                                  children: [
                                    Transform.scale(
                                      scale: 0.9,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (v) =>
                                            setState(() => _rememberMe = v!),
                                        activeColor: forestGreen,
                                        checkColor: Colors.white,
                                        side: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "จดจำฉัน",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        "ลืมรหัสผ่าน?",
                                        style: TextStyle(
                                          color: softBrown,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // ปุ่มเข้าสู่ระบบ
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (!formKey.currentState!.validate())
                                        return;
                                      try {
                                        setState(() => isLoading = true);
                                        final user = await userSevice.login(
                                          LoginRequest(
                                            username: usernameController.text,
                                            password: passwordController.text,
                                          ),
                                        );
                                        Session.currentUser = user.result;
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("เข้าสู่ระบบสำเร็จ"),
                                            backgroundColor: Color(0xFF2D6A4F),
                                          ),
                                        );
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => MainView(),
                                          ),
                                        );
                                      } on DioException catch (e) {
                                        if (!mounted) return;
                                        final statusCode =
                                            e.response?.statusCode;
                                        String message;
                                        if (statusCode == 401) {
                                          message = "รหัสผ่านไม่ถูกต้อง";
                                        } else if (statusCode == 404) {
                                          message = "ไม่มีบัญชีนี้ในระบบ";
                                        } else {
                                          message =
                                              "เกิดข้อผิดพลาด กรุณาลองใหม่";
                                        }
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(message),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } finally {
                                        setState(() => isLoading = false);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: forestGreen,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      "เข้าสู่ระบบ",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // สมัครสมาชิก
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "ยังไม่มีบัญชี? ",
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      RegisterStep1View(),
                                  transitionsBuilder:
                                      (_, animation, __, child) {
                                        return SlideTransition(
                                          position:
                                              Tween<Offset>(
                                                begin: const Offset(1, 0),
                                                end: Offset.zero,
                                              ).animate(
                                                CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.easeInOut,
                                                ),
                                              ),
                                          child: child,
                                        );
                                      },
                                ),
                              ),
                              child: const Text(
                                "สมัครสมาชิก",
                                style: TextStyle(
                                  color: forestGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: forestGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Animated TextField Widget ──────────────────────────────────────
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color creamBg = Color(0xFFF8F5F0);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: forestGreen.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        obscureText: widget.obscure,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: _isFocused ? forestGreen : Colors.black45,
            fontSize: 14,
          ),
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.black26),
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused ? forestGreen : Colors.black38,
            size: 20,
          ),
          suffixIcon: widget.onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                    widget.obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.black38,
                    size: 20,
                  ),
                  onPressed: widget.onToggleObscure,
                )
              : null,
          filled: true,
          fillColor: _isFocused ? Colors.white : creamBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: forestGreen, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          errorStyle: const TextStyle(fontSize: 11, color: Colors.red),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
