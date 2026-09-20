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

  // ── Vibrant Wilderness Palette ─────────────────────────────────
  static const Color screenBg = Color(0xFFF3F7F5);
  static const Color darkForest = Color(0xFF064E3B);
  static const Color emeraldTint = Color(0xFF00A86B);
  static const Color mintLight = Color(0xFFE8F7F0);
  static const Color mintBorder = Color(0xFFD6EFE2);
  static const Color mintPillBg = Color(0xFFD1FAE5);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("ไม่สามารถเลือกรูปภาพได้: $e")));
      }
    }
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "เปลี่ยนรูปโปรไฟล์",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: mintLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: mintBorder),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: darkForest,
                    size: 22,
                  ),
                ),
                title: const Text(
                  "ถ่ายภาพด้วยกล้อง",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                subtitle: const Text(
                  "ถ่ายภาพใหม่ทันทีจากกล้องของคุณ",
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: textMuted,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: mintLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: mintBorder),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: darkForest,
                    size: 22,
                  ),
                ),
                title: const Text(
                  "เลือกจากคลังรูปภาพ",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                subtitle: const Text(
                  "เลือกรูปภาพที่มีอยู่แล้วจากอัลบั้ม",
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: textMuted,
                ),
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
        uploadedImageUrl = await _userService.uploadProfileImage(
          _selectedImageFile!,
        );
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
        Session.currentUser!.firstname = _firstnameController.text;
        Session.currentUser!.lastname = _lastnameController.text;
        Session.currentUser!.email = _emailController.text;
        Session.currentUser!.phone = _phoneController.text;
        Session.currentUser!.birthDay = _birthDateController.text;
        Session.currentUser!.gender = _gender;
        Session.currentUser!.isForeigner = _isForeigner;
        Session.currentUser!.district = _districtController.text;
        Session.currentUser!.subDistrict = _subDistrictController.text;
        Session.currentUser!.province = _provinceController.text;
        Session.currentUser!.zipcode = _zipcodeController.text;
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
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("แก้ไขข้อมูลสำเร็จ"),
            ],
          ),
          backgroundColor: darkForest,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
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
    final user = Session.currentUser;
    final displayName = [
      _firstnameController.text,
      _lastnameController.text,
    ].join(' ').trim();
    final initial = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : (user?.username?.isNotEmpty == true
              ? user!.username!.characters.first.toUpperCase()
              : 'U');
    final resolvedUrl = resolveImageUrl(_currentProfileImage);

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
              onTap: () => Navigator.pop(context),
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
              "แก้ไขข้อมูลส่วนตัว",
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
      ),
      bottomNavigationBar: _buildBottomBar(),
      body: _isFetchingProfile
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: darkForest),
                  SizedBox(height: 16),
                  Text(
                    "กำลังโหลดข้อมูลส่วนตัว...",
                    style: TextStyle(
                      color: darkForest,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Avatar Hero Section ──────────────────────────
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _showImagePickerBottomSheet,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: mintLight,
                                      border: Border.all(
                                        color: emeraldTint.withValues(
                                          alpha: 0.35,
                                        ),
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: darkForest.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _selectedImageFile != null
                                          ? Image.file(
                                              _selectedImageFile!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : (resolvedUrl.isNotEmpty
                                                ? Image.network(
                                                    resolvedUrl,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Center(
                                                          child: Text(
                                                            initial,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 36,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      darkForest,
                                                                ),
                                                          ),
                                                        ),
                                                  )
                                                : Center(
                                                    child: Text(
                                                      initial,
                                                      style: const TextStyle(
                                                        fontSize: 36,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: darkForest,
                                                      ),
                                                    ),
                                                  )),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: darkForest,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _showImagePickerBottomSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: mintPillBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: mintBorder),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 12,
                                      color: darkForest,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "เปลี่ยนรูปภาพ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: darkForest,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Section 1: ข้อมูลส่วนตัว ───────────────────────
                      _buildSectionHeader(
                        icon: Icons.person_rounded,
                        title: "ข้อมูลพื้นฐาน",
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: darkForest.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfileInputField(
                              controller: _firstnameController,
                              icon: Icons.badge_outlined,
                              label: "ชื่อจริง",
                              hint: "กรอกชื่อจริง",
                              validator: (v) => v == null || v.isEmpty
                                  ? "กรุณากรอกชื่อจริง"
                                  : null,
                            ),

                            const SizedBox(height: 14),
                            _ProfileInputField(
                              controller: _lastnameController,
                              icon: Icons.badge_outlined,
                              label: "นามสกุล",
                              hint: "กรอกนามสกุล",
                              validator: (v) => v == null || v.isEmpty
                                  ? "กรุณากรอกนามสกุล"
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _ProfileInputField(
                              controller: _emailController,
                              label: "อีเมล",
                              hint: "กรอกอีเมล",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "กรุณากรอกอีเมล";
                                }
                                if (!RegExp(
                                  r'^[\w.-]+@[\w.-]+\.\w+$',
                                ).hasMatch(v)) {
                                  return "รูปแบบอีเมลไม่ถูกต้อง";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _ProfileInputField(
                              controller: _phoneController,
                              label: "หมายเลขโทรศัพท์",
                              hint: "กรอกหมายเลขโทรศัพท์ 10 หลัก",
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) => v != null && v.length != 10
                                  ? "กรุณากรอกหมายเลข 10 หลัก"
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _ProfileInputField(
                              controller: _birthDateController,
                              label: "วันเกิด (พ.ศ./ค.ศ.)",
                              hint: "เลือกวันเกิด",
                              icon: Icons.calendar_today_outlined,
                              onTap: () async {
                                final initialDate =
                                    DateTime.tryParse(
                                      _birthDateController.text,
                                    ) ??
                                    DateTime(2000);
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
                                  setState(
                                    () => _birthDateController.text =
                                        _dateFormat.format(picked),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Gender Selector
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
                                  child: _buildGenderOption(
                                    value: 0,
                                    label: "ชาย",
                                    icon: Icons.male_rounded,
                                    accentColor: const Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildGenderOption(
                                    value: 1,
                                    label: "หญิง",
                                    icon: Icons.female_rounded,
                                    accentColor: const Color(0xFFEC4899),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Is Foreigner
                            InkWell(
                              onTap: () =>
                                  setState(() => _isForeigner = !_isForeigner),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 2,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _isForeigner,
                                        onChanged: (v) => setState(
                                          () => _isForeigner = v ?? false,
                                        ),
                                        activeColor: darkForest,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      "เป็นชาวต่างชาติ (Foreigner)",
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        color: textDark,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Section 2: ข้อมูลที่อยู่ (ถ้าไม่ใช่ต่างชาติ) ──
                      if (!_isForeigner) ...[
                        _buildSectionHeader(
                          icon: Icons.location_on_rounded,
                          title: "ข้อมูลที่อยู่",
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: darkForest.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _ProfileInputField(
                                controller: _subDistrictController,
                                label: "แขวง",
                                hint: "แขวง",
                                icon: Icons.signpost_outlined,
                              ),
                              const SizedBox(height: 14),
                              _ProfileInputField(
                                controller: _districtController,
                                label: "เขต",
                                hint: "เขต",
                                icon: Icons.apartment_outlined,
                              ),
                              const SizedBox(height: 14),
                              _ProfileInputField(
                                controller: _provinceController,
                                label: "จังหวัด",
                                hint: "กรอกจังหวัด",
                                icon: Icons.map_outlined,
                              ),
                              const SizedBox(height: 14),
                              _ProfileInputField(
                                controller: _zipcodeController,
                                label: "รหัสไปรษณีย์",
                                hint: "กรอกรหัสไปรษณีย์ 5 หลัก",
                                icon: Icons.markunread_mailbox_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Section 3: เปลี่ยนรหัสผ่าน ───────────────────
                      _buildSectionHeader(
                        icon: Icons.lock_rounded,
                        title: "ความปลอดภัยและรหัสผ่าน",
                        subtitle: "เว้นว่างไว้หากไม่ต้องการเปลี่ยนรหัสผ่าน",
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: darkForest.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _ProfileInputField(
                              controller: _passwordController,
                              label: "รหัสผ่านใหม่",
                              hint: "กรอกรหัสผ่านใหม่ (ถ้าต้องการเปลี่ยน)",
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _ProfileInputField(
                              controller: _confirmPasswordController,
                              label: "ยืนยันรหัสผ่านใหม่",
                              hint: "กรอกรหัสผ่านใหม่อีกครั้งเพื่อยืนยัน",
                              icon: Icons.lock_outline_rounded,
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: mintLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: darkForest),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 11.5, color: textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGenderOption({
    required int value,
    required String label,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? mintLight : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? emeraldTint : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? darkForest : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? darkForest : textMuted,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: emeraldTint,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: darkForest.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: darkForest,
            foregroundColor: Colors.white,
            disabledBackgroundColor: darkForest.withValues(alpha: 0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "บันทึกการเปลี่ยนแปลง",
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Profile Input Field ──────────────────────────────────────────
class _ProfileInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;
  final Future<void> Function()? onTap;
  final String? Function(String?)? validator;

  const _ProfileInputField({
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
  State<_ProfileInputField> createState() => _ProfileInputFieldState();
}

class _ProfileInputFieldState extends State<_ProfileInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  static const Color darkForest = Color(0xFF064E3B);
  static const Color emeraldTint = Color(0xFF00A86B);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() => _isFocused = _focusNode.hasFocus);
      }
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
      readOnly: widget.onTap != null,
      onTap: widget.onTap,
      validator: widget.validator,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF0F172A),
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
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                color: _isFocused ? darkForest : Colors.grey.shade400,
                size: 18,
              )
            : null,
        suffixIcon: widget.onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  widget.obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade400,
                  size: 18,
                ),
                onPressed: widget.onToggleObscure,
              )
            : (widget.onTap != null
                  ? Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.grey.shade400,
                      size: 18,
                    )
                  : null),
        filled: true,
        fillColor: _isFocused
            ? const Color(0xFFE8F7F0).withValues(alpha: 0.35)
            : const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: emeraldTint, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}
