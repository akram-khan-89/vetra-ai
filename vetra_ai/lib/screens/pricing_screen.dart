import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/stitch_theme.dart';
import 'whatsapp_preview_screen.dart';

class PricingScreen extends StatefulWidget {
  final Map<String, dynamic> vet;
  final Map<String, dynamic> diagnosis;

  const PricingScreen({
    super.key,
    required this.vet,
    required this.diagnosis,
  });

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _pricingData;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchPricing();
  }

  Future<void> _fetchPricing() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final diagnosis = widget.diagnosis['diagnosis'] ?? widget.diagnosis;
      final vetId = widget.vet['vet_id'] ?? '';
      final urgency = diagnosis['urgency'] ?? 'routine';
      final complexityLevel = diagnosis['complexity_level'] ?? 1;

      final response = await _apiService.getPricing(
        vetId: vetId,
        urgency: urgency,
        complexityLevel: complexityLevel,
        farmerTotalBookings: 5,
        budgetSensitive: false,
      );

      setState(() {
        _pricingData = response['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildItemRow(String label, String value, {bool isDiscount = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: StitchColors.onBackground,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isDiscount
                  ? StitchColors.error
                  : (isBold ? StitchColors.primary : StitchColors.onBackground),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.background,
      appBar: AppBar(
        title: const Text('Pricing Details / فیس کی تفصیلات'),
        backgroundColor: StitchColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(StitchColors.primary),
                  ),
                  SizedBox(height: 16),
                  Text('Calculating visit fee... / فیس کا حساب لگایا جا رہا ہے...', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: StitchColors.error),
                      const SizedBox(height: 16),
                      Text('Error: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPricing,
                        style: ElevatedButton.styleFrom(backgroundColor: StitchColors.primary),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_pricingData == null) {
      return const Center(child: Text('No pricing details available.'));
    }

    final baseFee = (_pricingData!['base_fee'] ?? 0).toInt();
    final travelFee = (_pricingData!['travel_fee'] ?? 0).toInt();
    final urgencyFee = (_pricingData!['urgency_fee'] ?? 0).toInt();
    final complexityFee = (_pricingData!['complexity_fee'] ?? 0).toInt();
    final nightFee = (_pricingData!['night_fee'] ?? 0).toInt();
    final discount = (_pricingData!['loyalty_discount_rs'] ?? 0).toInt();
    final total = (_pricingData!['total_rs'] ?? 0).toInt();
    final budgetAlt = _pricingData!['budget_alternative'] as Map<String, dynamic>?;

    final distance = (widget.vet['distance_km'] as num?)?.toDouble() ?? 8.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vet header info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: StitchColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StitchColors.primary.withOpacity(0.15), width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 36, color: StitchColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.vet['name'] ?? 'Unknown Vet',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StitchColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(widget.vet['specialties'] as List<dynamic>?)?.join(", ") ?? "General"} Specialty',
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Breakdown Card
          const Text(
            'Visit Fee Breakdown / فیس کی تفصیل',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StitchColors.onBackground),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StitchColors.surfaceContainerHigh, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.015),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildItemRow('Base visit fee', 'Rs $baseFee'),
                _buildItemRow('Travel (${distance.toStringAsFixed(1)}km × Rs 30)', 'Rs $travelFee'),
                if (urgencyFee > 0) _buildItemRow('Urgency surcharge', 'Rs $urgencyFee'),
                if (complexityFee > 0) _buildItemRow('Complexity fee', 'Rs $complexityFee'),
                if (nightFee > 0) _buildItemRow('Night surcharge', 'Rs $nightFee'),
                if (discount > 0) _buildItemRow('Loyalty discount (10%)', '− Rs $discount', isDiscount: true),
                const Divider(height: 28, thickness: 1.5),
                _buildItemRow('Total / کل فیس', 'Rs $total', isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Budget alternative alert
          if (budgetAlt != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade300, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber.shade800),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Option Available / سستا متبادل',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cheaper option: ${budgetAlt['name'] ?? 'Alternative Vet'} → Rs ${budgetAlt['base_visit_fee_rs'] ?? 0}',
                          style: TextStyle(color: Colors.amber.shade900, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 16),

          // "Book This Vet" large green button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WhatsAppPreviewScreen(
                      vet: widget.vet,
                      diagnosis: widget.diagnosis,
                      pricing: _pricingData!,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: StitchColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Book This Vet / ڈاکٹر بک کریں',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
