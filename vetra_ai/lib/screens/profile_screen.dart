import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Real data for farmer's profile, backed by SharedPreferences
  String farmerName = 'Your Name / آپ کا نام';
  String phoneNumber = 'Add Phone Number';
  String location = 'Add Location';
  
  // Livestock counts
  int cowsCount = 0;
  int buffaloesCount = 0;
  int goatsCount = 0;
  int sheepCount = 0;

  bool _isLoading = true;
  List<Map<String, dynamic>> bookingHistory = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> bookingsList = prefs.getStringList('bookingHistory') ?? [];
    setState(() {
      farmerName = prefs.getString('farmerName') ?? 'Your Name / آپ کا نام';
      phoneNumber = prefs.getString('phoneNumber') ?? 'Add Phone Number';
      location = prefs.getString('location') ?? 'Add Location';
      
      cowsCount = prefs.getInt('cowsCount') ?? 0;
      buffaloesCount = prefs.getInt('buffaloesCount') ?? 0;
      goatsCount = prefs.getInt('goatsCount') ?? 0;
      sheepCount = prefs.getInt('sheepCount') ?? 0;
      
      bookingHistory = bookingsList.map((item) {
        try {
          return jsonDecode(item) as Map<String, dynamic>;
        } catch (e) {
          return <String, dynamic>{};
        }
      }).where((item) => item.isNotEmpty).toList();
      
      _isLoading = false;
    });
  }

  Future<void> _saveProfileData(String name, String phone, String loc, int cows, int buffaloes, int goats, int sheep) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmerName', name);
    await prefs.setString('phoneNumber', phone);
    await prefs.setString('location', loc);
    await prefs.setInt('cowsCount', cows);
    await prefs.setInt('buffaloesCount', buffaloes);
    await prefs.setInt('goatsCount', goats);
    await prefs.setInt('sheepCount', sheep);
    
    // Reload state to reflect changes on screen
    _loadProfileData();
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: farmerName);
    final phoneController = TextEditingController(text: phoneNumber);
    final locationController = TextEditingController(text: location);
    
    final cowsController = TextEditingController(text: cowsCount.toString());
    final buffaloesController = TextEditingController(text: buffaloesCount.toString());
    final goatsController = TextEditingController(text: goatsCount.toString());
    final sheepController = TextEditingController(text: sheepCount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile / پروفائل تبدیل کریں', style: TextStyle(color: Color(0xFF0F6E56), fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name (نام)'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number (فون نمبر)'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location (مقام)'),
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('My Farm (میرا فارم)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F6E56))),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: cowsController, decoration: const InputDecoration(labelText: 'Cows (گائے)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: buffaloesController, decoration: const InputDecoration(labelText: 'Buffaloes (بھینسیں)'), keyboardType: TextInputType.number)),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: TextField(controller: goatsController, decoration: const InputDecoration(labelText: 'Goats (بکریاں)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: sheepController, decoration: const InputDecoration(labelText: 'Sheep (بھیڑیں)'), keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final c = int.tryParse(cowsController.text) ?? 0;
                final b = int.tryParse(buffaloesController.text) ?? 0;
                final g = int.tryParse(goatsController.text) ?? 0;
                final s = int.tryParse(sheepController.text) ?? 0;
                
                _saveProfileData(
                  nameController.text,
                  phoneController.text,
                  locationController.text,
                  c, b, g, s
                );
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile saved successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F6E56), foregroundColor: Colors.white),
              child: const Text('Save (محفوظ کریں)'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0F6E56);
    
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile / میری پروفائل', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditProfileDialog,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Color(0xFFE8F5E9),
                          child: Icon(Icons.person, size: 60, color: primaryColor),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showEditProfileDialog,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: primaryColor, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    farmerName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        phoneNumber,
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Farm (میرا فارم)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Livestock Grid
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    children: [
                      _buildLivestockCard('Cows\nگائے', cowsCount, Icons.pets, primaryColor),
                      _buildLivestockCard('Buffaloes\nبھینسیں', buffaloesCount, Icons.water_drop, Colors.blueGrey),
                      _buildLivestockCard('Goats\nبکریاں', goatsCount, Icons.grass, Colors.brown),
                      _buildLivestockCard('Sheep\nبھیڑیں', sheepCount, Icons.cloud, Colors.grey),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Booking History / بکنگ کی تاریخ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (bookingHistory.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          const Text(
                            'No Bookings Yet / ابھی تک کوئی بکنگ نہیں ہے',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your scheduled vet appointments will be listed here.',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bookingHistory.length,
                      itemBuilder: (context, index) {
                        final booking = bookingHistory[index];
                        final vetName = booking['vetName'] ?? 'Doctor';
                        final time = booking['time'] ?? 'N/A';
                        final fee = booking['fee'] ?? '1000';
                        return Card(
                          elevation: 0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.vaccines, color: Color(0xFF0F6E56), size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vetName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        time,
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F6E56).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Confirmed',
                                        style: TextStyle(
                                          color: Color(0xFF0F6E56),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs $fee',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 30),
                  
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Log Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivestockCard(String title, int count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
