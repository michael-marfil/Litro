import 'package:flutter/material.dart';

class CoachStep {
  const CoachStep({
    required this.targetKey,
    required this.mascot,
    required this.title,
    required this.body,
  });

  final GlobalKey targetKey;
  final String mascot;
  final String title;
  final String body;
}

/// A multi-step spotlight tour. Each step highlights one widget, located by
/// its [GlobalKey].
class CoachOverlay extends StatefulWidget {
  const CoachOverlay({
    super.key,
    required this.steps,
    required this.onDone,
  });

  final List<CoachStep> steps;
  final VoidCallback onDone;

  @override
  State<CoachOverlay> createState() => _CoachOverlayState();
}

class _CoachOverlayState extends State<CoachOverlay> {
  int _index = 0;
  Rect? _target;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final box = widget.steps[_index].targetKey.currentContext
        ?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !mounted) return;
    setState(() => _target = box.localToGlobal(Offset.zero) & box.size);
  }

  void _next() {
    if (_index == widget.steps.length - 1) {
      widget.onDone();
      return;
    }
    setState(() {
      _index++;
      _target = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = widget.steps[_index];
    final target = _target;

    if (target == null) return const SizedBox.shrink();

    final hole = target.inflate(10);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final showBelow = hole.bottom < screenHeight * 0.45;
    final isLast = _index == widget.steps.length - 1;

    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          step.mascot,
          height: 110,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(height: 12),
        Text(step.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          step.body,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text(
              '${_index + 1} OF ${widget.steps.length}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (!isLast)
              TextButton(
                onPressed: widget.onDone,
                child: Text(
                  'SKIP',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _next,
              child: Text(isLast ? 'GOT IT' : 'NEXT'),
            ),
          ],
        ),
      ],
    );

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _SpotlightPainter(
              hole: hole,
              scrim: const Color(0xFF000000).withValues(alpha: 0.86),
              ring: theme.colorScheme.primary,
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          top: showBelow ? hole.bottom + 24 : null,
          bottom: showBelow ? null : screenHeight - hole.top + 24,
          child: card,
        ),
      ],
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.hole,
    required this.scrim,
    required this.ring,
  });

  final Rect hole;
  final Color scrim;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(hole, const Radius.circular(18));

    final full = Path()..addRect(Offset.zero & size);
    final cut = Path()..addRRect(rrect);

    canvas.drawPath(
      Path.combine(PathOperation.difference, full, cut),
      Paint()..color = scrim,
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = ring.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.hole != hole;
}