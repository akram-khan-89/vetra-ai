import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text('Vetra AI'),
        backgroundColor: const Color(0xFF0F6E56),
        foregroundColor: Colors.white,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Vets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0F6E56),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Large circular mic button
          Material(
            elevation: 8,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            color: const Color(0xFF0F6E56),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VoiceIntakeScreen()),
                );
              },
              child: const SizedBox(
                width: 160, // 80px radius = 160px diameter
                height: 160,
                child: Icon(
                  Icons.mic,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'بیماری بیان کریں',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F6E56),
            ),
          ),
          const SizedBox(height: 40),
          // Secondary camera button
          IconButton(
            icon: const Icon(Icons.camera_alt),
            iconSize: 50,
            color: const Color(0xFF0F6E56),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Take Photo',
            style: TextStyle(
              color: Color(0xFF0F6E56),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
