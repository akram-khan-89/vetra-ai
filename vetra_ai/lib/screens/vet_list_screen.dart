import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'whatsapp_preview_screen.dart';
import 'pricing_screen.dart';

class VetListScreen extends StatefulWidget {
  final Map<String, dynamic> diagnosisResult;

  const VetListScreen({super.key, required this.diagnosisResult});

  @override
  State<VetListScreen> createState() => _VetListScreenState();
}

class _VetListScreenState extends State<VetListScreen> {
  bool _isLoadingLocation = true;
  bool _isLoading = false;
  bool _locationSelected = false;
  String? _selectedCity;
  String? _selectedArea;
  String? _errorMessage;
  Map<String, dynamic>? _decisionResult;
  final ApiService _apiService = ApiService();

  Map<String, List<String>> _cityAreas = {};
  Map<String, Map<String, List<double>>> _areaCoordinates = {};

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      final vets = await _apiService.getAllVets();
      
      Map<String, List<String>> tempCityAreas = {};
      Map<String, Map<String, List<double>>> tempCoordinates = {};

      for (var vet in vets) {
        final loc = vet['location'];
        if (loc != null) {
          final city = loc['city'] as String?;
          final area = loc['area'] as String?;
          final lat = (loc['lat'] as num?)?.toDouble();
          final lng = (loc['lng'] as num?)?.toDouble();

          if (city != null && area != null && lat != null && lng != null) {
            if (!tempCityAreas.containsKey(city)) {
              tempCityAreas[city] = [];
            }
            if (!tempCityAreas[city]!.contains(area)) {
              tempCityAreas[city]!.add(area);
            }

            if (!tempCoordinates.containsKey(city)) {
              tempCoordinates[city] = {};
            }
            tempCoordinates[city]![area] = [lat, lng];
          }
        }
      }

