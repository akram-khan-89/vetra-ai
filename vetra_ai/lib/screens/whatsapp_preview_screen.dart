import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'booking_confirmation_screen.dart';

class WhatsAppPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> vet;
  final Map<String, dynamic> diagnosis;
  final Map<String, dynamic>? pricing;

  const WhatsAppPreviewScreen({
    super.key,
    required this.vet,
    required this.diagnosis,
    this.pricing,
  });

  @override
  State<WhatsAppPreviewScreen> createState() => _WhatsAppPreviewScreenState();
}

class _WhatsAppPreviewScreenState extends State<WhatsAppPreviewScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _messageUrdu;
  String? _whatsappLink;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchWhatsAppDetails();
  }

  Future<void> _fetchWhatsAppDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.postWorkflow(
        vet: widget.vet,
        diagnosis: widget.diagnosis,
        pricing: widget.pricing ?? {},
      );

      final executeData = response['data'] ?? {};
      setState(() {
        _messageUrdu = executeData['message_urdu'] ?? 'محترم ڈاکٹر، جانور کے معائنے کے لیے آپ کی ضرورت ہے۔';
        _whatsappLink = executeData['whatsapp_link'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createBookingAndNavigate({required bool launchWhatsApp}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vetId = widget.vet['vet_id'] ?? '';
      final caseId = widget.diagnosis['case_id'] ?? 'case_${DateTime.now().millisecondsSinceEpoch}';
      final farmerId = 'farmer_default'; // Default mock farmer

      final bookingResult = await _apiService.postBooking(
        vetId: vetId,
        caseId: caseId,
        farmerId: farmerId,
        pricing: widget.pricing ?? {},
      );

      setState(() {
        _isLoading = false;
      });

      if (launchWhatsApp && _whatsappLink != null) {
        final uri = Uri.parse(_whatsappLink!);
        try {
          final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!success) {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          }
        } catch (e) {
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not launch WhatsApp or browser.')),
              );
            }
          }
        }
      }

      final extendedBookingResult = {
        ...bookingResult,
        'vet_name': widget.vet['name'] ?? 'Vet',
        'pricing': widget.pricing ?? {},
      };

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationScreen(
              bookingResult: extendedBookingResult,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Message Preview'),
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
                  Text('Preparing message content...'),
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
                        onPressed: _fetchWhatsAppDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'To: Dr. ${widget.vet['name'] ?? 'Vet'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Outgoing message chat bubble container
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // WhatsApp Outgoing Chat Bubble
                  Container(
                    margin: const EdgeInsets.only(left: 40.0, bottom: 12.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9FDD3), // WhatsApp Outgoing Bubble Color
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _messageUrdu ?? '',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Vetra AI Agent',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Photo thumbnail
                  Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'جانور کی تصویر: ',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: (widget.diagnosis['image_path'] != null &&
                                  File(widget.diagnosis['image_path']).existsSync())
                              ? Image.file(
                                  File(widget.diagnosis['image_path']),
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Send via WhatsApp Button
          ElevatedButton.icon(
            onPressed: () => _createBookingAndNavigate(launchWhatsApp: true),
            icon: const Icon(Icons.send),
            label: const Text('Send via WhatsApp'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),

          // Book without WhatsApp Button
          OutlinedButton(
            onPressed: () => _createBookingAndNavigate(launchWhatsApp: false),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F6E56),
              side: const BorderSide(color: Color(0xFF0F6E56)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Book without WhatsApp'),
          ),
        ],
      ),
    );
  }
}
