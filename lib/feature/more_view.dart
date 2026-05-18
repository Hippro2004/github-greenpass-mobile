import 'package:flutter/material.dart';
import 'package:greenpass/core/session.dart';
import 'package:greenpass/feature/edit_profile_view.dart';
import 'package:greenpass/feature/login_view.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color creamBg = Color(0xFFF8F5F0);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "ออกจากระบบ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("คุณต้องการออกจากระบบใช่หรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "ยกเลิก",
              style: TextStyle(color: Colors.black45),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Session.clear();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("ออกจากระบบ"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: forestGreen.withOpacity(0.1),
                    child: const Icon(Icons.person_outline, color: forestGreen),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "คุณ ${Session.currentUser!.firstname}",
                    style: const TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      label: "แก้ไขข้อมูลส่วนตัว",
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileView(),
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade100),
                    _buildMenuItem(
                      icon: Icons.logout,
                      label: "ออกจากระบบ",
                      color: Colors.red,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = const Color(0xFF2D6A4F),
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: TextStyle(fontSize: 14, color: color)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade300),
      onTap: onTap,
    );
  }
}
