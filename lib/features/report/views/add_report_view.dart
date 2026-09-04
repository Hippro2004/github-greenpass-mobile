import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:greenpass/features/report/dtos/add_report_request.dart';
import 'package:greenpass/features/report/dtos/report_type_request.dart';
import 'package:greenpass/features/park/models/park.dart';
import 'package:greenpass/features/report/services/report_service.dart';
import 'package:greenpass/features/park/views/park_search_view.dart';
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
  List<ReporyTypeRequest> _reportTypes = [];
  List<String> _reportTypeNames = [];
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color creamBg = Color(0xFFF8F5F0);

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

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
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
      final response = await reportTypeService.getAllReportType();
      if (!mounted) return;

      if (response.success && response.result != null) {
        final rawTypes = response.result!
            .where((type) => type.typename.trim().isNotEmpty)
            .toList();

        final uniqueTypes = <ReporyTypeRequest>[];
        final uniqueNames = <String>[];
        for (final type in rawTypes) {
          if (!uniqueNames.contains(type.typename)) {
            uniqueNames.add(type.typename);
            uniqueTypes.add(type);
          }
        }

        if (uniqueNames.isNotEmpty) {
          setState(() {
            _reportTypes = uniqueTypes;
            _reportTypeNames = uniqueNames;
            _selectedReportTypeName = uniqueNames.first;
          });
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reportTypes = [];
        _reportTypeNames = [];
        _selectedReportTypeName = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingTypes = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black45),
      prefixIcon: Icon(icon, color: forestGreen, size: 20),
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
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceMaterialTransparency: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: forestGreen),
        ),
        title: const Text(
          "เพิ่มรายงาน",
          style: TextStyle(color: forestGreen, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ชื่อรายงาน
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  "ชื่อรายงาน",
                  Icons.title_outlined,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณากรอกชื่อรายงาน";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // อัพโหลดรูป
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            _image!,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_outlined,
                              size: 40,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "อัพโหลดรูปภาพ",
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "แตะเพื่อเลือกรูป",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              FormField<String>(
                validator: (_) => _selectedReportTypeName == null
                    ? "กรุณาเลือกประเภทรายงาน"
                    : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedReportTypeName,
                      isExpanded: true,
                      decoration:
                          _inputDecoration(
                            "ประเภทรายงาน",
                            Icons.category_outlined,
                          ).copyWith(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                      hint: const Text(
                        "เลือกประเภทรายงาน",
                        style: TextStyle(fontSize: 14),
                      ),
                      dropdownColor: Colors.white,
                      menuMaxHeight: 220,
                      borderRadius: BorderRadius.circular(14),
                      items: _reportTypeNames
                          .map(
                            (typeName) => DropdownMenuItem<String>(
                              value: typeName,
                              child: Text(
                                typeName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedReportTypeName = value);
                      },
                    ),
                    if (_isLoadingTypes)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 6),
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
              const SizedBox(height: 16),

              // อุทยานที่เกี่ยวข้อง
              FormField<Park>(
                validator: (_) =>
                    _selectedPark == null ? "กรุณาเลือกอุทยาน" : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _selectPark,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: field.hasError
                                ? Colors.red
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: forestGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.forest_outlined,
                                color: forestGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedPark?.name ?? "เลือกอุทยาน",
                                    style: TextStyle(
                                      color: _selectedPark == null
                                          ? Colors.black45
                                          : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedPark == null
                                        ? "ระบุสถานที่ของรายงานนี้"
                                        : (_selectedPark!.address ??
                                              "แตะเพื่อเปลี่ยนอุทยาน"),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: forestGreen),
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
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // รายละเอียด
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: _inputDecoration(
                  "รายละเอียด",
                  Icons.description_outlined,
                ).copyWith(alignLabelWithHint: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "กรุณากรอกรายละเอียด";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_isLoading) return;
                    if (!_formKey.currentState!.validate()) return;
                    try {
                      setState(() => _isLoading = true);
                      final response = await reportSerivce.addReport(
                        AddReportRequest(
                          name: _nameController.text,
                          description: _descriptionController.text,
                          parkId: _selectedPark!.id,
                          typeName: _selectedReportTypeName ?? '',
                          reportType: _selectedReportTypeName,
                        ),
                        _selectedPark!.id,
                      );
                      if (!mounted) return;
                      if (response.success) {
                        Navigator.pop(context, true);
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } on DioException catch (e) {
                      if (!mounted) return;
                      final statusCode = e.response?.statusCode;
                      final apiMessage = e.response?.data["message"];

                      String message;

                      if (statusCode == 500 &&
                          apiMessage == "Failed to add report") {
                        message = "เกิดข้อผิดพลาด กรุณาลองใหม่";
                      } else {
                        message = "ไม่สามารถบันทึกรายงานได้ กรุณาลองใหม่";
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
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
                  icon: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isLoading ? "กำลังบันทึก..." : "บันทึกรายงาน",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
