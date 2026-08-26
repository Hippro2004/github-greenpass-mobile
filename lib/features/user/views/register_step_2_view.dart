import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  bool isLoading = false;
  int? gender;
  bool isForeigner = false;

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  late final birthDateController = TextEditingController();
  late final districtController = TextEditingController();
  late final subDistrictController = TextEditingController();
  late final provinceController = TextEditingController();
  late final zipcodeController = TextEditingController();

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color midGreen = Color(0xFF40916C);

  @override
  void initState() {
    super.initState();
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? label,
    IconData? icon,
    TextInputType? keyboardType,
    Future<void> Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return _AnimatedTextField(
      controller: controller,
      label: label ?? hint,
      hint: hint,
      icon: icon,
      keyboardType: keyboardType,
      onTap: onTap,
      validator: validator,
    );
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
                        "กำลังสมัครสมาชิก...",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                // gradient ส่วนบน
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

                // cream ส่วนล่าง
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: size.height * 0.72,
                  child: Container(color: creamBg),
                ),

                // ลายตกแต่ง
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
                          onPressed: () => Navigator.of(context).pop({
                            'birthDate': birthDateController.text.isNotEmpty
                                ? dateFormat.parse(birthDateController.text)
                                : null,
                            'gender': gender,
                            'isForeigner': isForeigner,
                            'district': districtController.text,
                            'subDistrict': subDistrictController.text,
                            'province': provinceController.text,
                            'zipcode': zipcodeController.text,
                          }),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // Header
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
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
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
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Form card
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
                                      "ข้อมูลส่วนตัว",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "กรอกข้อมูลส่วนตัวเพิ่มเติม",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // วันเกิด
                                    _buildTextField(
                                      controller: birthDateController,
                                      label: "วันเดือนปีเกิด",
                                      hint: "กรอกวันเดือนปีเกิด",
                                      icon: Icons.calendar_today_outlined,
                                      validator: (value) {
                                        if (value == null || value.isEmpty)
                                          return "กรุณาเลือกวันเดือนปีเกิด";
                                        return null;
                                      },
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime(2000),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                          builder: (context, child) => Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                    primary: forestGreen,
                                                  ),
                                            ),
                                            child: child!,
                                          ),
                                        );
                                        if (picked != null) {
                                          setState(
                                            () => birthDateController.text =
                                                dateFormat.format(picked),
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // เพศ
                                    FormField<int>(
                                      validator: (value) {
                                        if (gender == null)
                                          return "กรุณาเลือกเพศ";
                                        return null;
                                      },
                                      builder: (field) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          DropdownMenu<int>(
                                            width: double.infinity,
                                            initialSelection: gender,
                                            label: const Text("เพศ"),
                                            leadingIcon: Icon(
                                              gender == 0
                                                  ? Icons.male
                                                  : gender == 1
                                                  ? Icons.female
                                                  : Icons.person_outline,
                                              color: gender == 0
                                                  ? Colors.blue
                                                  : gender == 1
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
                                              backgroundColor:
                                                  WidgetStatePropertyAll(
                                                    Colors.white,
                                                  ),
                                              shape: WidgetStatePropertyAll(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                            ),
                                            inputDecorationTheme:
                                                InputDecorationTheme(
                                                  filled: true,
                                                  fillColor: creamBg,
                                                  labelStyle: const TextStyle(
                                                    color: Colors.black45,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          14,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  forestGreen,
                                                              width: 1.5,
                                                            ),
                                                      ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 16,
                                                      ),
                                                ),
                                            dropdownMenuEntries: const [
                                              DropdownMenuEntry(
                                                value: 0,
                                                label: "ชาย",
                                              ),
                                              DropdownMenuEntry(
                                                value: 1,
                                                label: "หญิง",
                                              ),
                                            ],
                                            onSelected: (value) {
                                              setState(() => gender = value);
                                              field.didChange(value);
                                            },
                                          ),
                                          if (field.hasError)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 12,
                                                top: 6,
                                              ),
                                              child: Text(
                                                field.errorText!,
                                                style: const TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // ชาวต่างชาติ
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: 1.1,
                                          child: Checkbox(
                                            value: isForeigner,
                                            onChanged: (value) => setState(
                                              () => isForeigner = value!,
                                            ),
                                            activeColor: forestGreen,
                                            checkColor: Colors.white,
                                            side: BorderSide(
                                              color: Colors.grey.shade300,
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "Is a foreigner? / เป็นชาวต่างชาติ",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (!isForeigner) ...[
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildTextField(
                                              controller: districtController,
                                              label: "เขต / อำเภอ",
                                              hint: "กรอกเขต / อำเภอ",
                                              validator: (v) =>
                                                  v == null || v.isEmpty
                                                  ? "กรุณากรอก"
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildTextField(
                                              controller: subDistrictController,
                                              label: "ตำบล / แขวง",
                                              hint: "กรอกตำบล / แขวง",
                                              validator: (v) =>
                                                  v == null || v.isEmpty
                                                  ? "กรุณากรอก"
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildTextField(
                                        controller: provinceController,
                                        label: "จังหวัด",
                                        hint: "กรอกจังหวัด",
                                        icon: Icons.location_on_outlined,
                                        validator: (v) => v == null || v.isEmpty
                                            ? "กรุณากรอกจังหวัด"
                                            : null,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildTextField(
                                        controller: zipcodeController,
                                        label: "เลขไปรษณีย์",
                                        hint: "กรอกเลขไปรษณีย์",
                                        icon: Icons.markunread_mailbox_outlined,
                                        keyboardType: TextInputType.number,
                                        validator: (v) => v == null || v.isEmpty
                                            ? "กรุณากรอกเลขไปรษณีย์"
                                            : null,
                                      ),
                                    ],

                                    const SizedBox(height: 24),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          if (!formkey.currentState!.validate())
                                            return;
                                          try {
                                            setState(() => isLoading = true);
                                            await userservice.register(
                                              RegisterRequest(
                                                username: widget.username,
                                                firstname: widget.firstname,
                                                lastname: widget.lastname,
                                                email: widget.email,
                                                phone: widget.phone,
                                                dateOfBirth:
                                                    birthDateController.text,
                                                gender: gender!,
                                                isForeigner: isForeigner,
                                                distrcict:
                                                    districtController.text,
                                                subDistrict:
                                                    subDistrictController.text,
                                                province:
                                                    provinceController.text,
                                                zipcode: zipcodeController.text,
                                                password: widget.password,
                                              ),
                                            );
                                            if (!mounted) return;
                                            await showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                title: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      color: forestGreen,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "สมัครสมาชิกสำเร็จ",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                  "ยินดีต้อนรับสู่ GreenPass\nสามารถเข้าสู่ระบบได้เลยครับ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          forestGreen,
                                                      foregroundColor:
                                                          Colors.white,
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      "เข้าสู่ระบบ",
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (!mounted) return;
                                            Navigator.of(
                                              context,
                                            ).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const LoginView(),
                                              ),
                                            );
                                          } on DioException catch (e) {
                                            if (!mounted) return;
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                title: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.error_outline,
                                                      color: Colors.red,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "สมัครสมาชิกไม่สำเร็จ",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: Text(
                                                  e.response?.data['message'] ??
                                                      "เกิดข้อผิดพลาด",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      foregroundColor:
                                                          Colors.white,
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                    ),
                                                    child: const Text("ตกลง"),
                                                  ),
                                                ],
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
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                        label: const Text(
                                          "สมัครสมาชิก",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        icon: const Icon(Icons.check),
                                        iconAlignment: IconAlignment.end,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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

// ── Animated TextField
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Future<void> Function()? onTap;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.onToggleObscure,
    this.validator,
    this.keyboardType,
    this.onTap,
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
