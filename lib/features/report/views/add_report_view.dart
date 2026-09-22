import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/features/park/models/park.dart';
import 'package:greenpass/features/park/views/park_search_view.dart';
import 'package:greenpass/features/report/dtos/add_report_request.dart';
import 'package:greenpass/features/report/services/report_service.dart';
import 'package:greenpass/features/report/services/report_type_service.dart';
import 'package:image_picker/image_picker.dart';

class AddReportView extends StatefulWidget {
  const AddReportView({super.key});

  @override
  State<AddReportView> createState() => _AddReportViewState();
}

class _AddReportViewState extends State<AddReportView> {
  final ReportService reportSerivce = ReportService();
  final ReportTypeService reportTypeService = ReportTypeService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingTypes = false;
  File? _image;
  Park? _selectedPark;
  String? _selectedReportTypeName;
  List<String> _reportTypeNames = [];
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

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
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _loadReportTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _image = File(picked.path));
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
                "แนบรูปภาพรายงาน",
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
                  "ถ่ายภาพปัญหาที่พบทันทีจากกล้องของคุณ",
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
                  "เลือกรูปภาพที่บันทึกไว้ในอัลบั้ม",
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

  Future<void> _selectPark() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ParkSearchView(
          onParkSelected: (park) {
            setState(() => _selectedPark = park);
          },
        ),
      ),
    );
  }

  Future<void> _loadReportTypes() async {
    try {
      setState(() => _isLoadingTypes = true);
      final reportTypes = await reportTypeService.getAllReportType();
      if (!mounted) return;

      final rawTypes = reportTypes
          .where((type) => type.typename.trim().isNotEmpty)
          .toList();

      final uniqueNames = <String>[];
      for (final type in rawTypes) {
        if (!uniqueNames.contains(type.typename)) {
          uniqueNames.add(type.typename);
        }
      }

      if (uniqueNames.isNotEmpty) {
        setState(() {
          _reportTypeNames = uniqueNames;
          _selectedReportTypeName = uniqueNames.first;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reportTypeNames = [];
        _selectedReportTypeName = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingTypes = false);
      }
    }
  }

  Future<void> _submitReport() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPark == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณาเลือกอุทยานแห่งชาติที่พบปัญหา"),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      String? uploadedImageName;
      if (_image != null) {
        uploadedImageName = await reportSerivce.uploadReportImage(_image!);
      }

      await reportSerivce.addReport(
        AddReportRequest(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          parkId: _selectedPark!.id,
          typeName: _selectedReportTypeName ?? '',
          reportType: _selectedReportTypeName,
          image: uploadedImageName,
        ),
        _selectedPark!.id,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text("ส่งรายงานปัญหาเรียบร้อยแล้ว"),
            ],
          ),
          backgroundColor: darkForest,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;
      final statusCode = e.response?.statusCode;
      final apiMessage = e.response?.data?["message"];

      String message;
      if (statusCode == 500 && apiMessage == "Failed to add report") {
        message = "เกิดข้อผิดพลาดในการบันทึก กรุณาลองใหม่";
      } else {
        message = "ไม่สามารถบันทึกรายงานได้ กรุณาลองใหม่อีกครั้ง";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFDC2626),
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
              "แจ้งรายงานปัญหา",
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section 1: อุทยานที่เกี่ยวข้อง ──────────────────────
                _buildSectionHeader(
                  icon: Icons.location_on_rounded,
                  title: "สถานที่เกิดเหตุ / อุทยาน",
                  subtitle: "ระบุอุทยานแห่งชาติที่ต้องการแจ้งเรื่องหรือพบปัญหา",
                ),
                const SizedBox(height: 10),
                _buildParkSelectorCard(),
                const SizedBox(height: 24),

                // ── Section 2: ข้อมูลรายงาน ──────────────────────────
                _buildSectionHeader(
                  icon: Icons.assignment_rounded,
                  title: "รายละเอียดปัญหา",
                  subtitle: "กรอกข้อมูลและระบุหมวดหมู่ของปัญหาให้ชัดเจน",
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
                      // หัวข้อรายงาน
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: textDark,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          label: "หัวข้อรายงาน",
                          hint: "เช่น ทางเดินไม้ชำรุด, ขยะตกค้างริมลำธาร",
                          icon: Icons.edit_note_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "กรุณากรอกหัวข้อรายงาน";
                          } else if (value.trim().length < 2 ||
                              value.trim().length > 25) {
                            return "หัวข้อต้องมีความยาว 2 - 25 ตัวอักษร";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ประเภทรายงาน
                      FormField<String>(
                        validator: (_) => _selectedReportTypeName == null
                            ? "กรุณาเลือกประเภทรายงาน"
                            : null,
                        builder: (field) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: _selectedReportTypeName,
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              menuMaxHeight: 250,
                              borderRadius: BorderRadius.circular(16),
                              style: const TextStyle(
                                fontSize: 14,
                                color: textDark,
                                fontWeight: FontWeight.w500,
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: darkForest,
                              ),
                              decoration: _buildInputDecoration(
                                label: "ประเภทรายงาน",
                                hint: "เลือกประเภทปัญหา",
                                icon: Icons.category_outlined,
                              ),
                              hint: const Text(
                                "เลือกประเภทรายงาน",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: textMuted,
                                ),
                              ),
                              items: _reportTypeNames
                                  .map(
                                    (typeName) => DropdownMenuItem<String>(
                                      value: typeName,
                                      child: Text(
                                        typeName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: textDark,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedReportTypeName = value);
                                field.didChange(value);
                              },
                            ),
                            if (_isLoadingTypes)
                              const Padding(
                                padding: EdgeInsets.only(top: 8, left: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: emeraldTint,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "กำลังโหลดประเภทรายงาน...",
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (field.hasError)
                              Padding(
                                padding: const EdgeInsets.only(left: 12, top: 6),
                                child: Text(
                                  field.errorText!,
                                  style: const TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // รายละเอียดรายงาน
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: textDark,
                        ),
                        decoration: _buildInputDecoration(
                          label: "รายละเอียดเพิ่มเติม",
                          hint:
                              "อธิบายลักษณะปัญหา พิกัด หรือจุดสังเกตโดยละเอียด...",
                          icon: Icons.notes_rounded,
                        ).copyWith(alignLabelWithHint: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "กรุณากรอกรายละเอียดปัญหา";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Section 3: แนบรูปภาพ ──────────────────────────────
                _buildSectionHeader(
                  icon: Icons.add_photo_alternate_rounded,
                  title: "ภาพถ่ายประกอบ (ถ้ามี)",
                  subtitle: "เพิ่มรูปภาพเพื่อช่วยให้เจ้าหน้าที่ตรวจสอบได้เร็วขึ้น",
                ),
                const SizedBox(height: 10),
                _buildImagePickerBox(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParkSelectorCard() {
    return FormField<Park>(
      validator: (_) => _selectedPark == null ? "กรุณาเลือกอุทยาน" : null,
      builder: (field) {
        final hasPark = _selectedPark != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _selectPark,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: field.hasError
                        ? const Color(0xFFEF4444)
                        : (hasPark ? mintBorder : Colors.grey.shade100),
                    width: hasPark ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: darkForest.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (hasPark)
                      _buildSubstringIconBadge(_selectedPark!.name)
                    else
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: mintLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: mintBorder),
                        ),
                        child: const Icon(
                          Icons.nature_people_rounded,
                          color: darkForest,
                          size: 24,
                        ),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasPark
                                ? _selectedPark!.name
                                : "เลือกอุทยานแห่งชาติ",
                            style: TextStyle(
                              color: hasPark ? textDark : textMuted,
                              fontSize: 15,
                              fontWeight:
                                  hasPark ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasPark
                                ? (_selectedPark!.address ??
                                    "แตะเพื่อเปลี่ยนอุทยาน")
                                : "แตะเพื่อค้นหาและเลือกสถานที่เกิดเหตุ",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: hasPark ? textMuted : Colors.grey.shade400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: hasPark ? mintPillBg : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hasPark ? "เปลี่ยน" : "เลือก",
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: hasPark ? darkForest : textMuted,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: hasPark ? darkForest : textMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 11.5,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImagePickerBox() {
    if (_image != null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: mintBorder),
          boxShadow: [
            BoxShadow(
              color: darkForest.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Image.file(
                _image!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => setState(() => _image = null),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: GestureDetector(
                  onTap: _showImagePickerBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_camera_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "เปลี่ยนรูป",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _showImagePickerBottomSheet,
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: darkForest.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: mintLight,
                shape: BoxShape.circle,
                border: Border.all(color: mintBorder),
              ),
              child: const Icon(
                Icons.add_a_photo_outlined,
                size: 24,
                color: darkForest,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "แนบรูปภาพปัญหาที่พบ",
              style: TextStyle(
                color: textDark,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              "แตะเพื่อถ่ายรูปด้วยกล้อง หรือเลือกจากอัลบั้ม",
              style: TextStyle(
                fontSize: 11.5,
                color: textMuted,
              ),
            ),
          ],
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

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textMuted, fontSize: 13),
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(icon, color: darkForest, size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: emeraldTint, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          onPressed: _isLoading ? null : _submitReport,
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
                    Icon(Icons.send_rounded, size: 19),
                    SizedBox(width: 8),
                    Text(
                      "ส่งรายงานปัญหา",
                      style: TextStyle(
                        fontSize: 16,
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

  Widget _buildSubstringIconBadge(String rawParkName) {
    String shortName = rawParkName.trim();
    if (shortName.startsWith("อุทยานแห่งชาติ")) {
      shortName = shortName.substring("อุทยานแห่งชาติ".length).trim();
    }
    if (shortName.isEmpty) {
      shortName = rawParkName;
    }

    final name = rawParkName;
    IconData icon;
    List<Color> gradientColors;

    if (name.contains("น้ำตก")) {
      icon = Icons.water_drop_rounded;
      gradientColors = const [Color(0xFF0284C7), Color(0xFF2563EB)];
    } else if (name.contains("เกาะ") ||
        name.contains("ทะเล") ||
        name.contains("หาด") ||
        name.contains("อ่าว") ||
        name.contains("ธารา") ||
        name.contains("หมู่เกาะ")) {
      icon = Icons.waves_rounded;
      gradientColors = const [Color(0xFF00796B), Color(0xFF009688)];
    } else if (name.contains("ดอย") ||
        name.contains("ภู") ||
        name.contains("ยอด")) {
      icon = Icons.landscape_rounded;
      gradientColors = const [Color(0xFFB45309), Color(0xFFD97706)];
    } else if (name.contains("ผา") ||
        name.contains("เขา") ||
        name.contains("หิน")) {
      icon = Icons.terrain_rounded;
      gradientColors = const [Color(0xFF475569), Color(0xFF64748B)];
    } else {
      icon = Icons.forest_rounded;
      gradientColors = const [Color(0xFF15803D), Color(0xFF065F46)];
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              shortName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 7.5,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
