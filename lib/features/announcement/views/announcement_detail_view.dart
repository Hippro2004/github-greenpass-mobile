import 'package:flutter/material.dart';
import 'package:greenpass/core/network/dio_client.dart';
import 'package:greenpass/features/announcement/dtos/announcement_response.dart';
import 'package:greenpass/features/announcement/services/announcement_service.dart';

class AnnouncementDetailView extends StatefulWidget {
  final int announcementId;

  const AnnouncementDetailView({super.key, required this.announcementId});

  @override
  State<AnnouncementDetailView> createState() => _AnnouncementDetailViewState();
}

class _AnnouncementDetailViewState extends State<AnnouncementDetailView> {
  final AnnoucementService _announcementService = AnnoucementService();
  AnnouncementResponse? _announcement;
  bool _isLoading = true;
  String? _error;

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color darkGreen = Color(0xFF1B4332);
  static const Color lightGreen = Color(0xFFD8F3DC);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color warmGold = Color(0xFFB7791F);

  @override
  void initState() {
    super.initState();
    _loadAnnouncement();
  }

  Future<void> _loadAnnouncement() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final announcement = await _announcementService.getAnnouncementDetails(
        widget.announcementId,
      );
      if (!mounted) return;
      setState(() {
        _announcement = announcement;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = "ไม่สามารถโหลดรายละเอียดประกาศได้\n$error";
        _isLoading = false;
      });
    }
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
          "รายละเอียดประกาศ",
          style: TextStyle(color: forestGreen, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _buildContent(_announcement!),
    );
  }

  Widget _buildContent(AnnouncementResponse announcement) {
    final imageUrl = _resolveImageUrl(announcement.image);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 190,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(height: 18),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.campaign_outlined, color: darkGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    announcement.parkName,
                    style: const TextStyle(
                      color: forestGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              announcement.announcementTitle,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: warmGold,
                ),
                const SizedBox(width: 6),
                Text(
                  announcement.postDate,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 28),
            Text(
              announcement.description.trim().isNotEmpty
                  ? announcement.description
                  : "ไม่มีรายละเอียดเพิ่มเติม",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveImageUrl(String image) {
    final value = image.trim();
    if (value.isEmpty) return '';

    final parsed = Uri.tryParse(value);
    if (parsed != null && parsed.hasScheme) return value;

    final apiUri = Uri.parse(DioClient.dio.options.baseUrl);
    final origin = '${apiUri.scheme}://${apiUri.authority}';
    final normalized = value
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'^api/v1/+'), '')
        .replaceFirst(RegExp(r'^uploads/+'), 'uploads/')
        .replaceFirst(RegExp(r'^announcements/+'), 'announcements/');

    if (normalized.startsWith('uploads/')) {
      return '$origin/$normalized';
    }
    if (normalized.startsWith('images/')) {
      return '$origin/$normalized';
    }
    if (normalized.startsWith('announcements/')) {
      return '$origin/uploads/$normalized';
    }
    if (normalized.startsWith('files/')) {
      return '$origin/$normalized';
    }

    return '$origin/uploads/$normalized';
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 190,
      color: lightGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: darkGreen,
        size: 42,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 44),
            const SizedBox(height: 12),
            Text(
              _error ?? "ไม่สามารถโหลดรายละเอียดประกาศได้",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAnnouncement,
              icon: const Icon(Icons.refresh),
              label: const Text("ลองใหม่"),
              style: ElevatedButton.styleFrom(
                backgroundColor: forestGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
