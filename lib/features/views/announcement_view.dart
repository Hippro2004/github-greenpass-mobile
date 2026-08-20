import 'package:flutter/material.dart';
import 'package:greenpass/dtos/announcement_response.dart';
import 'package:greenpass/features/services/announcement_service.dart';

class AnnouncementView extends StatefulWidget {
  const AnnouncementView({super.key});

  @override
  State<AnnouncementView> createState() => _AnnouncementViewState();
}

class _AnnouncementViewState extends State<AnnouncementView> {
  final AnnoucementService _announcementService = AnnoucementService();
  List<AnnouncementResponse> _announcements = [];
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
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await _announcementService.getAllAnnouncements();
      if (!mounted) return;
      setState(() {
        _announcements = response.result ?? [];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = "ไม่สามารถโหลดประกาศได้";
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
          "ประกาศ",
          style: TextStyle(color: forestGreen, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildError()
          : _announcements.isEmpty
          ? _buildEmpty()
          : RefreshIndicator(
              color: forestGreen,
              onRefresh: _loadAnnouncements,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _announcements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) =>
                    _buildAnnouncementCard(_announcements[index]),
              ),
            ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementResponse announcement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.campaign_outlined, color: darkGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  announcement.annoucementName,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.forest_outlined, size: 14, color: forestGreen),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  announcement.parkName,
                  style: const TextStyle(
                    color: forestGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: warmGold,
              ),
              const SizedBox(width: 4),
              Text(
                announcement.postDate,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            announcement.description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text("ยังไม่มีประกาศ", style: TextStyle(color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: _loadAnnouncements,
        icon: const Icon(Icons.refresh),
        label: const Text("ลองใหม่"),
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
