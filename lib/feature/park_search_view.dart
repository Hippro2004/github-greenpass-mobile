import 'package:flutter/material.dart';
import 'package:greenpass/data/models/park.dart';
import 'package:greenpass/data/services/park_service.dart';
import 'package:greenpass/feature/park_detail_view.dart';

class ParkSearchView extends StatefulWidget {
  const ParkSearchView({super.key});

  @override
  State<ParkSearchView> createState() => _ParkSearchViewState();
}

class _ParkSearchViewState extends State<ParkSearchView> {
  final ParkService _parkService = ParkService();
  final TextEditingController _searchController = TextEditingController();

  List<Park> _allParks = [];
  List<Park> _filteredParks = [];
  bool _isLoading = false;

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color creamBg = Color(0xFFF8F5F0);

  @override
  void initState() {
    super.initState();
    _loadAllParks();
    _searchController.addListener(_filterParks);
  }

  void _filterParks() {
    final keyword = _searchController.text.toLowerCase();
    setState(() {
      _filteredParks = _allParks
          .where((park) => park.name.toLowerCase().contains(keyword))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterParks);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllParks() async {
    setState(() => _isLoading = true);
    try {
      final parks = await _parkService.searchParks('');
      if (!mounted) return;
      setState(() {
        _allParks = parks;
        _filteredParks = parks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
          "ค้นหาอุทยาน",
          style: TextStyle(color: forestGreen, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "ค้นหาชื่ออุทยาน...",
                hintStyle: const TextStyle(color: Colors.black38),
                prefixIcon: const Icon(Icons.search, color: forestGreen),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black38),
                        onPressed: () => _searchController.clear(),
                      )
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
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(forestGreen),
                    ),
                  )
                : _filteredParks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.forest,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "ไม่พบอุทยานที่ค้นหา",
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: _filteredParks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final park = _filteredParks[index];
                      return _buildParkCard(park);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkCard(Park park) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ParkDetailView(park: park)),
      ),
      child: Container(
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: EdgeInsets.only(left: 8),
                child: park.image != null
                    ? Image.asset(
                        'assets/images/${park.image}',
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      park.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (park.address != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              park.address!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: lightGreen.withOpacity(0.2),
      child: Center(child: Icon(Icons.forest, color: forestGreen, size: 32)),
    );
  }
}
