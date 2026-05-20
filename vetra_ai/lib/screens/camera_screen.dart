import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
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
        title: const Text('Image Quality'),
        content: const Text('Photo unclear. Please retake in daylight.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
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
      appBar: AppBar(
        title: const Text('Photo Analysis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F6E56),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(color: Color(0xFF0F6E56)),
                  SizedBox(height: 16),
                  Text('Analyzing image...', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Upload a clear photo of the animal to help identify symptoms and physical conditions.',
                    style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // Image Preview Area
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _selectedImage != null
                        ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover, width: double.infinity)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('No image selected', style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500)),
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
                            backgroundColor: const Color(0xFF0F6E56),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.photo_library, color: Color(0xFF0F6E56)),
                          label: const Text('Gallery', style: TextStyle(color: Color(0xFF0F6E56), fontSize: 16, fontWeight: FontWeight.bold)),
                          onPressed: () => _pickImage(ImageSource.gallery),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF0F6E56), width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    const Text('Detected Findings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _visualFindings.map((f) => Chip(
                        label: Text(f, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                        backgroundColor: const Color(0xFF1B8A6B),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide.none),
                      )).toList(),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F6E56),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: const Text('Continue with Findings', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
