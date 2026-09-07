import 'package:flutter/material.dart';
import 'package:litro/screens/intro_screen.dart';

import '../data/database.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key, required this.db});

    final AppDatabase db;

    @override
    Widget build(BuildContext context) {
        return StreamBuilder<List<Bike>>(
            stream: db.select(db.bikes).watch(),
            builder: (context, snapshot) {
                if (!snapshot.hasData) {
                    return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                    );
                }

                if (snapshot.data!.isEmpty) {
                    return IntroScreen(db: db);
                }

                final bikes = snapshot.data!;
                final active = bikes.firstWhere(
                    (b) => b.isActive,
                    orElse: () => bikes.first,
                );
                return DashboardScreen(db: db, bike: active);
            },
        );
    }
}