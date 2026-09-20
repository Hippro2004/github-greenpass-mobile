import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/core/network/image_helper.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/features/user/dtos/update_request.dart';
import 'package:greenpass/features/user/services/user_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final UserSevice _userService = UserSevice();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _isFetchingProfile = true;

  File? _selectedImageFile;
  String? _currentProfileImage;

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

  // ── ธีมสีเดียวกับหน้า Login ────────────────────────────
  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color softBrown = Color(0xFF8B6F47);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color midGreen = Color(0xFF40916C);

  @override
  void initState() {
    super.initState();
    final user = Session.currentUser;
    _firstnameController = TextEditingController(text: user?.firstname ?? '');
    _lastnameController = TextEditingController(text: user?.lastname ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _birthDateController = TextEditingController(text: user?.birthDay ?? '');
    _districtController = TextEditingController(text: user?.district ?? '');
    _subDistrictController = TextEditingController(
      text: user?.subDistrict ?? '',
    );
    _provinceController = TextEditingController(text: user?.province ?? '');
    _zipcodeController = TextEditingController(text: user?.zipcode ?? '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _gender = user?.gender;
    _isForeigner = user?.isForeigner ?? false;
    _currentProfileImage = user?.profileImage;

    _fetchProfile();
  }

  Future<void> _fetchProfile({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isFetchingProfile = true);
    }
    try {
      final profile = await _userService.getProfile();

      if (Session.currentUser != null) {
        Session.currentUser!
          ..firstname = profile.firstname
          ..lastname = profile.lastname
          ..email = profile.email
          ..phone = profile.phone
          ..birthDay = profile.birthDate
          ..gender = profile.gender
          ..isForeigner = profile.isForeigner
          ..district = profile.district
          ..subDistrict = profile.subDistrict
          ..province = profile.province
          ..zipcode = profile.zipcode
          ..profileImage =
              profile.profileImage ?? Session.currentUser?.profileImage;
      }

      if (profile.profileImage != null && profile.profileImage!.isNotEmpty) {
        _currentProfileImage = profile.profileImage;
      }

      _firstnameController.text = profile.firstname;
      _lastnameController.text = profile.lastname;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _birthDateController.text = profile.birthDate;
      _districtController.text = profile.district;
      _subDistrictController.text = profile.subDistrict;
      _provinceController.text = profile.province;
      _zipcodeController.text = profile.zipcode;
      _gender = profile.gender;
      _isForeigner = profile.isForeigner;
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data?['message'] ?? "ไม่สามารถดึงข้อมูลส่วนตัวได้",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เกิดข้อผิดพลาด: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingProfile = false);
      }
    }
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _selectedImageFile = File(picked.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ไม่สามารถเลือกรูปภาพได้: $e")),
        );
      }
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "เปลี่ยนรูปโปรไฟล์",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkGreen,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.camera_alt, color: forestGreen),
                ),
                title: const Text("ถ่ายรูปด้วยกล้อง"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.photo_library, color: forestGreen),
                ),
                title: const Text("เลือกจากคลังรูปภาพ"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      setState(() => _isLoading = true);

      String? uploadedImageUrl = _currentProfileImage;
      if (_selectedImageFile != null) {
        uploadedImageUrl =
            await _userService.uploadProfileImage(_selectedImageFile!);
      }

      await _userService.update(
        Session.currentUser!.username!,
        UpdateRequest(
          firstname: _firstnameController.text,
          lastname: _lastnameController.text,
          profileImage: uploadedImageUrl,
          email: _emailController.text,
          phone: _phoneController.text,
          birthDate: _birthDateController.text,
          gender: _gender ?? 0,
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

      if (Session.currentUser != null) {
        Session.currentUser!.profileImage = uploadedImageUrl;
      }
      _currentProfileImage = uploadedImageUrl;
      _selectedImageFile = null;

      // ยิง API ดึงข้อมูลล่าสุดมาแสดง
      await _fetchProfile(showLoading: false);

      _passwordController.clear();
      _confirmPasswordController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("แก้ไขข้อมูลสำเร็จ"),
          backgroundColor: forestGreen,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.response?.data?['message'] ?? "เกิดข้อผิดพลาด"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Stack(
        children: [
          // ── ลายตกแต่งพื้นหลัง เหมือนหน้า Login เป๊ะ ─────
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
          Positioned(
            top: 90,
            right: -10,
            child: Icon(
              Icons.forest,
              size: 90,
              color: Colors.black.withOpacity(0.03),
            ),
          ),
          Positioned(
            top: 140,
            left: -30,
            child: Icon(
              Icons.park,
              size: 120,
              color: Colors.black.withOpacity(0.025),
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
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: forestGreen,
                      size: 18,
                    ),
                  ),
                ),
                title: const Text(
                  "แก้ไขข้อมูลส่วนตัว",
                  style: TextStyle(
                    color: forestGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
                centerTitle: true,
              ),
              if (_isFetchingProfile)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: forestGreen),
                        SizedBox(height: 16),
                        Text(
                          "กำลังโหลดข้อมูลส่วนตัว...",
                          style: TextStyle(
                            color: forestGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
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
                          child: GestureDetector(
                            onTap: _showImagePickerBottomSheet,
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        darkGreen,
                                        midGreen,
                                        forestGreen,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: forestGreen.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 14,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: Colors.grey.shade100,
                                    backgroundImage: _selectedImageFile != null
                                        ? FileImage(_selectedImageFile!)
                                        : (resolveImageUrl(_currentProfileImage)
                                                .isNotEmpty
                                            ? NetworkImage(
                                                resolveImageUrl(
                                                  _currentProfileImage,
                                                ),
                                              )
                                            : null) as ImageProvider?,
                                    child: (_selectedImageFile == null &&
                                            resolveImageUrl(
                                              _currentProfileImage,
                                            ).isEmpty)
                                        ? const Icon(
                                            Icons.person,
                                            size: 45,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: forestGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
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
                        ),
                        const SizedBox(height: 28),

                        Row(
                          children: [
                            Expanded(
                              child: _AnimatedTextField(
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
                              child: _AnimatedTextField(
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
                        const SizedBox(height: 16),

                        _AnimatedTextField(
                          controller: _emailController,
                          label: "อีเมล",
                          hint: "กรอกอีเมล",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return "กรุณากรอกอีเมล";
                            if (!RegExp(
                              r'^[\w.-]+@[\w.-]+\.\w+$',
                            ).hasMatch(v)) {
                              return "รูปแบบอีเมลไม่ถูกต้อง";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        _AnimatedTextField(
                          controller: _phoneController,
                          label: "หมายเลขโทรศัพท์",
                          hint: "กรอกหมายเลขโทรศัพท์",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.length != 10
                              ? "กรุณากรอกหมายเลข 10 หลัก"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        _AnimatedTextField(
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
                        const SizedBox(height: 16),

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
                              scale: 1.1,
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
                                child: _AnimatedTextField(
                                  controller: _districtController,
                                  label: "เขต / อำเภอ",
                                  hint: "กรอกเขต / อำเภอ",
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AnimatedTextField(
                                  controller: _subDistrictController,
                                  label: "ตำบล / แขวง",
                                  hint: "กรอกตำบล / แขวง",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _AnimatedTextField(
                            controller: _provinceController,
                            label: "จังหวัด",
                            hint: "กรอกจังหวัด",
                            icon: Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 16),
                          _AnimatedTextField(
                            controller: _zipcodeController,
                            label: "เลขไปรษณีย์",
                            hint: "กรอกเลขไปรษณีย์",
                            icon: Icons.markunread_mailbox_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ],

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: softBrown,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "เปลี่ยนรหัสผ่าน (ไม่บังคับ)",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: softBrown,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedTextField(
                          controller: _passwordController,
                          label: "รหัสผ่านใหม่",
                          hint: "กรอกรหัสผ่านใหม่",
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _AnimatedTextField(
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
                        const SizedBox(height: 28),

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

// ── Animated TextField Widget เดียวกับหน้า Login ──────────
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final Future<void> Function()? onTap;
  final String? Function(String?)? validator;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.onTap,
    this.validator,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  static const Color forestGreen = Color(0xFF2D6A4F);

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
        keyboardType: widget.keyboardType,
        readOnly: widget.onTap != null,
        onTap: widget.onTap,
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
