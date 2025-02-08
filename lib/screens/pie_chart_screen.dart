import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Répartition des cigarettes")),
      body: Center(
        child: Text("Graphique en camembert ici"),
      ),
    );
  }
}
