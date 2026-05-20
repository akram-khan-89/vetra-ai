import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/stitch_theme.dart';
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
    final loggedInPhone = prefs.getString('loggedInUserPhone') ?? '';
    final key = 'bookingHistory_$loggedInPhone';
    final List<String> bookingsList = prefs.getStringList(key) ?? [];
    
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
    await prefs.setStringList(key, bookingsList);
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
      backgroundColor: StitchColors.background,
      appBar: AppBar(
        title: const Text('Booking Confirmation / بکنگ کی تصدیق'),
        backgroundColor: StitchColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Prevent going back
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            // Animated Green Checkmark with premium ring outline
            Center(
              child: AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeIn,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: StitchColors.primary.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: StitchColors.primary.withOpacity(0.2), width: 3),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: StitchColors.primary,
                    size: 80,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Success Text in Urdu & English
            Text(
              '$vetName نے آپ کی request قبول کر لی',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: StitchColors.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Appointment Card
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.event, color: StitchColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Appointment Details / تفاصیل',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 28),
                    const Text(
                      'Scheduled Time / مقررہ وقت:',
                      style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: StitchColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Estimated Fee / تخمینہ فیس:',
                      style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rs $totalFee',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: StitchColors.primary,
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StitchColors.surfaceContainerHigh, width: 1.5),
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
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: StitchColors.onBackground),
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
                    activeColor: Colors.white,
                    activeTrackColor: StitchColors.primary,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // "Done" Button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: StitchColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Done / مکمل',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
