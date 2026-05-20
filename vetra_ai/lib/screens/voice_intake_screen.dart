import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../services/api_service.dart';
import '../theme/stitch_theme.dart';
import 'diagnosis_screen.dart';

class VoiceIntakeScreen extends StatefulWidget {
  const VoiceIntakeScreen({super.key});

  @override
  State<VoiceIntakeScreen> createState() => _VoiceIntakeScreenState();
}

class _VoiceIntakeScreenState extends State<VoiceIntakeScreen> with SingleTickerProviderStateMixin {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  double _confidence = 0;
  bool _isRecording = false;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (error) => print('Error: $error'),
      onStatus: (status) {
        print('Status: $status');
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isRecording = false;
            _animationController.stop();
            _animationController.reset();
          });
        }
      },
    );
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'ur_PK', // Listen in Urdu for farmer convenience
    );
    setState(() {
      _isRecording = true;
      _animationController.repeat(reverse: true);
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isRecording = false;
      _animationController.stop();
      _animationController.reset();
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _confidence = result.confidence;
    });
  }

  void _submitData() async {
    if (_lastWords.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _apiService.postVoiceIntake(_lastWords);
      setState(() {
        _isLoading = false;
      });
      // Navigate to DiagnosisScreen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiagnosisScreen(listenResult: result),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.background,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text('Voice Intake / آواز ریکارڈ کریں'),
        ),
        backgroundColor: StitchColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Styled Transcription card
            Expanded(
              child: Container(
                width: double.infinity,
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
                child: SingleChildScrollView(
                  child: Text(
                    _lastWords.isEmpty
                      ? 'Tap the microphone and start speaking...\n\nمائیکروفون دبائیں اور بولنا شروع کریں...'
                      : _lastWords,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: _lastWords.isEmpty ? Colors.grey : StitchColors.onBackground,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Confidence Chip
            if (_lastWords.isNotEmpty)
              Chip(
                avatar: const Icon(Icons.language, size: 16, color: StitchColors.primary),
                label: Text(
                  'Urdu (ur_PK) | Confidence: ${(_confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: StitchColors.primary, fontSize: 12),
                ),
                backgroundColor: StitchColors.primary.withOpacity(0.08),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            const SizedBox(height: 24),
            // Mic Button
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing effect using Stitch green colors
                  if (_isRecording)
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StitchColors.primary.withOpacity(0.18),
                        ),
                      ),
                    ),
                  // Main action button
                  Material(
                    elevation: 6,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    color: _isRecording ? Colors.red.shade600 : StitchColors.primary,
                    child: InkWell(
                      onTap: () {
                        if (!_speechEnabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Speech recognition not available or permission denied.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (_isRecording) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isRecording ? 'Listening / سن رہا ہے...' : 'Tap to speak / بولنے کے لیے دبائیں',
              style: const TextStyle(fontWeight: FontWeight.bold, color: StitchColors.onBackground),
            ),
            const SizedBox(height: 24),
            // Action Buttons or Loading
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(StitchColors.primary),
              )
            else if (_lastWords.isNotEmpty && !_isRecording)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: StitchColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      'Confirm / تصدیق کریں',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
