import 'package:flutter/material.dart';
// import 'package:litro/screens/intro_screen.dart';
import 'theme/app_theme.dart';
import 'data/database.dart';
import 'data/notifications.dart';
import 'screens/home_screen.dart';
// import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  await Notifications.init();
  await Notifications.sync(db);
  runApp(LitroApp(db: db));
}

class LitroApp extends StatelessWidget {
  const LitroApp({super.key, required this.db});

  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Litro',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: HomeScreen(db:db),
      // home: IntroScreen(db: db),
      // home: const DashboardScreen(),
    );
  }
}
