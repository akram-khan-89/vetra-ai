import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/stitch_theme.dart';
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
  }

  Future<void> _loadProfileData() async {
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
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Edit Profile / پروفائل تبدیل کریں',
            style: TextStyle(color: StitchColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name (نام)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number (فون نمبر)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location (مقام)'),
                ),
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'My Farm (میرا فارم)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: StitchColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: cowsController, decoration: const InputDecoration(labelText: 'Cows (گائے)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: buffaloesController, decoration: const InputDecoration(labelText: 'Buffaloes (بھینسیں)'), keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: goatsController, decoration: const InputDecoration(labelText: 'Goats (بکریاں)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: StitchColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save / محفوظ کریں'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: StitchColors.background,
        body: Center(child: CircularProgressIndicator(color: StitchColors.primary)),
      );
    }
    
    return Scaffold(
      backgroundColor: StitchColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Premium Profile Banner Card
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    StitchColors.primaryContainer,
                    StitchColors.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 36, top: 24, left: 24, right: 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: StitchColors.primary.withOpacity(0.08),
                          child: const Icon(Icons.person, size: 64, color: StitchColors.primary),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showEditProfileDialog,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.edit, color: StitchColors.primary, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    farmerName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              phoneNumber,
                              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              location,
                              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Farm / میرا فارم',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: StitchColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Livestock Grid styled perfectly
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.4,
                    children: [
                      _buildLivestockCard('Cows\nگائے', cowsCount, Icons.pets, StitchColors.primary),
                      _buildLivestockCard('Buffaloes\nبھینسیں', buffaloesCount, Icons.agriculture, Colors.blueGrey),
                      _buildLivestockCard('Goats\nبکریاں', goatsCount, Icons.pets, Colors.brown),
                      _buildLivestockCard('Sheep\nبھیڑیں', sheepCount, Icons.cloud, Colors.grey),
                    ],
                  ),
                  
                  const SizedBox(height: 36),
                  
                  // Edit profile action button
                  OutlinedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Details / تفصیلات بدلیں'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      side: const BorderSide(color: StitchColors.primary, width: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Log Out Button
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
                    label: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StitchColors.errorContainer,
                      foregroundColor: StitchColors.error,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
        border: Border.all(color: StitchColors.surfaceContainerHigh, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
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
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: StitchColors.onBackground,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
