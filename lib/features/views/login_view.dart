import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/core/storage/session_strorage.dart';
import 'package:greenpass/dtos/login_request.dart';
import 'package:greenpass/features/services/user_service.dart';
import 'package:greenpass/features/home_view.dart';
import 'package:greenpass/features/views/register_step_1_view.dart';

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

  late final TextEditingController usernameController;
  late final TextEditingController passwordController;

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color softBrown = Color(0xFF8B6F47);

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
    return Scaffold(
      backgroundColor: creamBg,
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
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 20,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              "GreenPass",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: forestGreen,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              "สมุดเดินทางอุทยานแห่งชาติ",
                              style: TextStyle(
                                fontSize: 13,
                                color: softBrown,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            "ยินดีต้อนรับ",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
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

                          TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: "ชื่อผู้ใช้งาน",
                              labelStyle: TextStyle(color: Colors.black45),
                              hintText: "กรอกชื่อผู้ใช้งาน",
                              hintStyle: const TextStyle(color: Colors.black26),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: forestGreen,
                              ),
                              filled: true,
                              fillColor: Colors.white,
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
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "กรุณากรอกชื่อผู้ใช้งาน";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          TextFormField(
                            obscureText: _obscurePassword,
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: "รหัสผ่าน",
                              labelStyle: TextStyle(color: Colors.black45),
                              hintText: "กรอกรหัสผ่าน",
                              hintStyle: const TextStyle(color: Colors.black26),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: forestGreen,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.black38,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
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
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "กรุณากรอกรหัสผ่าน";
                              } else if (!(value.length >= 4 &&
                                  value.length <= 16)) {
                                return "ต้องมีความยาวตั้งเเต่ 4 - 16 ตัวอักษร";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
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
                          ),
                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;
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
                                  ScaffoldMessenger.of(context).showSnackBar(
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

                                  final statusCode = e.response?.statusCode;

                                  String message;
                                  if (statusCode == 401) {
                                    message = "รหัสผ่านไม่ถูกต้อง";
                                  } else if (statusCode == 404) {
                                    message = "ไม่มีบัญชีนี้ในระบบ";
                                  } else {
                                    message = "เกิดข้อผิดพลาด กรุณาลองใหม่";
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: Colors.red,
                                    ),
                                  );

                                  // showDialog(
                                  //   context: context,
                                  //   builder: (_) => AlertDialog(
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(20),
                                  //     ),
                                  //     title: const Row(
                                  //       children: [
                                  //         Icon(
                                  //           Icons.error_outline,
                                  //           color: Colors.red,
                                  //           size: 24,
                                  //         ),
                                  //         SizedBox(width: 8),
                                  //         Text(
                                  //           "เข้าสู่ระบบไม่สำเร็จ",
                                  //           style: TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.bold,
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     content: Text(
                                  //       message,
                                  //       style: const TextStyle(fontSize: 14),
                                  //     ),
                                  //     actions: [
                                  //       ElevatedButton(
                                  //         onPressed: () =>
                                  //             Navigator.pop(context),
                                  //         style: ElevatedButton.styleFrom(
                                  //           backgroundColor: forestGreen,
                                  //           foregroundColor: Colors.white,
                                  //           elevation: 0,
                                  //           shape: RoundedRectangleBorder(
                                  //             borderRadius:
                                  //                 BorderRadius.circular(12),
                                  //           ),
                                  //         ),
                                  //         child: const Text("ตกลง"),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // );
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

                          const SizedBox(height: 24),
                          Center(
                            child: Row(
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
                                  onTap: () {
                                    Navigator.of(context).push(
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
                                    );
                                  },
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
