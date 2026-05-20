import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'whatsapp_preview_screen.dart';
import 'pricing_screen.dart';

class AllVetsScreen extends StatefulWidget {
  const AllVetsScreen({super.key});

  @override
  State<AllVetsScreen> createState() => _AllVetsScreenState();
}

class _AllVetsScreenState extends State<AllVetsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _allVets = [];
  List<dynamic> _filteredVets = [];
  
  String _selectedProvince = 'All';
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryColor = Color(0xFF0F6E56);

  @override
  void initState() {
    super.initState();
    _fetchVets();
    _searchController.addListener(_filterVets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final vets = await _apiService.getAllVets();
      setState(() {
        _allVets = vets;
        _filteredVets = vets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getProvince(String city) {
    final c = city.toLowerCase();
    if (c.contains('lahore') || c.contains('multan') || c.contains('chunian') || c.contains('manga') || c.contains('raiwind')) {
      return 'Punjab';
    } else if (c.contains('karachi') || c.contains('malir') || c.contains('saddar')) {
      return 'Sindh';
    } else if (c.contains('islamabad')) {
      return 'Islamabad';
    } else if (c.contains('peshawar')) {
      return 'KP';
    } else {
      return 'Other';
    }
  }

  void _filterVets() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredVets = _allVets.where((vet) {
        // Province Filter
        final province = _getProvince(vet['location']?['city'] ?? '');
        final matchesProvince = _selectedProvince == 'All' || province == _selectedProvince;

        if (!matchesProvince) return false;

        // Search Query Filter
        if (query.isEmpty) return true;

        final name = (vet['name'] ?? '').toString().toLowerCase();
        final city = (vet['location']?['city'] ?? '').toString().toLowerCase();
        final area = (vet['location']?['area'] ?? '').toString().toLowerCase();
        final specialties = (vet['specialties'] as List<dynamic>? ?? []).map((s) => s.toString().toLowerCase()).join(' ');

        return name.contains(query) || city.contains(query) || area.contains(query) || specialties.contains(query);
      }).toList();
    });
  }

  void _onProvinceSelected(String province) {
    setState(() {
      _selectedProvince = province;
    });
    _filterVets();
  }

  Widget _buildStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(const Icon(Icons.star, color: Colors.amber, size: 16));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 16));
      } else {
        stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 16));
      }
    }

    return Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        title: const Text('Find a Vet / ڈاکٹر تلاش کریں'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: primaryColor,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Name, City, Specialty... / تلاش کریں',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: primaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Province Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'All / تمام'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Punjab', 'Punjab / پنجاب'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Islamabad', 'Islamabad / اسلام آباد'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Sindh', 'Sindh / سندھ'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main content area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(_errorMessage!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchVets,
                                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                                child: const Text('Retry / دوبارہ کوشش کریں'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _filteredVets.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                const Text(
                                  'No Vets Found / کوئی ڈاکٹر نہیں ملا',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredVets.length,
                            itemBuilder: (context, index) {
                              final vet = _filteredVets[index];
                              final name = vet['name'] ?? 'Unknown Vet';
                              final rating = (vet['overall_rating'] as num?)?.toDouble() ?? 0.0;
                              final fee = vet['base_visit_fee_rs'] ?? 'N/A';
                              final city = vet['location']?['city'] ?? 'N/A';
                              final area = vet['location']?['area'] ?? 'N/A';
                              final specialties = vet['specialties'] as List<dynamic>? ?? [];
                              final isAvailable = vet['available_now'] == true;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: const Color(0xFFE8F5E9),
                                            radius: 28,
                                            child: Icon(
                                              Icons.person,
                                              size: 32,
                                              color: isAvailable ? primaryColor : Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: isAvailable ? const Color(0xFFE8F5E9) : Colors.red.shade50,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text(
                                                        isAvailable ? 'Available' : 'Busy',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                          color: isAvailable ? primaryColor : Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    _buildStars(rating),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      rating.toString(),
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$area, $city',
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                          ),
                                          const Spacer(),
                                          const Icon(Icons.payments_outlined, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Rs $fee',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 4,
                                        children: specialties
                                            .map((spec) => Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    spec.toString(),
                                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                                  ),
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
                                                      diagnosis: const {
                                                        'disease_name': 'General Consultation / عام معائنہ',
                                                        'urgency': 'routine',
                                                        'complexity_level': 1,
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.chat, size: 16),
                                              label: const Text('WhatsApp'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                                      diagnosis: const {
                                                        'disease_name': 'General Consultation / عام معائنہ',
                                                        'urgency': 'routine',
                                                        'complexity_level': 1,
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: primaryColor,
                                                side: const BorderSide(color: primaryColor),
                                                padding: const EdgeInsets.symmetric(vertical: 10),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              child: const Text('Select'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedProvince == value;
    return GestureDetector(
      onTap: () => _onProvinceSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
