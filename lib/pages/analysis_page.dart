
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ai_api_service.dart';
import 'dart:convert';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String _analysisResult = '';
  bool _isLoading = true; // Start loading immediately
  late final AiApiService _aiApiService;
  final String _userId = 'test_user';

  @override
  void initState() {
    super.initState();
    final generativeModel = FirebaseAI.vertexAI(auth: FirebaseAuth.instance)
        .generativeModel(model: 'gemini-1.5-flash');
    _aiApiService = AiApiService(generativeModel);
    _analyzeDietAutomatically(); // Trigger analysis on page load
  }

  Future<void> _analyzeDietAutomatically() async {
    setState(() {
      _isLoading = true;
      _analysisResult = '';
    });

    try {
      // 1. Fetch User Profile
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();

      if (!userDoc.exists) {
        setState(() {
          _analysisResult = 'Could not find user profile. Please save your details on the Home page first.';
          _isLoading = false;
        });
        return;
      }
      Map<String, dynamic> userProfile = userDoc.data() as Map<String, dynamic>;

      // 2. Fetch recent food logs (e.g., last 7 days)
      QuerySnapshot foodLogSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('food_logs')
          .orderBy('timestamp', descending: true)
          .limit(20) // Limit to last 20 entries for this example
          .get();

      if (foodLogSnapshot.docs.isEmpty) {
        setState(() {
          _analysisResult = 'Not enough data to analyze. Please log your meals on the Home page for a few days.';
          _isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> foodLogs = foodLogSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // 3. Construct the data payload for the AI
      Map<String, dynamic> analysisData = {
        'user_profile': userProfile,
        'food_log': foodLogs,
      };

      // 4. Call the AI service
      final result = await _aiApiService.analyzeDiet(json.encode(analysisData));

      setState(() {
        _analysisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _analysisResult = 'Error performing analysis: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Diet Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _analyzeDietAutomatically,
            tooltip: 'Refresh Analysis',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildAnalysisResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResultCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Powered Insights',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const Divider(height: 20, thickness: 1),
            Text(
              _analysisResult,
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
