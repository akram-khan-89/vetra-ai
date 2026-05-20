import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/stitch_theme.dart';
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

      // Merge vision findings into symptoms
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
    if (score >= 7) return StitchColors.error;
    if (score >= 4) return Colors.orange;
    return StitchColors.primary;
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
      backgroundColor: StitchColors.background,
      appBar: AppBar(
        title: const Text('Diagnosis Result / تشخیص کا نتیجہ'),
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
                  Text('Analyzing symptoms / تشخیص ہو رہی ہے...', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: StitchColors.error),
                        const SizedBox(height: 16),
                        Text('Error: $_errorMessage', textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchDiagnosis,
                          style: ElevatedButton.styleFrom(backgroundColor: StitchColors.primary),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Disease name card with gradient and premium styling
          Container(
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
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [StitchColors.primaryContainer, StitchColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
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
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    diseaseName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: StitchColors.onBackground,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Confidence bar
          const Text(
            'Confidence / اعتماد کا تناسب',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: StitchColors.onBackground),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: confidence / 100,
                    backgroundColor: StitchColors.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation<Color>(StitchColors.primary),
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${confidence.toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: StitchColors.primary, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Risk badge & 4. Urgency text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  'Risk Score: $riskScore',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                backgroundColor: _getRiskColor(riskScore),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              if (urgency != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300, width: 1.5),
                  ),
                  child: Text(
                    _getUrgencyText(urgency),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),

          // 5. Home care steps styled card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: StitchColors.surfaceContainerHigh, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Home Care Steps',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: StitchColors.onBackground),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _showUrduHomeCare = !_showUrduHomeCare),
                      icon: Icon(
                        _showUrduHomeCare ? Icons.g_translate : Icons.language,
                        size: 14,
                        color: StitchColors.primary,
                      ),
                      label: Text(
                        _showUrduHomeCare ? 'English' : 'اردو',
                        style: const TextStyle(
                          color: StitchColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: StitchColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Choose which list to display based on toggle
                Builder(
                  builder: (context) {
                    final bool isUrdu = _showUrduHomeCare && homeCareUrdu.isNotEmpty;
                    final List<dynamic> steps = isUrdu ? homeCareUrdu : homeCare;
                    if (steps.isEmpty) {
                      return const Text('No specific home care steps provided.', style: TextStyle(color: Colors.grey));
                    }
                    return Column(
                      children: steps.map((step) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                          children: [
                            Text(isUrdu ? ' • ' : ' • ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StitchColors.primary)),
                            Expanded(
                              child: Text(
                                step.toString(),
                                style: const TextStyle(fontSize: 15, color: StitchColors.onBackground, height: 1.4),
                                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 6. "Find a Vet" large green button
          SizedBox(
            width: double.infinity,
            height: 54,
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
                backgroundColor: StitchColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Find a Vet / ڈاکٹر تلاش کریں',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 7. "View Agent Reasoning" link
          Center(
            child: TextButton(
              onPressed: () {
                _showReasoningBottomSheet(context, reasoning);
              },
              child: const Text(
                'View Agent Reasoning / تفصیلات دیکھیں',
                style: TextStyle(
                  color: StitchColors.primary,
                  fontWeight: FontWeight.bold,
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Agent Reasoning / تفصیلی وجہ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StitchColors.primary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    reasoning,
                    style: const TextStyle(fontSize: 15, color: StitchColors.onBackground, height: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StitchColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
