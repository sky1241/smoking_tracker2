import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pie_chart_screen.dart';
import 'dart:convert';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<String> days = [];
  List<List<int>> cigaretteData = [];
  int historyView = 7; // 7 jours par défaut

  @override
  void initState() {
    super.initState();
    _loadCigaretteData();
  }

  Future<void> _loadCigaretteData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('cigarette_history');
    if (storedData != null) {
      Map<String, dynamic> history = jsonDecode(storedData);
      List<String> sortedKeys = history.keys.toList()..sort();
      List<String> selectedDays = sortedKeys.takeLast(historyView).toList();

      List<List<int>> selectedData = selectedDays.map((day) {
        return List<int>.from(history[day]);
      }).toList();

      setState(() {
        days = selectedDays;
        cigaretteData = selectedData;
      });
    }
  }

  void _cycleHistoryView() {
    setState(() {
      if (historyView == 7) {
        historyView = 30; // 1 mois
      } else if (historyView == 30) {
        historyView = 90; // 3 mois
      } else if (historyView == 90) {
        historyView = 365; // 1 an
      } else {
        historyView = 9999; // Tout l'historique
      }
    });
    _loadCigaretteData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Statistiques")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Évolution des cigarettes fumées", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(child: _buildBarChart()),
            SizedBox(height: 30),
            Text("Tendance des cigarettes fumées", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Expanded(child: _buildLineChart()),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PieChartScreen()),
              ),
              child: Text("Voir la répartition en camembert"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cycleHistoryView,
              child: Text(historyView == 7 ? "Afficher 1 mois" :
              historyView == 30 ? "Afficher 3 mois" :
              historyView == 90 ? "Afficher 1 an" : "Afficher tout l'historique"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: List.generate(days.length, (index) {
          return BarChartGroupData(x: index, barRods: [
            BarChartRodData(toY: cigaretteData[index][0].toDouble(), color: Colors.blue),
            BarChartRodData(toY: cigaretteData[index][1].toDouble(), color: Colors.red),
            BarChartRodData(toY: cigaretteData[index][2].toDouble(), color: Colors.green),
          ]);
        }),
        titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(days[value.toInt()])))),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(spots: List.generate(days.length, (index) => FlSpot(index.toDouble(), cigaretteData[index][0].toDouble())), color: Colors.blue),
          LineChartBarData(spots: List.generate(days.length, (index) => FlSpot(index.toDouble(), cigaretteData[index][1].toDouble())), color: Colors.red),
          LineChartBarData(spots: List.generate(days.length, (index) => FlSpot(index.toDouble(), cigaretteData[index][2].toDouble())), color: Colors.green),
        ],
      ),
    );
  }
}

extension TakeLastExtension<T> on List<T> {
  List<T> takeLast(int n) {
    return sublist(length > n ? length - n : 0);
  }
}
