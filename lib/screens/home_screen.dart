import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'main_screen.dart'; // Assure-toi que ce fichier existe bien

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int plaisirCount = 0;
  int besoinCount = 0;
  int habitudeCount = 0;
  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    _loadStartTime();
  }

  Future<void> _loadStartTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTime = prefs.getString('startTime');

    if (savedTime == null) {
      startTime = DateTime.now();
      prefs.setString('startTime', startTime.toIso8601String());
    } else {
      startTime = DateTime.parse(savedTime);
    }

    _checkElapsedTime();
  }

  void _checkElapsedTime() {
    Duration elapsed = DateTime.now().difference(startTime);
    if (elapsed.inHours >= 24) {
      // Après 24h, passage automatique à la page principale
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    }
  }

  void _incrementCounter(String type) {
    setState(() {
      if (type == "Plaisir") plaisirCount++;
      if (type == "Besoin") besoinCount++;
      if (type == "Habitude") habitudeCount++;
    });
  }

  void _showNextDayWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Attention"),
        content: Text(
            "En passant au jour suivant, vous ne pourrez plus modifier vos entrées d'aujourd'hui. Êtes-vous sûr de vouloir continuer ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            },
            child: Text("Continuer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Suivi des cigarettes")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                "Nombre total de cigarettes fumées : ${plaisirCount + besoinCount + habitudeCount}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            _buildCigaretteCounter("Plaisir", plaisirCount, Colors.green),
            _buildCigaretteCounter("Besoin", besoinCount, Colors.blue),
            _buildCigaretteCounter("Habitude", habitudeCount, Colors.red),
            Spacer(),
            ElevatedButton(
              onPressed: _showNextDayWarning,
              child: Text("Jour Suivant"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCigaretteCounter(String label, int count, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.smoking_rooms, color: color),
        title: Text(label, style: TextStyle(fontSize: 18)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$count", style: TextStyle(fontSize: 18)),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _incrementCounter(label),
              child: Text("+"),
            ),
          ],
        ),
      ),
    );
  }
}