      setState(() {
        _cityAreas = tempCityAreas;
        _areaCoordinates = tempCoordinates;
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load locations: $e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadVetsAndDecide(double lat, double lng) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final diagnosis = widget.diagnosisResult['diagnosis'] ?? widget.diagnosisResult;
      
      // Extract parameters safely
      final specialty = diagnosis['required_specialization'] ?? 'general';
      final urgency = diagnosis['urgency'] ?? 'routine';
      final complexity = diagnosis['complexity_level'] ?? 1;

      // 1. Fetch nearby vets
      final nearbyVetsResponse = await _apiService.getNearbyVets(
        lat,
        lng,
        specialty,
        urgency,
        complexity,
      );

      final vets = nearbyVetsResponse['data'] as List<dynamic>? ?? [];

      // 2. Call decide route
      final decideResponse = await _apiService.postDecide(
        vets,
        diagnosis,
        urgency,
      );

      setState(() {
        _decisionResult = decideResponse['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
      }
    }

    return Row(children: stars);
  }

  Widget _buildVetCard({
    required Map<String, dynamic> vet,
    required bool isRecommended,
    required Map<String, dynamic> diagnosis,
  }) {
    final name = vet['name'] ?? 'Unknown Vet';
    final distance = (vet['distance_km'] as num?)?.toStringAsFixed(1) ?? 'N/A';
    final rating = (vet['overall_rating'] as num?)?.toDouble() ?? 0.0;
    final specialties = vet['specialties'] as List<dynamic>? ?? [];
    final score = (vet['total_score'] as num?)?.toStringAsFixed(0) ?? 'N/A';
    final fee = vet['base_visit_fee_rs'] ?? 'N/A';

    return Card(
      elevation: isRecommended ? 6 : 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRecommended
            ? const BorderSide(color: Color(0xFF0F6E56), width: 2.5)
            : BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF0F6E56),
                borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تجویز کردہ', // Recommended in Urdu
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'RECOMMENDED',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: isRecommended ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildStars(rating),
                              const SizedBox(width: 8),
                              Text(
                                  rating.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isRecommended ? const Color(0xFF0F6E56).withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'SCORE',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          Text(
                            '$score/100',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isRecommended ? const Color(0xFF0F6E56) : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$distance km away'),
                    const SizedBox(width: 16),
                    const Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Rs. $fee'),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: specialties
                      .map((spec) => Chip(
                            label: Text(
                              spec.toString(),
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.grey.shade100,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WhatsAppPreviewScreen(
                                vet: vet,
                                diagnosis: diagnosis,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble, size: 16),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Calling $name at ${vet['phone']}...')),
                          );
                        },
                        icon: const Icon(Icons.phone, size: 16),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PricingScreen(
                                vet: vet,
                                diagnosis: diagnosis,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0F6E56),
                          side: const BorderSide(color: Color(0xFF0F6E56)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Select'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelection() {
    final cities = _cityAreas.keys.toList();
    final areas = _selectedCity != null ? _cityAreas[_selectedCity!] ?? [] : [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.location_on,
            size: 80,
            color: Color(0xFF0F6E56),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Location\nمقام منتخب کریں',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'To connect you with the nearest veterinarian, please select your city and area.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // City Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                hint: const Text('Select City / شہر منتخب کریں'),
                isExpanded: true,
                items: cities.map((city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCity = val;
                    _selectedArea = null; // Reset area
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Area Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: _selectedCity == null ? Colors.grey.shade100 : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedArea,
                hint: Text(
                  _selectedCity == null
                      ? 'Select City First'
                      : 'Select Area / علاقہ منتخب کریں',
                  style: TextStyle(
                    color: _selectedCity == null ? Colors.grey : Colors.black87,
                  ),
                ),
                isExpanded: true,
                items: areas.map((area) {
                  return DropdownMenuItem<String>(
                    value: area,
                    child: Text(area),
                  );
                }).toList(),
                onChanged: _selectedCity == null
                    ? null
                    : (val) {
                        setState(() {
                          _selectedArea = val;
                        });
                      },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Find Button
          ElevatedButton(
            onPressed: (_selectedCity == null || _selectedArea == null)
                ? null
                : () {
                    final coords = _areaCoordinates[_selectedCity!]?[_selectedArea!];
                    if (coords != null && coords.length == 2) {
                      setState(() {
                        _locationSelected = true;
                      });
                      _loadVetsAndDecide(coords[0], coords[1]);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F6E56),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Find Nearby Vets / قریبی ڈاکٹر تلاش کریں',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> diagnosis) {
    if (_decisionResult == null) {
      return const Center(child: Text('No decision data available'));
    }

    final topVet = _decisionResult!['top_vet'] as Map<String, dynamic>?;
    final alternatives = _decisionResult!['alternatives'] as List<dynamic>? ?? [];
    final overrideHappened = _decisionResult!['override_happened'] == true;
    final overrideReason = _decisionResult!['override_reason'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F6E56).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0F6E56).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location, color: Color(0xFF0F6E56), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location: $_selectedArea, $_selectedCity',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F6E56),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _locationSelected = false;
                      _decisionResult = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF0F6E56),
                  ),
                  child: const Text(
                    'Change / تبدیل کریں',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (topVet != null) ...[
            _buildVetCard(
              vet: topVet,
              isRecommended: true,
              diagnosis: diagnosis,
            ),
            const SizedBox(height: 8),
          ],
          if (overrideHappened && overrideReason.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'More reliable than closer vet — $overrideReason',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (alternatives.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Alternative Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...alternatives.map((altVet) => _buildVetCard(
                  vet: altVet as Map<String, dynamic>,
                  isRecommended: false,
                  diagnosis: diagnosis,
                )),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final diagnosis = widget.diagnosisResult['diagnosis'] ?? widget.diagnosisResult;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        title: const Text('Find a Vet'),
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
      ),
      body: _isLoadingLocation
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F6E56)),
                  ),
                  SizedBox(height: 16),
                  Text('Loading location data...'),
                ],
              ),
            )
          : !_locationSelected
              ? _buildLocationSelection()
              : _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F6E56)),
                          ),
                          SizedBox(height: 16),
                          Text('Matching best veterinarian...'),
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
                                onPressed: () {
                                  final coords = _areaCoordinates[_selectedCity!]?[_selectedArea!];
                                  if (coords != null && coords.length == 2) {
                                    _loadVetsAndDecide(coords[0], coords[1]);
                                  } else {
                                    _loadLocationData();
                                  }
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _buildContent(diagnosis),
    );
  }
}
