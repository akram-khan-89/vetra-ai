import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'vet_list_screen.dart';

class DiagnosisScreen extends StatefulWidget {
  final Map<String, dynamic> listenResult;

  const DiagnosisScreen({super.key, required this.listenResult});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _diagnosisResult;
  String? _errorMessage;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchDiagnosis();
  }

  void _fetchDiagnosis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Assuming listenResult has 'data' containing 'symptoms' and 'animal_type', or 'vision_findings' directly
      final data = widget.listenResult['data'] ?? {};
      final visionFindingsRaw = widget.listenResult['vision_findings'] ?? data['vision_findings'] ?? [];
      
      List<String> visionFindings = [];
      if (visionFindingsRaw is List) {
        visionFindings = visionFindingsRaw.map((e) => e.toString()).toList();
      }

      final symptomsData = data['symptoms'];
      List<String> symptoms = [];
      if (symptomsData is List) {
        symptoms = symptomsData.map((e) => e.toString()).toList();
      } else if (symptomsData is String) {
        symptoms = symptomsData.split(',').map((e) => e.trim()).toList();
      }

      // Merge vision findings into symptoms so backend doesn't crash on empty symptoms
      for (var f in visionFindings) {
        if (!symptoms.contains(f)) {
          symptoms.add(f);
        }
      }

      if (symptoms.isEmpty) {
        symptoms.add('Abnormal appearance (from photo)');
      }

      final animalType = data['animal_type'] ?? 'unknown';

      final result = await _apiService.postDiagnose(symptoms, animalType, visionFindings);
      setState(() {
        _diagnosisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getRiskColor(int score) {
    if (score >= 7) return Colors.red;
    if (score >= 4) return Colors.orange;
    return Colors.green;
  }

  String _getUrgencyText(String? urgency) {
    if (urgency == null) return '';
    if (urgency.toLowerCase().contains('urgent')) {
      return 'ابھی ضروری'; // Urgent Now
    }
    if (urgency.toLowerCase().contains('today')) {
      return 'آج'; // Today
    }
    return urgency;
  }

  bool _showUrduHomeCare = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Result'),
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
                  Text('Analyzing symptoms...'),
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
                        onPressed: _fetchDiagnosis,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _diagnosisResult == null
                  ? const Center(child: Text('No data available'))
                  : _buildResultContent(),
    );
  }

  Widget _buildResultContent() {
    final data = Map<String, dynamic>.from(_diagnosisResult!['diagnosis'] ?? {});
    if (widget.listenResult['image_path'] != null) {
      data['image_path'] = widget.listenResult['image_path'];
    }
    final diseaseName = data['primary_diagnosis'] ?? 'Unknown Disease';
    final diseaseUrdu = data['disease_name_urdu'] ?? 'نامعلوم بیماری';
    final confidence = (data['confidence_percent'] ?? 0).toDouble();
    final riskScore = data['risk_score'] ?? 0;
    final urgency = data['urgency'];
    final homeCare = data['home_care'] as List<dynamic>? ?? [];
    final homeCareUrdu = data['home_care_urdu'] as List<dynamic>? ?? []; // Urdu translations
    final reasoning = data['reasoning'] ?? 'No reasoning provided.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Disease name card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F6E56),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Text(
                    diseaseUrdu,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    diseaseName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Confidence bar
          const Text(
            'Confidence',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: confidence / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F6E56)),
                  minHeight: 10,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${confidence.toInt()}% confidence',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Risk badge & 4. Urgency text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  'Risk Score: $riskScore',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: _getRiskColor(riskScore),
              ),
              if (urgency != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Text(
                    _getUrgencyText(urgency),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Home care steps
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Home Care Steps',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              OutlinedButton.icon(
                onPressed: () => setState(() => _showUrduHomeCare = !_showUrduHomeCare),
                icon: Icon(
                  _showUrduHomeCare ? Icons.g_translate : Icons.language,
                  size: 16,
                  color: const Color(0xFF0F6E56),
                ),
                label: Text(
                  _showUrduHomeCare ? 'English' : 'اردو (Urdu)',
                  style: const TextStyle(
                    color: Color(0xFF0F6E56),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0F6E56)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Choose which list to display based on toggle
          Builder(
            builder: (context) {
              final bool isUrdu = _showUrduHomeCare && homeCareUrdu.isNotEmpty;
              final List<dynamic> steps = isUrdu ? homeCareUrdu : homeCare;
              if (steps.isEmpty) {
                return const Text('No specific home care steps provided.');
              }
              return Column(
                children: steps.map((step) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                    children: [
                      Text(isUrdu ? ' •' : '• ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          step.toString(),
                          style: const TextStyle(fontSize: 16),
                          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              );
            },
          ),
          const SizedBox(height: 32),

          // 6. "Find a Vet" large green button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VetListScreen(diagnosisResult: data),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6E56),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Find a Vet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 7. "View Agent Reasoning" small text link
          Center(
            child: TextButton(
              onPressed: () {
                _showReasoningBottomSheet(context, reasoning);
              },
              child: const Text(
                'View Agent Reasoning',
                style: TextStyle(
                  color: Color(0xFF0F6E56),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReasoningBottomSheet(BuildContext context, String reasoning) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Agent Reasoning',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    reasoning,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6E56),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
