import 'package:flutter/material.dart';
import '../theme/stitch_theme.dart';
import 'booking_history_screen.dart';
import 'all_vets_screen.dart';
import 'voice_intake_screen.dart';
import 'camera_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeTabContent(),
    BookingHistoryScreen(),
    AllVetsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StitchColors.background,
      appBar: AppBar(
        title: const Text('Vetra AI'),
        backgroundColor: StitchColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: 'Vets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: StitchColors.primary,
          unselectedItemColor: StitchColors.outline,
          backgroundColor: Colors.white,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Farmer Greeting Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  StitchColors.primaryContainer,
                  StitchColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: StitchColors.primary.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'السلام علیکم / Welcome',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your AI assistant is ready to analyze your livestock health problems.',
                  style: TextStyle(
                    color: StitchColors.onPrimaryContainer,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Main Diagnostic Interaction Card
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 20.0),
              child: Column(
                children: [
                  const Text(
                    'Quick Diagnose / فوری تشخیص',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: StitchColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the microphone to describe symptoms in Urdu or English, or take a clear picture of the animal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Large circular mic button with premium animated-style rings
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: StitchColors.primary.withOpacity(0.08),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StitchColors.primary.withOpacity(0.12),
                        ),
                        child: Material(
                          elevation: 6,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          color: StitchColors.primary,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const VoiceIntakeScreen()),
                              );
                            },
                            child: const SizedBox(
                              width: 140,
                              height: 140,
                              child: Icon(
                                Icons.mic,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'بیماری بیان کریں',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: StitchColors.primary,
                    ),
                  ),
                  const Text(
                    'Tap to speak',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: StitchColors.outline,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Camera button styled cleanly
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CameraScreen()),
                      );
                    },
                    icon: const Icon(Icons.camera_alt_outlined, size: 20),
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: const Text('Take Photo / تصویر لیں', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchColors.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
