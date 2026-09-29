import 'package:flutter/material.dart';
import 'package:greenpass/core/services/translation_service.dart';

/// Widget ข้อความที่แปลภาษาอังกฤษอัตโนมัติเมื่อเลือกภาษาอังกฤษ (แปลทั้งจาก API และข้อความในเครื่อง)
class AutoTranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AutoTranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.instance.currentLocale,
      builder: (context, langCode, _) {
        if (langCode == 'th' || text.trim().isEmpty) {
          return Text(
            text,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        }

        // ลองดึงจาก Sync (Dictionary หรือ Cache)
        final syncResult = TranslationService.instance.translateSync(text);
        if (syncResult != text) {
          return Text(
            syncResult,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        }

        // ถ้ายังไม่มีใน Cache ให้เรียก FutureBuilder แปลสด
        return FutureBuilder<String>(
          future: TranslationService.instance.translate(text),
          initialData: text,
          builder: (context, snapshot) {
            final displayText = snapshot.data ?? text;
            return Text(
              displayText,
              style: style,
              textAlign: textAlign,
              maxLines: maxLines,
              overflow: overflow,
            );
          },
        );
      },
    );
  }
}

/// ปุ่มสลับภาษา (TH / EN) สวยงามแบบ Modern Pill
class LanguageSwitchButton extends StatelessWidget {
  final Color? activeColor;
  final Color? backgroundColor;

  const LanguageSwitchButton({
    super.key,
    this.activeColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: TranslationService.instance.currentLocale,
      builder: (context, currentLang, _) {
        final isEn = currentLang == 'en';
        return GestureDetector(
          onTap: () => TranslationService.instance.toggleLanguage(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0xFFE8F7F0),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: activeColor?.withValues(alpha: 0.3) ??
                    const Color(0xFFD6EFE2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.language_rounded,
                  size: 16,
                  color: activeColor ?? const Color(0xFF064E3B),
                ),
                const SizedBox(width: 5),
                Text(
                  isEn ? 'EN' : 'TH',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: activeColor ?? const Color(0xFF064E3B),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
