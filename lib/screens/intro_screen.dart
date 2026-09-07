import 'package:flutter/material.dart';

import '../data/database.dart';
import 'add_bike_sheet.dart';

class _Slide {
  const _Slide({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;
}

const _slides = <_Slide>[
  _Slide(
    icon: Icons.local_gas_station_outlined,
    title: 'Log a fill-up in\nten seconds',
    body: 'Peso amount, price per litre, odometer. '
        'Litro works out the rest while you type.',
  ),
  _Slide(
    icon: Icons.speed_outlined,
    title: 'Know your real\nkm per litre',
    body: 'Measured between full tanks from your own fill-ups — '
        'not the number on the spec sheet.',
  ),
  _Slide(
    icon: Icons.build_outlined,
    title: 'Never miss an\noil change',
    body: 'Oil, chain, brakes — anything on a schedule. '
        'It counts down using the odometer you already log.',
  ),
  _Slide(
    icon: Icons.wifi_off_outlined,
    title: 'Works at the pump,\nsignal or not',
    body: 'Everything lives on your phone. No account, no server, '
        'nothing to sign up for.',
  ),
];

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.db});

  final AppDatabase db;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _slides.length - 1;

  void _next() {
    if (_isLast) {
      showAddBikeSheet(context, widget.db);
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      style: theme.textTheme.titleLarge,
                      children: [
                        const TextSpan(text: 'Lit'),
                        TextSpan(
                          text: 'ro',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => showAddBikeSheet(context, widget.db),
                    child: Text(
                      'SKIP',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final slide = _slides[i];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            slide.icon,
                            size: 30,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(slide.title, style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 14),
                        Text(
                          slide.body,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _slides.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: i == _page ? 20 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _page
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.35,
                            ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_isLast ? 'ADD YOUR BIKE' : 'NEXT'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
