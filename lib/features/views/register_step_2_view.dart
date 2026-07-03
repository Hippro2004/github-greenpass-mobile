import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/dtos/register_request.dart';
import 'package:greenpass/features/auth/services/user_service.dart';
import 'package:greenpass/features/views/login_view.dart';
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
  static const Color softBrown = Color(0xFF8B6F47);

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
    Future<Null> Function()? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onTap: onTap,
      validator: validator,
      readOnly: onTap != null,
      decoration: InputDecoration(
        labelText: label ?? hint,
        labelStyle: const TextStyle(color: Colors.black45),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        prefixIcon: icon != null
            ? Icon(icon, color: forestGreen, size: 20)
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
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 24,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: forestGreen,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

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
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(2000),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );

                                  if (pickedDate != null) {
                                    setState(
                                      () => birthDateController.text =
                                          dateFormat.format(pickedDate),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              FormField<int>(
                                validator: (value) {
                                  if (gender == null) return "กรุณาเลือกเพศ";
                                  return null;
                                },
                                builder: (field) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        backgroundColor: WidgetStatePropertyAll(
                                          Colors.white,
                                        ),
                                        shape: WidgetStatePropertyAll(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      inputDecorationTheme:
                                          InputDecorationTheme(
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelStyle: const TextStyle(
                                              color: Colors.black45,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              borderSide: const BorderSide(
                                                color: forestGreen,
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
                                          top: 8,
                                        ),
                                        child: Text(
                                          field.errorText!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // DropdownMenu<int>(
                              //   width: double.infinity,
                              //   initialSelection: gender,
                              //   label: const Text("เพศ"),
                              //   leadingIcon: Icon(
                              //     gender == 0
                              //         ? Icons.male
                              //         : gender == 1
                              //         ? Icons.female
                              //         : Icons.person_outline,
                              //     color: gender == 0
                              //         ? Colors.blue
                              //         : gender == 1
                              //         ? Colors.pink
                              //         : forestGreen,
                              //     size: 20,
                              //   ),
                              //   trailingIcon: const Icon(
                              //     Icons.keyboard_arrow_down,
                              //     color: forestGreen,
                              //   ),
                              //   selectedTrailingIcon: const Icon(
                              //     Icons.keyboard_arrow_up,
                              //     color: forestGreen,
                              //   ),
                              //   menuStyle: MenuStyle(
                              //     backgroundColor: WidgetStatePropertyAll(
                              //       Colors.white,
                              //     ),
                              //     shape: WidgetStatePropertyAll(
                              //       RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(14),
                              //       ),
                              //     ),
                              //   ),
                              //   inputDecorationTheme: InputDecorationTheme(
                              //     filled: true,
                              //     fillColor: Colors.white,
                              //     labelStyle: const TextStyle(
                              //       color: Colors.black45,
                              //     ),
                              //     border: OutlineInputBorder(
                              //       borderRadius: BorderRadius.circular(14),
                              //       borderSide: BorderSide.none,
                              //     ),
                              //     enabledBorder: OutlineInputBorder(
                              //       borderRadius: BorderRadius.circular(14),
                              //       borderSide: BorderSide(
                              //         color: Colors.grey.shade200,
                              //       ),
                              //     ),
                              //     focusedBorder: OutlineInputBorder(
                              //       borderRadius: BorderRadius.circular(14),
                              //       borderSide: const BorderSide(
                              //         color: forestGreen,
                              //         width: 1.5,
                              //       ),
                              //     ),
                              //     contentPadding: const EdgeInsets.symmetric(
                              //       horizontal: 16,
                              //       vertical: 16,
                              //     ),
                              //   ),
                              //   dropdownMenuEntries: const [
                              //     DropdownMenuEntry(value: 0, label: "ชาย"),
                              //     DropdownMenuEntry(value: 1, label: "หญิง"),
                              //   ],
                              //   onSelected: (value) =>
                              //       setState(() => gender = value),
                              // ),
                              Row(
                                children: [
                                  Transform.scale(
                                    scale: 1.2,
                                    child: Checkbox(
                                      value: isForeigner,
                                      onChanged: (value) =>
                                          setState(() => isForeigner = value!),
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
                                  Text(
                                    "เป็นชาวต่างชาติ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),
                              if (isForeigner == false) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: districtController,
                                        label: "เขต / อำเภอ",
                                        hint: "กรอกเขต / อำเภอ",
                                        validator: (value) {
                                          if (value == null || value.isEmpty)
                                            return "กรุณากรอกเขต / อำเภอ";
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: subDistrictController,
                                        label: "ตำบล / แขวง",
                                        hint: "กรอกตำบล / แขวง",
                                        validator: (value) {
                                          if (value == null || value.isEmpty)
                                            return "กรุณากรอกตำบล / แขวง";
                                          return null;
                                        },
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
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "กรุณากรอกจังหวัด";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                _buildTextField(
                                  controller: zipcodeController,
                                  label: "เลขไปรษณีย์",
                                  hint: "กรอกเลขไปรษณีย์",
                                  icon: Icons.markunread_mailbox_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return "กรุณากรอกเลขไปรษณีย์";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                              ],

                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
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
                                            distrcict: districtController.text,
                                            subDistrict:
                                                subDistrictController.text,
                                            province: provinceController.text,
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
                                                  Icons.check_circle_outline,
                                                  color: Color(0xFF2D6A4F),
                                                  size: 24,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  "สมัครสมาชิกสำเร็จ",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: const Text(
                                              "ยินดีต้อนรับสู่ GreenPass\nสามารถเข้าสู่ระบบได้เลยครับ",
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: forestGreen,
                                                  foregroundColor: Colors.white,
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
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (_) => const LoginView(),
                                          ),
                                        );
                                      } on DioException catch (e) {
                                        if (!mounted) return;

                                        final message =
                                            e.response!.data['message'];
                                        // if (e.response?.statusCode == 409) {
                                        //   message =
                                        //       "ชื่อผู้ใช้งานนี้มีอยู่แล้ว";
                                        // } else {
                                        //   message =
                                        //       "เกิดข้อผิดพลาด กรุณาลองใหม่";
                                        // }

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
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: Text(
                                              message,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
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
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 14,
                                      ),
                                    ),
                                    label: const Text(
                                      "สมัครสมาชิก",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    icon: const Icon(Icons.check),
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
