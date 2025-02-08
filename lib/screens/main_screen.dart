import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'schedule_screen.dart';
import 'stats_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String wakeUpTime = "";
  String sleepTime = "";
  bool isScheduleSet = false;
  bool hasAcknowledged = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
    _loadAcknowledgment();
  }

  Future<void> _loadSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      wakeUpTime = prefs.getString('wakeUpTime') ?? "";
      sleepTime = prefs.getString('sleepTime') ?? "";
      isScheduleSet = wakeUpTime.isNotEmpty && sleepTime.isNotEmpty;
    });
  }

  Future<void> _loadAcknowledgment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      hasAcknowledged = prefs.getBool('hasAcknowledged') ?? false;
    });
  }

  Future<void> _setAcknowledgment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasAcknowledged', true);
    setState(() {
      hasAcknowledged = true;
    });
  }

  void _showScheduleAlert() {
    if (!isScheduleSet && mounted && !hasAcknowledged) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text("Information Importante"),
            content: Text("Il est important de définir vos heures de lever et de coucher afin que l'application puisse mieux vous aider à suivre votre consommation de cigarettes."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _navigateToScheduleScreen();
                },
                child: Text("Définir maintenant"),
              ),
              TextButton(
                onPressed: () {
                  _setAcknowledgment();
                  Navigator.pop(context);
                },
                child: Text("Valider"),
              ),
            ],
          ),
        );
      });
    }
  }

  void _navigateToScheduleScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScheduledScreen()),
    ).then((_) {
      _loadSchedule();
    });
  }

  void _navigateToStatsScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StatsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (!isScheduleSet && !hasAcknowledged) {
        _showScheduleAlert();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Accueil"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Accueil",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.alarm,
                        color: isScheduleSet ? Colors.white : Colors.red,
                        size: 50,
                      ),
                      onPressed: _navigateToScheduleScreen,
                    ),
                    SizedBox(width: 20),
                    IconButton(
                      icon: Icon(
                        Icons.bar_chart,
                        color: Colors.blue,
                        size: 50,
                      ),
                      onPressed: _navigateToStatsScreen,
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
}
