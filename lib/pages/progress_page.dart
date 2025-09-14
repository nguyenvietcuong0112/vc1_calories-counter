
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to see your progress.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('daily_logs')
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No progress data yet.'));
          }

          final logs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildWeightChart(logs),
              const SizedBox(height: 32),
              _buildCaloriesChart(logs),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeightChart(List<QueryDocumentSnapshot> logs) {
    final spots = <FlSpot> [];
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i].data() as Map<String, dynamic>;
      if (log.containsKey('weight')) {
        spots.add(FlSpot(i.toDouble(), log['weight']));
      }
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: LineChart(
        LineChartData(
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Theme.of(context).primaryColor,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(List<QueryDocumentSnapshot> logs) {
    final bars = <BarChartGroupData> [];
    for (var i = 0; i < logs.length; i++) {
      final log = logs[i].data() as Map<String, dynamic>;
      if (log.containsKey('calories')) {
        bars.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: log['calories'].toDouble(),
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        );
      }
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: bars,
        ),
      ),
    );
  }
}
