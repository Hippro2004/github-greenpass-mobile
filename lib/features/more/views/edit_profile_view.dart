import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/auth/dtos/update_request.dart';
import 'package:greenpass/features/auth/services/user_service.dart';
import 'package:intl/intl.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final UserSevice _userService = UserSevice();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final TextEditingController _firstnameController;
  late final TextEditingController _lastnameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _districtController;
  late final TextEditingController _subDistrictController;
  late final TextEditingController _provinceController;
  late final TextEditingController _zipcodeController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  int? _gender;
  bool _isForeigner = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final DateFormat _dateFormat = DateFormat("yyyy-MM-dd");

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color softBrown = Color(0xFF8B6F47);

  @override
  void initState() {
    super.initState();
    final user = Session.currentUser!;
    _firstnameController = TextEditingController(text: user.firstname);
    _lastnameController = TextEditingController(text: user.lastname);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _birthDateController = TextEditingController(text: user.birthDay ?? '');
    _districtController = TextEditingController(text: user.district ?? '');
    _subDistrictController = TextEditingController(
      text: user.subDistrict ?? '',
    );
    _provinceController = TextEditingController(text: user.province ?? '');
    _zipcodeController = TextEditingController(text: user.zipcode ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _gender = user.gender;
    _isForeigner = user.isForeigner ?? false;
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _districtController.dispose();
    _subDistrictController.dispose();
    _provinceController.dispose();
    _zipcodeController.dispose();
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
    Future<void> Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      readOnly: onTap != null,
      onTap: onTap,
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isLoading = true);

      await _userService.update(
        Session.currentUser!.username!,
        UpdateRequest(
          firstname: _firstnameController.text,
          lastname: _lastnameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          birthDate: _birthDateController.text,
          gender: _gender!,
          isForeigner: _isForeigner,
          district: _districtController.text,
          subDistrict: _subDistrictController.text,
          province: _provinceController.text,
          zipcode: _zipcodeController.text,
          password: _passwordController.text.isNotEmpty
              ? _passwordController.text
              : null,
        ),
      );

      Session.currentUser = Session.currentUser!
        ..firstname = _firstnameController.text;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("แก้ไขข้อมูลสำเร็จ"),
          backgroundColor: Color(0xFF2D6A4F),
        ),
      );
      Navigator.pop(context);
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data['message'] ?? "เกิดข้อผิดพลาด"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
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
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: forestGreen),
                ),
                title: const Text(
                  "แก้ไขข้อมูลส่วนตัว",
                  style: TextStyle(
                    color: forestGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.person,
                                  size: 45,
                                  color: Colors.grey,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: forestGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _firstnameController,
                                label: "ชื่อจริง",
                                hint: "กรอกชื่อจริง",
                                validator: (v) => v == null || v.isEmpty
                                    ? "กรุณากรอกชื่อจริง"
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastnameController,
                                label: "นามสกุล",
                                hint: "กรอกนามสกุล",
                                validator: (v) => v == null || v.isEmpty
                                    ? "กรุณากรอกนามสกุล"
                                    : null,
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
                          validator: (v) {
                            if (v == null || v.isEmpty) return "กรุณากรอกอีเมล";
                            if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(v))
                              return "รูปแบบอีเมลไม่ถูกต้อง";
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
                          validator: (v) => v!.length != 10
                              ? "กรุณากรอกหมายเลข 10 หลัก"
                              : null,
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _birthDateController,
                          label: "วันเดือนปีเกิด",
                          hint: "กรอกวันเดือนปีเกิด",
                          icon: Icons.calendar_today_outlined,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(
                                () => _birthDateController.text = _dateFormat
                                    .format(picked),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        DropdownMenu<int>(
                          width: double.infinity,
                          initialSelection: _gender,
                          label: const Text("เพศ"),
                          leadingIcon: Icon(
                            _gender == 0
                                ? Icons.male
                                : _gender == 1
                                ? Icons.female
                                : Icons.person_outline,
                            color: _gender == 0
                                ? Colors.blue
                                : _gender == 1
                                ? Colors.pink
                                : forestGreen,
                            size: 20,
                          ),
                          trailingIcon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: forestGreen,
                          ),
                          selectedTrailingIcon: const Icon(
                            Icons.keyboard_arrow_up,
                            color: forestGreen,
                          ),
                          menuStyle: MenuStyle(
                            backgroundColor: WidgetStatePropertyAll(
                              Colors.white,
                            ),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          inputDecorationTheme: InputDecorationTheme(
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: const TextStyle(color: Colors.black45),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: forestGreen,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 0, label: "ชาย"),
                            DropdownMenuEntry(value: 1, label: "หญิง"),
                          ],
                          onSelected: (value) =>
                              setState(() => _gender = value),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: _isForeigner,
                                onChanged: (v) =>
                                    setState(() => _isForeigner = v!),
                                activeColor: forestGreen,
                                checkColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const Text(
                              "เป็นชาวต่างชาติ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),

                        if (!_isForeigner) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _districtController,
                                  label: "เขต / อำเภอ",
                                  hint: "กรอกเขต / อำเภอ",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _subDistrictController,
                                  label: "ตำบล / แขวง",
                                  hint: "กรอกตำบล / แขวง",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _provinceController,
                            label: "จังหวัด",
                            hint: "กรอกจังหวัด",
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _zipcodeController,
                            label: "เลขไปรษณีย์",
                            hint: "กรอกเลขไปรษณีย์",
                            icon: Icons.markunread_mailbox_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ],

                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "เปลี่ยนรหัสผ่าน (ไม่บังคับ)",
                            style: TextStyle(
                              fontSize: 13,
                              color: softBrown,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _passwordController,
                          label: "รหัสผ่านใหม่",
                          hint: "กรอกรหัสผ่านใหม่",
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: "ยืนยันรหัสผ่านใหม่",
                          hint: "กรอกรหัสผ่านใหม่อีกครั้ง",
                          icon: Icons.lock_outline,
                          obscure: _obscureConfirmPassword,
                          onToggleObscure: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                          validator: (v) {
                            if (_passwordController.text.isNotEmpty &&
                                v != _passwordController.text) {
                              return "รหัสผ่านไม่ตรงกัน";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: forestGreen,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: forestGreen.withOpacity(
                                0.6,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "บันทึก",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
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
