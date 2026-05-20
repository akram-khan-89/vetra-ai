import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingResult;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingResult,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  double _opacity = 0.0;
  bool _reminderOn = true;

  @override
  void initState() {
    super.initState();
    // Save booking to history
    _saveBookingToHistory();
    // Trigger animation after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _opacity = 1.0;
      });
    });
  }

  Future<void> _saveBookingToHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookingsList = prefs.getStringList('bookingHistory') ?? [];
    
    // Add current booking
    final vetName = widget.bookingResult['vet_name'] ?? 'Doctor';
    final rawTime = widget.bookingResult['confirmed_time'] ?? widget.bookingResult['appointment_time'];
    final timeStr = _formatDateTime(rawTime);
    final pricing = widget.bookingResult['pricing'] ?? {};
    final totalFee = pricing['total_rs'] ?? 1000;
    
    final bookingEntry = {
      'vetName': vetName,
      'time': timeStr,
      'fee': totalFee.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    bookingsList.insert(0, jsonEncode(bookingEntry));
    await prefs.setStringList('bookingHistory', bookingsList);
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(isoString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final dateStr = "${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}";
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minuteStr = dateTime.minute.toString().padLeft(2, '0');
      return "$dateStr at $hour:$minuteStr $ampm";
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vetName = widget.bookingResult['vet_name'] ?? 'Doctor';
    final rawTime = widget.bookingResult['confirmed_time'] ?? widget.bookingResult['appointment_time'];
    final timeStr = _formatDateTime(rawTime);
    
    final pricing = widget.bookingResult['pricing'] ?? {};
    final totalFee = pricing['total_rs'] ?? 1000;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevent going back
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            // Animated Green Checkmark
            Center(
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeIn,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Success Text in Urdu
            Text(
              '$vetName نے آپ کی request قبول کر لی',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F6E56),
              ),
            ),
            const SizedBox(height: 32),

            // Appointment Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event, color: Color(0xFF0F6E56)),
                        const SizedBox(width: 8),
                        const Text(
                          'Appointment Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Scheduled Time:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Estimated Fee:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs $totalFee',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F6E56),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reminder Toggle (Visual only, always on)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.grey),
                      SizedBox(width: 12),
                      Text(
                        'Appointment Reminder',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Switch(
                    value: _reminderOn,
                    onChanged: (val) {
                      setState(() {
                        _reminderOn = true; // Always stays on
                      });
                    },
                    activeThumbColor: const Color(0xFF0F6E56),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // "Done" Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F6E56),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
