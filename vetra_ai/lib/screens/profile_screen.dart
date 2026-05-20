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

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInPhone = prefs.getString('loggedInUserPhone') ?? '';
    
    final keyName = 'farmerName_$loggedInPhone';
    final keyPhone = 'phoneNumber_$loggedInPhone';
    final keyLocation = 'location_$loggedInPhone';
    final keyCows = 'cowsCount_$loggedInPhone';
    final keyBuffaloes = 'buffaloesCount_$loggedInPhone';
    final keyGoats = 'goatsCount_$loggedInPhone';
    final keySheep = 'sheepCount_$loggedInPhone';

    setState(() {
      farmerName = prefs.getString(keyName) ?? 'Your Name / آپ کا نام';
      phoneNumber = prefs.getString(keyPhone) ?? loggedInPhone;
      location = prefs.getString(keyLocation) ?? 'Add Location';
      
      cowsCount = prefs.getInt(keyCows) ?? 0;
      buffaloesCount = prefs.getInt(keyBuffaloes) ?? 0;
      goatsCount = prefs.getInt(keyGoats) ?? 0;
      sheepCount = prefs.getInt(keySheep) ?? 0;
      
      _isLoading = false;
    });
  }

  Future<void> _saveProfileData(String name, String phone, String loc, int cows, int buffaloes, int goats, int sheep) async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInPhone = prefs.getString('loggedInUserPhone') ?? '';

    final keyName = 'farmerName_$loggedInPhone';
    final keyPhone = 'phoneNumber_$loggedInPhone';
    final keyLocation = 'location_$loggedInPhone';
    final keyCows = 'cowsCount_$loggedInPhone';
    final keyBuffaloes = 'buffaloesCount_$loggedInPhone';
    final keyGoats = 'goatsCount_$loggedInPhone';
    final keySheep = 'sheepCount_$loggedInPhone';

    await prefs.setString(keyName, name.trim().isEmpty ? 'Your Name / آپ کا نام' : name.trim());
    await prefs.setString(keyPhone, phone.trim().isEmpty ? loggedInPhone : phone.trim());
    await prefs.setString(keyLocation, loc.trim().isEmpty ? 'Add Location' : loc.trim());
    await prefs.setInt(keyCows, cows);
    await prefs.setInt(keyBuffaloes, buffaloes);
    await prefs.setInt(keyGoats, goats);
    await prefs.setInt(keySheep, sheep);
    
    // Reload state to reflect changes on screen
    _loadProfileData();
  }
  void _showEditProfileDialog() {
    final nameController = TextEditingController(
      text: (farmerName == 'Your Name / آپ کا نام' || farmerName == 'Chaudhry Ali' || farmerName == 'Farmer Ali') ? '' : farmerName,
    );
    final phoneController = TextEditingController(
      text: (phoneNumber == 'Add Phone Number' || phoneNumber == '0300-1234567') ? '' : phoneNumber,
    );
    final locationController = TextEditingController(
      text: (location == 'Add Location' || location == 'Lahore, Pakistan') ? '' : location,
    );
    
    final cowsController = TextEditingController(text: cowsCount == 0 ? '' : cowsCount.toString());
    final buffaloesController = TextEditingController(text: buffaloesCount == 0 ? '' : buffaloesCount.toString());
    final goatsController = TextEditingController(text: goatsCount == 0 ? '' : goatsCount.toString());
    final sheepController = TextEditingController(text: sheepCount == 0 ? '' : sheepCount.toString());

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
                  
                  const SizedBox(height: 30),
                  
                  ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', false);
                      await prefs.remove('loggedInUserPhone');
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                          (route) => false,
                        );
                      }
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
