import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../services/api_service.dart';
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
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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
      localeId: 'ur_PK', // Try to listen in Urdu as implied by previous screen
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
            builder: (context) => DiagnosisScreen(data: result),
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
      appBar: AppBar(
        title: const Text('Voice Intake'),
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Transcription area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _lastWords.isEmpty
                        ? 'Tap the microphone and start speaking...'
                        : _lastWords,
                    style: TextStyle(
                      fontSize: 18,
                      color: _lastWords.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Confidence Chip
            if (_lastWords.isNotEmpty)
              Chip(
                avatar: const Icon(Icons.language, size: 16),
                label: Text(
                  'Urdu (ur_PK) | Confidence: ${(_confidence * 100).toStringAsFixed(0)}%',
                ),
                backgroundColor: const Color(0xFF0F6E56).withOpacity(0.1),
              ),
            const SizedBox(height: 24),
            // Mic Button
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing effect
                  if (_isRecording)
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                    ),
                  // Main button
                  Material(
                    elevation: 4,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    color: _isRecording ? Colors.red : const Color(0xFF0F6E56),
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
              _isRecording ? 'Listening...' : 'Tap to speak',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Action Buttons or Loading
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F6E56)),
              )
            else if (_lastWords.isNotEmpty && !_isRecording)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6E56),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 18),
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
