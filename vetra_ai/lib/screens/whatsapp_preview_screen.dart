import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../theme/stitch_theme.dart';
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
      backgroundColor: StitchColors.background,
      appBar: AppBar(
        title: const Text('Message Preview / پیغام کا پیش نظارہ'),
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
                  Text('Preparing message content... / پیغام تیار ہو رہا ہے...', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: StitchColors.error),
                      const SizedBox(height: 16),
                      Text('Error: $_errorMessage'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchWhatsAppDetails,
                        style: ElevatedButton.styleFrom(backgroundColor: StitchColors.primary),
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'To: Dr. ${widget.vet['name'] ?? 'Vet'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: StitchColors.primary),
          ),
          const SizedBox(height: 20),

          // Outgoing message chat bubble container
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // WhatsApp Outgoing Chat Bubble
                  Container(
                    margin: const EdgeInsets.only(left: 40.0, bottom: 16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9FDD3), // WhatsApp Outgoing Bubble Color
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(0),
                      ),
                      border: Border.all(color: Colors.green.shade100, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
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
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Vetra AI Agent / ویٹرا اے آئی ایجنٹ',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Photo thumbnail
                  Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Animal Photo / جانور کی تصویر: ',
                          style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: StitchColors.surfaceContainerHigh, width: 1.5),
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
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text('Send via WhatsApp / واٹس ایپ پر بھیجیں'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
          ),
          const SizedBox(height: 12),

          // Book without WhatsApp Button
          OutlinedButton(
            onPressed: () => _createBookingAndNavigate(launchWhatsApp: false),
            style: OutlinedButton.styleFrom(
              foregroundColor: StitchColors.primary,
              side: const BorderSide(color: StitchColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Book without WhatsApp / واٹس ایپ کے بغیر بک کریں', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
