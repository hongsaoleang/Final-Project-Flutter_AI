import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BookingsBoardingPassScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const BookingsBoardingPassScreen({super.key, this.onBack});

  @override
  State<BookingsBoardingPassScreen> createState() => _BookingsBoardingPassScreenState();
}

class _BookingsBoardingPassScreenState extends State<BookingsBoardingPassScreen> {
  final List<Map<String, dynamic>> _checklist = [
    {'title': 'Angkor Temple Pass (e-Pass)', 'checked': true},
    {'title': 'Lightweight Cotton/Linen Clothes (Temple Modesty)', 'checked': true},
    {'title': 'Biodegradable Eco Sunscreen & Insect Spray', 'checked': true},
    {'title': 'Reusable Stainless Water Bottle', 'checked': true},
    {'title': 'Traditional Khmer Krama Scarf', 'checked': false},
    {'title': 'Cambodian Riel & USD Cash for Local Markets', 'checked': true},
  ];

  double get _checklistProgress {
    if (_checklist.isEmpty) return 0.0;
    final done = _checklist.where((i) => i['checked'] == true).length;
    return done / _checklist.length;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (widget.onBack != null)
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.white : const Color(0xFF1C2820)),
                      onPressed: widget.onBack,
                    ),
                  const Expanded(
                    child: Text(
                      'Cambodia Travel Passes',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Travel Pass link copied to clipboard!')),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // 1. Cambodian Domestic Flight/Express Pass Card
                  _buildBoardingPass(isDark),
                  const SizedBox(height: 20),

                  // 2. Widget Cards (Live Weather & Trip Progress Ring)
                  Row(
                    children: [
                      // Weather Widget
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Weather', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '31°C',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Warm Tropical Breeze\nSiem Reap, Cambodia',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Trip Progress Widget
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Route Status', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: 0.90,
                                          strokeWidth: 4.5,
                                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                        ),
                                        const Text(
                                          '90%',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'Cambodia\nPlan Ready',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 3. Hotel & Logistics Cards in Cambodia
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Lodging & Stays in Cambodia',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '2 Confirmed',
                        style: TextStyle(fontSize: 12, color: isDark ? AppTheme.accentMint : AppTheme.primaryLight, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildHotelCard(
                    title: 'Phum Baitang Eco Retreat',
                    location: 'Svay Dangkum, Siem Reap',
                    dates: 'Oct 14 – 16, 2026 (2 Nights)',
                    badge: '🌿 Traditional Wooden Stilt Villas',
                    imageUrl: 'https://images.unsplash.com/photo-1544644181-1484b3fdfc62?auto=format&fit=crop&w=600&q=80',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 10),
                  _buildHotelCard(
                    title: 'The Plantation Urban Resort',
                    location: 'Daun Penh, Phnom Penh',
                    dates: 'Oct 12 – 14, 2026 (2 Nights)',
                    badge: '🏛️ Near Royal Palace & Museum',
                    imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=600&q=80',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 22),

                  // 4. Checklist Section (Interactive packing checklist)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cambodia Travel Checklist',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(_checklistProgress * 100).toInt()}% Done',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _checklistProgress,
                      minHeight: 6,
                      backgroundColor: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                      ),
                    ),
                    child: Column(
                      children: List.generate(_checklist.length, (index) {
                        final item = _checklist[index];
                        final isLast = index == _checklist.length - 1;
                        return Column(
                          children: [
                            CheckboxListTile(
                              value: item['checked'],
                              onChanged: (val) {
                                setState(() {
                                  _checklist[index]['checked'] = val ?? false;
                                });
                              },
                              activeColor: AppTheme.primaryColor,
                              title: Text(
                                item['title'],
                                style: TextStyle(
                                  fontSize: 13,
                                  decoration: item['checked'] ? TextDecoration.lineThrough : null,
                                  color: item['checked'] ? Colors.grey : null,
                                  fontWeight: item['checked'] ? FontWeight.normal : FontWeight.w600,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: isDark ? AppTheme.borderDark : const Color(0xFFF0F3EF),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // 5. Sticky Bottom Action Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showFullTicketModal(context, isDark);
                  },
                  icon: const Icon(Icons.qr_code_rounded, size: 20),
                  label: const Text(
                    'View Angkor Pass & Ticket',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardingPass(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Upper header section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2F24) : const Color(0xFFEFF5F0),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flight_takeoff_rounded, color: AppTheme.primaryLight, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'CAMBODIA ANGKOR AIR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: isDark ? AppTheme.accentMint : AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'DOMESTIC ECO',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Flight Codes Route: PNH to SAI (Siem Reap Angkor)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PNH', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    SizedBox(height: 2),
                    Text('Phnom Penh', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('08:30 AM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.flight_rounded, color: AppTheme.primaryLight, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      '45 mins • Direct',
                      style: TextStyle(fontSize: 10, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                    ),
                  ],
                ),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('SAI', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    SizedBox(height: 2),
                    Text('Siem Reap (Angkor)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('09:15 AM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),

          // Dashed Divider with Notches
          Row(
            children: [
              Container(
                width: 14,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final count = (constraints.constrainWidth() / 12).floor();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        count,
                        (_) => SizedBox(
                          width: 6,
                          height: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.4)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 14,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                ),
              ),
            ],
          ),

          // Flight Details & Seat Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPassDetail('FLIGHT', 'K6-102'),
                _buildPassDetail('GATE', 'G2'),
                _buildPassDetail('SEAT', '12A'),
                _buildPassDetail('TERMINAL', 'T1 Domestic'),
              ],
            ),
          ),

          // Simulated Barcode / QR Section
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17221A) : const Color(0xFFF6F8F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PASSENGER', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
                    const Text('SOKHA CHANTHOU', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('ETKT: 288-KH84739201', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, size: 36, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHotelCard({
    required String title,
    required String location,
    required String dates,
    required String badge,
    required String imageUrl,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : const Color(0xFFE5E9E4),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                width: 72,
                height: 72,
                color: AppTheme.primaryLight,
                child: const Icon(Icons.hotel, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Text(location, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(dates, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(badge, style: const TextStyle(fontSize: 10, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullTicketModal(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 18),
              const Text('Digital E-Ticket & Pass', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Cambodia Angkor Air • PNH to SAI Domestic Route', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                  ],
                ),
                child: const Icon(Icons.qr_code_2_rounded, size: 160, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Text('CODE: K6-102-PNH-SAI-12A', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Close Pass'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
