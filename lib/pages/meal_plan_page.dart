
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ai_api_service.dart';

class MealPlanPage extends StatefulWidget {
  const MealPlanPage({super.key});

  @override
  State<MealPlanPage> createState() => _MealPlanPageState();
}

class _MealPlanPageState extends State<MealPlanPage> {
  final _daysController = TextEditingController();
  Map<String, dynamic> _mealPlan = {};
  bool _isLoading = false;
  late final AiApiService _aiApiService;
  final String _userId = 'test_user';

  @override
  void initState() {
    super.initState();
    final generativeModel = FirebaseAI.vertexAI(auth: FirebaseAuth.instance)
        .generativeModel(model: 'gemini-1.5-flash');
    _aiApiService = AiApiService(generativeModel);
  }

  void _generateMealPlan() async {
    if (_daysController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _mealPlan = {};
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
        if (userDoc.exists) {
          Map<String, dynamic> userProfile = userDoc.data() as Map<String, dynamic>;
          final result = await _aiApiService.generateMealPlan(
            userProfile,
            int.parse(_daysController.text),
          );
          setState(() {
            _mealPlan = json.decode(result);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please save your profile first on the Home page.')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Personalized Meal Plan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of days',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _generateMealPlan,
                child: const Text('Generate Meal Plan'),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_mealPlan.isNotEmpty)
              _buildMealPlanDisplay()
          ],
        ),
      ),
    );
  }

  Widget _buildMealPlanDisplay() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _mealPlan.length,
      itemBuilder: (context, index) {
        String day = _mealPlan.keys.elementAt(index);
        Map<String, dynamic> meals = _mealPlan[day];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $day',
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...meals.entries.map((mealEntry) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealEntry.key,
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          mealEntry.value.toString(),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
