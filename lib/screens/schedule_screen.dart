import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduledScreen extends StatefulWidget {
  @override
  _ScheduledScreenState createState() => _ScheduledScreenState();
}

class _ScheduledScreenState extends State<ScheduledScreen> {
  Map<String, TimeOfDay?> wakeUpTimes = {};
  Map<String, TimeOfDay?> sleepTimes = {};
  List<String> daysOfWeek = [
    "Lundi",
    "Mardi",
    "Mercredi",
    "Jeudi",
    "Vendredi",
    "Samedi",
    "Dimanche"
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var day in daysOfWeek) {
        wakeUpTimes[day] = _parseTime(prefs.getString('$day-wakeUp'));
        sleepTimes[day] = _parseTime(prefs.getString('$day-sleep'));
      }
    });
  }

  TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null) return null;
    List<String> parts = timeString.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> _pickTime(String day, bool isWakeUp) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isWakeUp) {
          wakeUpTimes[day] = pickedTime;
        } else {
          sleepTimes[day] = pickedTime;
        }
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          '$day-${isWakeUp ? "wakeUp" : "sleep"}',
          "${pickedTime.hour}:${pickedTime.minute}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Votre Plan Actuel")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centrage global
          children: [
            Text(
              "Définissez vos heures de lever et coucher pour chaque jour :",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: daysOfWeek.length,
                itemBuilder: (context, index) {
                  String day = daysOfWeek[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Centrage des lignes
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () => _pickTime(day, true),
                            child: Text(wakeUpTimes[day] == null
                                ? "Définir"
                                : "Lever: ${wakeUpTimes[day]!.format(context)}"),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () => _pickTime(day, false),
                            child: Text(sleepTimes[day] == null
                                ? "Définir"
                                : "Coucher: ${sleepTimes[day]!.format(context)}"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text("Retour", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

