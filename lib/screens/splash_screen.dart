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

    /// Ride in, hold, ride out - three stages on one controller.
    late final Animation<double> _x = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: -3.5,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 25),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 3.5,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 40,
      ),
    ]).animate(_controller);

    /// Fades in during the hold.
    late final Animation<double> _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.38, 0.55, curve: Curves.easeIn),
    );

    @override
    void initState() {
      super.initState();
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2600),
      )..forward();

      // Navigation runs on wall-clock time, not on the animation finishing.
      // Tickers pause when the app isn't visible - if that happened mid-ride,
      // whenComplete would never fire and the splash would hang forever.
      Future.delayed(const Duration(milliseconds: 2850), _open);
    }

    void _open() {
      if (_opened || !mounted) return;
      _opened = true;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (_, _, _) => HomeScreen(db: widget.db),
          transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        ),
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
          body: Stack(
            children: [
              AnimatedBuilder(
                animation: _x,
                builder: (context, child) =>
                    Align(alignment: Alignment(_x.value, 0.0), child: child),
                child: Image.asset('assets/mascot/riding.png', height: 160),
              ),
              Align(
                alignment: const Alignment(0, 0.3),
                child: FadeTransition(
                  opacity: _titleFade,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Lit',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        TextSpan(
                          text: 'ro',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }