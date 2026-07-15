import 'package:flutter/material.dart';
import 'package:greenpass/features/views/login_view.dart';
import 'package:greenpass/features/views/register_step_2_view.dart';

class RegisterStep1View extends StatefulWidget {
  const RegisterStep1View({super.key});

  @override
  State<RegisterStep1View> createState() => _RegisterStep1ViewState();
}

class _RegisterStep1ViewState extends State<RegisterStep1View> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  bool isLoading = false;

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

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color softBrown = Color(0xFF8B6F47);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color midGreen = Color(0xFF40916C);

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
                        "กำลังโหลด...",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                // ── gradient ส่วนบน
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.28,
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

                // ── cream ส่วนล่าง
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.72,
                  child: Container(color: creamBg),
                ),

                // ── ลายตกแต่ง
                Positioned(
                  top: 20,
                  right: -20,
                  child: Icon(
                    Icons.forest,
                    size: 100,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: -20,
                  child: Icon(
                    Icons.eco,
                    size: 80,
                    color: Colors.white.withOpacity(0.06),
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

                // ── เนื้อหา
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        forceMaterialTransparency: true,
                        floating: true,
                        snap: true,
                        leading: IconButton(
                          onPressed: () =>
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const LoginView(),
                                ),
                              ),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // ── Header บนพื้นเขียว
                            SizedBox(
                              height: size.height * 0.14,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "สมัครสมาชิก",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "เริ่มต้นการเดินทางกับ GreenPass",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Step indicator
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // ── Form card
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
                                key: formkey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "ข้อมูลบัญชี",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "กรอกข้อมูลเพื่อสร้างบัญชีใหม่",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    _AnimatedTextField(
                                      controller: _usernameController,
                                      label: "ชื่อผู้ใช้งาน",
                                      hint: "กรอกชื่อผู้ใช้งาน",
                                      icon: Icons.person_outline,
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return "กรุณากรอกชื่อผู้ใช้งาน";
                                        if (!(value.length >= 4 &&
                                            value.length <= 16))
                                          return "ความยาว 4 - 16 ตัวอักษร";
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: _AnimatedTextField(
                                            controller: _firstnameController,
                                            label: "ชื่อจริง",
                                            hint: "กรอกชื่อจริง",
                                            icon: Icons.badge_outlined,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty)
                                                return "กรุณากรอกชื่อจริง";
                                              if (!(value.length >= 2 &&
                                                  value.length <= 25))
                                                return "ความยาว 2 - 25";
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _AnimatedTextField(
                                            controller: _lastnameController,
                                            label: "นามสกุล",
                                            hint: "กรอกนามสกุล",
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty)
                                                return "กรุณากรอกนามสกุล";
                                              if (!(value.length >= 2 &&
                                                  value.length <= 25))
                                                return "ความยาว 2 - 25";
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    _AnimatedTextField(
                                      controller: _emailController,
                                      label: "อีเมล",
                                      hint: "กรอกอีเมล",
                                      icon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return "กรุณากรอกอีเมล";
                                        if (!RegExp(
                                          r'^[\w.-]+@[\w.-]+\.\w+$',
                                        ).hasMatch(value))
                                          return "รูปแบบอีเมลไม่ถูกต้อง";
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    _AnimatedTextField(
                                      controller: _phoneController,
                                      label: "หมายเลขโทรศัพท์",
                                      hint: "กรอกหมายเลขโทรศัพท์",
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value!.length != 10)
                                          return "กรุณากรอกหมายเลข 10 หลัก";
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    _AnimatedTextField(
                                      controller: _passwordController,
                                      label: "รหัสผ่าน",
                                      hint: "กรอกรหัสผ่าน",
                                      icon: Icons.lock_outline,
                                      obscure: _obscurePassword,
                                      onToggleObscure: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return "กรุณากรอกรหัสผ่าน";
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    _AnimatedTextField(
                                      controller: _confirmPasswordController,
                                      label: "ยืนยันรหัสผ่าน",
                                      hint: "กรอกรหัสผ่านยืนยัน",
                                      icon: Icons.lock_outline,
                                      obscure: _obscureConfirmPassword,
                                      onToggleObscure: () => setState(
                                        () => _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return "กรุณากรอกรหัสผ่าน";
                                        if (!(value.length >= 4 &&
                                            value.length <= 16))
                                          return "ความยาวตั้งแต่ 4 - 16";
                                        if (value != _passwordController.text)
                                          return "รหัสผ่านไม่ตรงกัน";
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          if (formkey.currentState!
                                              .validate()) {
                                            final data =
                                                await Navigator.push<
                                                  Map<String, dynamic>
                                                >(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        RegisterStep2View(
                                                          username:
                                                              _usernameController
                                                                  .text,
                                                          firstname:
                                                              _firstnameController
                                                                  .text,
                                                          lastname:
                                                              _lastnameController
                                                                  .text,
                                                          email:
                                                              _emailController
                                                                  .text,
                                                          phone:
                                                              _phoneController
                                                                  .text,
                                                          password:
                                                              _passwordController
                                                                  .text,
                                                          savedBirthDate:
                                                              _savedBirthDate,
                                                          savedGender:
                                                              _savedGender,
                                                          savedIsForeigner:
                                                              _savedIsForeigner,
                                                          savedDistrict:
                                                              _savedDistrict,
                                                          savedSubDistrict:
                                                              _savedSubDistrict,
                                                          savedProvince:
                                                              _savedProvince,
                                                          savedZipcode:
                                                              _savedZipcode,
                                                        ),
                                                  ),
                                                );
                                            if (data != null) {
                                              _savedBirthDate =
                                                  data['birthDate'];
                                              _savedGender = data['gender'];
                                              _savedIsForeigner =
                                                  data['isForeigner'];
                                              _savedDistrict = data['district'];
                                              _savedSubDistrict =
                                                  data['subDistrict'];
                                              _savedProvince = data['province'];
                                              _savedZipcode = data['zipcode'];
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: forestGreen,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        label: const Text(
                                          "ต่อไป",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        icon: const Icon(Icons.arrow_forward),
                                        iconAlignment: IconAlignment.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "มีบัญชีอยู่แล้ว? ",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 13,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => const LoginView(),
                                        ),
                                      ),
                                  child: const Text(
                                    "เข้าสู่ระบบ",
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Animated TextField (เหมือน LoginView)
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
    this.keyboardType,
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
    _focusNode.addListener(
      () => setState(() => _isFocused = _focusNode.hasFocus),
    );
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
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: _isFocused ? forestGreen : Colors.black45,
            fontSize: 14,
          ),
          hintText: widget.hint,
          hintStyle: const TextStyle(color: Colors.black26),
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: _isFocused ? forestGreen : Colors.black38,
                  size: 20,
                )
              : null,
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
