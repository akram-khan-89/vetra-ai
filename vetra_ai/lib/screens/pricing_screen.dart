import 'package:flutter/material.dart';
import '../services/api_service.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : (isBold ? const Color(0xFF0F6E56) : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pricing Details'),
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F6E56)),
                  ),
                  SizedBox(height: 16),
                  Text('Calculating visit fee breakdown...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPricing,
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vet header info
          Card(
            color: const Color(0xFF0F6E56).withValues(alpha: 0.05),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: const Color(0xFF0F6E56).withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 40, color: Color(0xFF0F6E56)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vet['name'] ?? 'Unknown Vet',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(widget.vet['specialties'] as List<dynamic>?)?.join(", ") ?? "General"} Specialty',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Breakdown Card
          const Text(
            'Visit Fee Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildItemRow('Base visit fee', 'Rs $baseFee'),
                  _buildItemRow('Travel (${distance.toStringAsFixed(1)}km × Rs 30)', 'Rs $travelFee'),
                  if (urgencyFee > 0) _buildItemRow('Urgency surcharge', 'Rs $urgencyFee'),
                  if (complexityFee > 0) _buildItemRow('Complexity fee', 'Rs $complexityFee'),
                  if (nightFee > 0) _buildItemRow('Night surcharge', 'Rs $nightFee'),
                  if (discount > 0) _buildItemRow('Loyalty discount (10%)', '− Rs $discount', isDiscount: true),
                  const Divider(height: 24, thickness: 1.5),
                  _buildItemRow('Total', 'Rs $total', isBold: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Budget alternative alert
          if (budgetAlt != null) ...[
            Card(
              color: Colors.amber.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.amber.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                            'Budget Option Available',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Budget option: ${budgetAlt['name'] ?? 'Cheaper Vet'} → Rs ${budgetAlt['base_visit_fee_rs'] ?? 0}',
                            style: TextStyle(color: Colors.amber.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          const SizedBox(height: 32),

          // "Book This Vet" large green button
          SizedBox(
            width: double.infinity,
            height: 50,
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
                backgroundColor: const Color(0xFF0F6E56),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Book This Vet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

