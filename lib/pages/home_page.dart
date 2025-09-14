
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/ai_api_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/push_notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _caloriesController = TextEditingController();

  String? _gender;
  String? _goal;
  String _healthTip = 'Loading your daily health tip...';
  String _predictedWeight = 'Loading prediction...';

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _goals = ['Lose weight', 'Maintain weight', 'Gain weight'];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';
  late final AiApiService _aiApiService;
  late final PushNotificationService _pushNotificationService;

  @override
  void initState() {
    super.initState();
    final generativeModel = FirebaseAI.vertexAI(auth: FirebaseAuth.instance)
        .generativeModel(model: 'gemini-1.5-flash');
    _aiApiService = AiApiService(generativeModel);
    _pushNotificationService = PushNotificationService();
    _loadData();
    _setupNotifications();
  }

  void _setupNotifications() async {
    await _pushNotificationService.initialize();
    String? token = await _pushNotificationService.getFCMToken();
    _saveFCMToken(token);
  }

  Future<void> _saveFCMToken(String? token) async {
    if (token == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .set({'fcmToken': token}, SetOptions(merge: true));
  }

  Future<void> _loadData() async {
    await _loadUserProfile();
    _generateHealthTip();
  }

  Future<void> _generateHealthTip() async {
    final tip = await _aiApiService.generateHealthTip();
    setState(() {
      _healthTip = tip;
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        _ageController.text = userData['age']?.toString() ?? '';
        _heightController.text = userData['height']?.toString() ?? '';
        _weightController.text = userData['weight']?.toString() ?? '';
        _caloriesController.text = userData['calories']?.toString() ?? '';
        setState(() {
          _gender = userData['gender'];
          _goal = userData['goal'];
        });
        _predictWeight(userData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  Future<void> _saveUserProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        Map<String, dynamic> userProfile = {
          'age': int.tryParse(_ageController.text),
          'gender': _gender,
          'height': int.tryParse(_heightController.text),
          'weight': int.tryParse(_weightController.text),
          'goal': _goal,
          'calories': int.tryParse(_caloriesController.text),
        };
        await _firestore.collection('users').doc(_userId).set(userProfile, SetOptions(merge: true));
        _saveWeightToFirestore(int.tryParse(_weightController.text));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
        _predictWeight(userProfile);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
  }

  Future<void> _saveWeightToFirestore(int? weight) async {
    if (weight == null) return;

    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month}-${today.day}";

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('daily_logs')
        .doc(dateStr)
        .set({'weight': weight, 'date': today}, SetOptions(merge: true));
  }

  Future<void> _predictWeight(Map<String, dynamic> userProfile) async {
    final prediction = await _aiApiService.predictWeight(userProfile);
    setState(() {
      _predictedWeight = prediction;
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHealthTipCard(),
              const SizedBox(height: 24),
              _buildWeightPredictionCard(),
              const SizedBox(height: 24),
              Text(
                'Your Profile',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your age';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                      items: _genders.map((String gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _gender = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your gender';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height (cm)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your height';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your weight';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _goal,
                      decoration: const InputDecoration(
                        labelText: 'Your Goal',
                        border: OutlineInputBorder(),
                      ),
                      items: _goals.map((String goal) {
                        return DropdownMenuItem<String>(
                          value: goal,
                          child: Text(goal),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _goal = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your goal';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Daily Calorie Goal',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your calorie goal';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveUserProfile,
                        child: const Text('Save Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthTipCard() {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Tip of the Day',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _healthTip,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightPredictionCard() {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '30-Day Weight Prediction',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _predictedWeight,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
