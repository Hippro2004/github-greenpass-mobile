import 'package:flutter/material.dart';
import 'package:greenpass/features/park/models/park.dart';

class ParkDetailView extends StatelessWidget {
  final Park park;

  const ParkDetailView({super.key, required this.park});

  static const Color forestGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF74C69D);
  static const Color creamBg = Color(0xFFF8F5F0);
  static const Color cardGreen = Color(0xFFE8F5EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: forestGreen,
            forceMaterialTransparency: false,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back, color: forestGreen),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                park.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              // background: park.image != null
              //     ? Image.asset(
              //         'assets/images/${park.image}',
              //         fit: BoxFit.cover,
              //         errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              //       )
              //     : _buildImagePlaceholder(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: park.image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildParkImage(park.image!),
                                )
                              : const Icon(
                                  Icons.forest,
                                  color: forestGreen,
                                  size: 32,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                park.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (park.location != null)
                                Text(
                                  park.location!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoSection(
                    icon: Icons.location_on_outlined,
                    title: "ข้อมูลที่อยู่อุทยาน",
                    content: park.address ?? "-",
                  ),
                  const SizedBox(height: 12),

                  _buildTimeSection(),
                  const SizedBox(height: 12),

                  _buildInfoSection(
                    icon: Icons.event_outlined,
                    title: "งานอีเว้นประจำฤดูกาล",
                    content: park.eventNote ?? "-",
                  ),
                  const SizedBox(height: 12),

                  if (park.description != null)
                    _buildInfoSection(
                      icon: Icons.info_outline,
                      title: "เกี่ยวกับอุทยาน",
                      content: park.description!,
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: forestGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(
              content,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkImage(String image) {
    final isNetworkImage =
        image.startsWith('http://') || image.startsWith('https://');

    final placeholder = Container(
      color: cardGreen,
      child: const Center(
        child: Icon(Icons.forest, color: forestGreen, size: 32),
      ),
    );

    return isNetworkImage
        ? Image.network(
            image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder,
          )
        : Image.asset(
            'assets/images/$image',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder,
          );
  }

  Widget _buildTimeSection() {
    // เช็ค status
    Color statusColor;
    String statusText;

    if (park.isTemporaryClosed == true) {
      statusColor = Colors.red;
      statusText = "ปิดชั่วคราว";
    } else if (park.isSeasonalPark == true) {
      statusColor = Colors.orange;
      statusText = "เปิดตามฤดูกาล";
    } else {
      statusColor = Colors.green;
      statusText = "เปิดทำการ";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: forestGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "เวลาเปิด - ปิดทำการ",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // เวลาเปิด-ปิดปกติ
                _buildTimeRow(
                  park.isSeasonalPark == true
                      ? "เปิดทุกวันในช่วงเทศกาล"
                      : "เปิดทุกวัน",
                  "${park.openTime ?? '-'} - ${park.closeTime ?? '-'}",
                ),

                if (park.isSeasonalPark == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ช่วงเวลาเปิดตามฤดูกาล",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${park.seasonOpenDate ?? '-'} ถึง ${park.seasonCloseDate ?? '-'}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (park.isTemporaryClosed == true &&
                    park.eventNote != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.red,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            park.eventNote!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              time,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
