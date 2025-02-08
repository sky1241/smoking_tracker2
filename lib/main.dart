import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  bool? isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  bool? hasCompletedSchedule = prefs.getBool('hasCompletedSchedule') ?? false;

  runApp(SmokingTrackerApp(
    isFirstLaunch: isFirstLaunch,
    hasCompletedSchedule: hasCompletedSchedule,
  ));
}

class SmokingTrackerApp extends StatelessWidget {
  final bool isFirstLaunch;
  final bool hasCompletedSchedule;

  SmokingTrackerApp({required this.isFirstLaunch, required this.hasCompletedSchedule});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smoking Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: isFirstLaunch
          ? WelcomeScreen()
          : hasCompletedSchedule
          ? MainScreen()  // Si déjà programmé, on va direct sur MainScreen
          : HomeScreen(), // Sinon, on commence avec HomeScreen
      routes: {
        "/main": (context) => MainScreen(),
        "/schedule": (context) => ScheduledScreen(),
      },
    );
  }
}
