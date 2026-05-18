import 'package:flutter/material.dart';
import 'package:greenpass/feature/login_view.dart';
import 'package:greenpass/feature/register_step_2_view.dart';

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? label,
    IconData? icon,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label ?? hint,
        labelStyle: const TextStyle(color: Colors.black45),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        prefixIcon: icon != null
            ? Icon(icon, color: forestGreen, size: 20)
            : null,
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black38,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              ),
            )
          : Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightGreen.withOpacity(0.2),
                    ),
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
                      color: forestGreen.withOpacity(0.08),
                    ),
                  ),
                ),

                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      forceMaterialTransparency: true,
                      floating: true,
                      snap: true,
                      leading: IconButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginView()),
                        ),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(14),
                        ),
                        icon: const Icon(Icons.arrow_back, color: forestGreen),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Form(
                          key: formkey,
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: forestGreen,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Icon(
                                    Icons.forest,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "สมัครสมาชิก",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: forestGreen,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                "เริ่มต้นการเดินทางกับ GreenPass",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: softBrown,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: forestGreen,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              _buildTextField(
                                controller: _usernameController,
                                label: "ชื่อผู้ใช้งาน",
                                hint: "กรอกชื่อผู้ใช้งาน",
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "กรุณากรอกชื่อผู้ใช้งาน";
                                  } else if (!(value.length >= 4 &&
                                      value.length <= 16)) {
                                    return "ความยาว 4 - 16 ตัวอักษร";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _firstnameController,
                                      label: "ชื่อจริง",
                                      hint: "กรอกชื่อจริง",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "กรุณากรอกชื่อจริง";
                                        } else if (!(value.length >= 4 &&
                                            value.length <= 25)) {
                                          return "ความยาว 4 - 25 ตัวอักษร";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _lastnameController,
                                      label: "นามสกุล",
                                      hint: "กรอกนามสกุล",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "กรุณากรอกนามสกุล";
                                        } else if (!(value.length >= 4 &&
                                            value.length <= 25)) {
                                          return "ความยาว 4 - 25 ตัวอักษร";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _emailController,
                                label: "อีเมล",
                                hint: "กรอกอีเมล",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "กรุณากรอกอีเมล";
                                  }
                                  if (!RegExp(
                                    r'^[\w.-]+@[\w.-]+\.\w+$',
                                  ).hasMatch(value)) {
                                    return "รูปแบบอีเมลไม่ถูกต้อง";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _phoneController,
                                label: "หมายเลขโทรศัพท์",
                                hint: "กรอกหมายเลขโทรศัพท์",
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value!.length != 10) {
                                    return "กรุณากรอกหมายเลข 10 หลัก";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(
                                controller: _passwordController,
                                label: "รหัสผ่าน",
                                hint: "กรอกรหัสผ่าน",
                                icon: Icons.lock_outline,
                                obscure: _obscurePassword,
                                onToggleObscure: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "กรุณากรอกรหัสผ่าน";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              _buildTextField(
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
                                  if (value == null || value.isEmpty) {
                                    return "กรุณากรอกรหัสผ่าน";
                                  } else if (!(value.length >= 4 &&
                                      value.length <= 16)) {
                                    return "ความยาวตั้งแต่ 4 - 16";
                                  } else if (value !=
                                      _passwordController.text) {
                                    return "รหัสผ่านไม่ตรงกัน";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      if (formkey.currentState!.validate()) {
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
                                                          _emailController.text,
                                                      phone:
                                                          _phoneController.text,
                                                      password:
                                                          _passwordController
                                                              .text,
                                                      savedBirthDate:
                                                          _savedBirthDate,
                                                      savedGender: _savedGender,
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
                                          _savedBirthDate = data['birthDate'];
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
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 14,
                                      ),
                                    ),
                                    label: const Text(
                                      "ต่อไป",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    icon: const Icon(Icons.arrow_forward),
                                    iconAlignment: IconAlignment.end,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
