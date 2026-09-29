import 'package:flutter/material.dart';

import '../data/database.dart';
import 'home_screen.dart';

/// Rides the mascot across the screen once, then opens the app.
/// Tap anywhere to skip - you will see this several times a day.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
  with SingleTickerProviderStateMixin {
    late final AnimationController _controller;
    bool _opened = false;

    @override
    void initState() {
      super.initState();
      _controller = 
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1400),
        )..forward().whenComplete(_open);
    }

    void _open() {
      if (_opened || !mounted) return;
      _opened = true;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(db: widget.db)),
      );
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);

      return GestureDetector(
        onTap: _open,
        child: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Constant speed, dead level - a scooter crossing the frame.
              final x = -2.5 + 5.0 * _controller.value;

              return Align(alignment: Alignment(x, 0.1), child: child);
            },
            child: Image.asset('assets/mascot/riding.png', height: 160),
          ),
        ),
      );
    }
  }