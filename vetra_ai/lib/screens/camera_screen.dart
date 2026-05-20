import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../theme/stitch_theme.dart';
import 'diagnosis_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isLoading = false;
  List<String> _visualFindings = [];
  String? _imageQuality;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, maxWidth: 480);
      if (image == null) return;
      setState(() {
        _selectedImage = image;
        _isLoading = true;
      });
      await _uploadImage(image);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _uploadImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final api = ApiService();
      final response = await api.postImageIntake(base64Image, 'demo-001');
      // Expected response structure: { visual_findings: [...], image_quality: 'good'|'poor' }
      setState(() {
        _visualFindings = List<String>.from(response['visual_findings'] ?? []);
        _imageQuality = response['image_quality'];
        _isLoading = false;
      });
      if (_imageQuality == 'poor') {
        _showQualityWarning();
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  void _showQualityWarning() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Image Quality / تصویر کا معیار', style: TextStyle(color: StitchColors.primary, fontWeight: FontWeight.bold)),
        content: const Text('Photo unclear. Please retake in daylight.\nتصویر صاف نہیں ہے۔ براہ کرم دن کی روشنی میں دوبارہ تصویر لیں۔'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: StitchColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _continue() {
    // Pass findings to DiagnosisScreen via listenResult map
    final data = {
      'vision_findings': _visualFindings,
      'image_path': _selectedImage?.path,
    };
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DiagnosisScreen(listenResult: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.background,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: const Text('Photo Analysis / تصویر کا تجزیہ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: StitchColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: StitchColors.primary),
                  SizedBox(height: 16),
                  Text('Analyzing image... / تصویر کا تجزیہ ہو رہا ہے...', style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Upload a clear photo of the animal to help identify symptoms and physical conditions.\nجانور کی واضح تصویر اپ لوڈ کریں تاکہ بیماری کی علامات کو آسانی سے پہچانا جا سکے۔',
                    style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Image Preview Area
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: StitchColors.surfaceContainerHigh, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.015),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _selectedImage != null
                        ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover, width: double.infinity)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: StitchColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_a_photo_outlined, size: 48, color: StitchColors.primary),
                              ),
                              const SizedBox(height: 16),
                              const Text('No image selected / کوئی تصویر منتخب نہیں کی گئی', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          label: const Text('Camera', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          onPressed: () => _pickImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: StitchColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.photo_library, color: StitchColors.primary),
                          label: const Text('Gallery', style: TextStyle(color: StitchColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                          onPressed: () => _pickImage(ImageSource.gallery),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: StitchColors.primary, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Results Area
                  if (_visualFindings.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),
                    const Text('Detected Findings / علامات ملی ہیں', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StitchColors.onBackground)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _visualFindings.map((f) => Chip(
                        label: Text(f, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        backgroundColor: StitchColors.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      )).toList(),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StitchColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: const Text(
                          'Continue with Findings / نتائج کے ساتھ جاری رکھیں',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
