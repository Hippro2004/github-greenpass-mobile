import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslationService {
  TranslationService._internal();
  static final TranslationService instance = TranslationService._internal();

  /// ตัวแจ้งเตือนภาษาปัจจุบัน ('th' หรือ 'en')
  final ValueNotifier<String> currentLocale = ValueNotifier<String>('th');

  bool get isEnglish => currentLocale.value == 'en';

  OnDeviceTranslator? _thToEnTranslator;
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  bool _isModelReady = false;
  bool _isDownloading = false;

  /// Cache สำหรับเก็บข้อความที่เคยแปลแล้ว จะได้ไม่ต้องแปลซ้ำ
  final Map<String, String> _cache = {};

  /// พจนานุกรมคำเฉพาะเจาะจง (Instant & Accurate Proper Nouns)
  final Map<String, String> _dictionary = {
    'อุทยานแห่งชาติ': 'National Park',
    'วนอุทยาน': 'Forest Park',
    'สมุดเดินทางและบริการอุทยานแห่งชาติ':
        'Passport and National Park Services',
    'เข้าสู่ระบบ': 'Login',
    'สมัครสมาชิก': 'Register',
    'สมัครสมาชิกใหม่': 'Register New Account',
    'ชื่อผู้ใช้งาน': 'Username',
    'รหัสผ่าน': 'Password',
    'ยืนยันรหัสผ่าน': 'Confirm Password',
    'ชื่อจริง': 'First Name',
    'นามสกุล': 'Last Name',
    'อีเมล': 'Email',
    'หมายเลขโทรศัพท์': 'Phone Number',
    'วันเกิด': 'Date of Birth',
    'เพศ': 'Gender',
    'ชาย': 'Male',
    'หญิง': 'Female',
    'ชาวต่างชาติ': 'Foreigner',
    'ข้อมูลที่อยู่': 'Address Information',
    'อำเภอ/เขต': 'District',
    'ตำบล/แขวง': 'Sub-district',
    'จังหวัด': 'Province',
    'รหัสไปรษณีย์': 'Zipcode',
    'เหตุฉุกเฉิน': 'Emergency',
    'โทรฉุกเฉิน 1362': 'Emergency Call 1362',
    'สายด่วนพิทักษ์ป่า': 'Forest Protection Hotline',
    'บันทึก': 'Save',
    'ยกเลิก': 'Cancel',
    'ตกลง': 'OK',
    'ถัดไป': 'Next',
    'ย้อนกลับ': 'Back',
    'ค้นหา': 'Search',
    'ประวัติ': 'History',
    'ตราประทับ': 'Passport Stamp',
    'ของรางวัล': 'Rewards',
    'ประกาศ': 'Announcements',
    'ข่าวสาร': 'News',
    'แจ้งเตือน': 'Notifications',
    'โปรไฟล์': 'Profile',
    'แก้ไขโปรไฟล์': 'Edit Profile',
    'ออกจากระบบ': 'Logout',
  };

  /// สลับภาษา
  void switchLanguage(String langCode) {
    if (currentLocale.value != langCode) {
      currentLocale.value = langCode;
      if (langCode == 'en') {
        _prepareModel();
      }
    }
  }

  void toggleLanguage() {
    switchLanguage(isEnglish ? 'th' : 'en');
  }

  /// ดาวน์โหลดและเตรียม ML Kit Model
  Future<void> _prepareModel() async {
    if (_isModelReady || _isDownloading) return;
    try {
      _isDownloading = true;

      // ตรวจสอบโมเดลไทยและอังกฤษ
      final isThDownloaded = await _modelManager
          .isModelDownloaded(TranslateLanguage.thai.bcpCode);
      if (!isThDownloaded) {
        await _modelManager.downloadModel(TranslateLanguage.thai.bcpCode);
      }

      final isEnDownloaded = await _modelManager
          .isModelDownloaded(TranslateLanguage.english.bcpCode);
      if (!isEnDownloaded) {
        await _modelManager.downloadModel(TranslateLanguage.english.bcpCode);
      }

      _thToEnTranslator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.thai,
        targetLanguage: TranslateLanguage.english,
      );
      _isModelReady = true;
    } catch (e) {
      debugPrint('Error preparing ML Kit Translation: $e');
    } finally {
      _isDownloading = false;
    }
  }

  /// ฟังก์ชันหลักสำหรับแปลข้อความ (ใช้แปลข้อมูลจาก API)
  Future<String> translate(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || !isEnglish) {
      return text;
    }

    // 1. ตรวจสอบใน Dictionary ก่อน (แม่นยำและเร็วกว่า)
    if (_dictionary.containsKey(trimmed)) {
      return _dictionary[trimmed]!;
    }

    // 2. ตรวจสอบใน Cache
    if (_cache.containsKey(trimmed)) {
      return _cache[trimmed]!;
    }

    // 3. ถ้ายังไม่ได้โหลดโมเดล ให้เริ่มเตรียม
    if (!_isModelReady) {
      await _prepareModel();
    }

    // 4. สั่งแปลด้วย ML Kit On-Device
    if (_thToEnTranslator != null && _isModelReady) {
      try {
        final result = await _thToEnTranslator!.translateText(trimmed);
        if (result.isNotEmpty) {
          _cache[trimmed] = result;
          return result;
        }
      } catch (e) {
        debugPrint('ML Kit translation error for "$trimmed": $e');
      }
    }

    return text;
  }

  /// แปลแบบ Synchronous (ดึงจาก Cache หรือ Dictionary ถ้ามี)
  String translateSync(String text) {
    if (!isEnglish || text.isEmpty) return text;
    if (_dictionary.containsKey(text.trim())) {
      return _dictionary[text.trim()]!;
    }
    if (_cache.containsKey(text.trim())) {
      return _cache[text.trim()]!;
    }
    // หากยังไม่มีใน cache ให้ส่งคำเดิมไปก่อน แล้วทริกเกอร์แปลเบื้องหลัง
    translate(text);
    return text;
  }

  /// คืนทรัพยากร
  void dispose() {
    _thToEnTranslator?.close();
  }
}
