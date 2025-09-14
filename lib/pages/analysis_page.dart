
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ai_api_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final _controller = TextEditingController();
  String _analysisResult = '';
  bool _isLoading = false;
  late final AiApiService _aiApiService;

  @override
  void initState() {
    super.initState();
    final generativeModel = FirebaseAI.vertexAI(auth: FirebaseAuth.instance)
        .generativeModel(model: 'gemini-1.5-flash');
    _aiApiService = AiApiService(generativeModel);
  }

  void _analyzeDiet() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _analysisResult = '';
      });

      final result = await _aiApiService.analyzeDiet(_controller.text);

      setState(() {
        _analysisResult = result;
        _isLoading = false;
      });

      _saveCaloriesToFirestore(result);
    }
  }

  Future<void> _saveCaloriesToFirestore(String analysisResult) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final caloriesMatch = RegExp(r'Total Calories: (\d+)').firstMatch(analysisResult);
    if (caloriesMatch != null) {
      final calories = int.tryParse(caloriesMatch.group(1)!);
      if (calories != null) {
        final today = DateTime.now();
        final dateStr = "${today.year}-${today.month}-${today.day}";

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('daily_logs')
            .doc(dateStr)
            .set({'calories': calories, 'date': today}, SetOptions(merge: true));
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
              'Analyze Your Daily Diet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Paste your daily food log here (JSON format)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyzeDiet,
                child: const Text('Analyze'),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_analysisResult.isNotEmpty)
              _buildAnalysisResultCard()
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResultCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diet Analysis',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _analysisResult,
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
