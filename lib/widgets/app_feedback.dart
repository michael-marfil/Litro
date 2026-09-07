import 'package:flutter/material.dart';

enum AlertKind { success, error, info }

/// A brief banner near the top of the screen. Lives in the root overlay, so it
/// survives the sheet that triggered it being dismissed.
void showAppAlert(
  BuildContext context,
  String message, {
  AlertKind kind = AlertKind.success,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _AlertBanner(
      message: message,
      kind: kind,
      onDone: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

/// Runs [work] behind a full-screen blocking spinner.
/// 
/// Doesn't slow the work down — it only keeps the spinner up long enough to
/// be seen, so a fast operation doesn't flash and look like a glitch.
Future<void> runWithLoader(
  BuildContext context,
  Future<void> Function() work,
) async {
  final navigator = Navigator.of(context, rootNavigator: true);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xCC000000),
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );

  final started = DateTime.now();
  try {
    await work();
  } finally {
    final elapsed = DateTime.now().difference(started);
    const minimum = Duration(milliseconds: 500);
    if (elapsed < minimum) {
      await Future<void>.delayed(minimum - elapsed);
    }
    navigator.pop();
  }
}

class _AlertBanner extends StatefulWidget {
  const _AlertBanner({
    required this.message,
    required this.kind,
    required this.onDone,
  });

  final String message;
  final AlertKind kind;
  final VoidCallback onDone;

  @override
  State<_AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<_AlertBanner>
  with SingleTickerProviderStateMixin {
    late final AnimationController _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    @override
    void initState() {
      super.initState();
      _play();
    }
    
    Future<void> _play() async {
      await _controller.forward();
      await Future<void>.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return;
      await _controller.reverse();
      widget.onDone();
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);

      final (Color accent, IconData icon) = switch (widget.kind) {
        AlertKind.success => (
          theme.colorScheme.primary,
          Icons.check_circle_outline,
        ),
        AlertKind.error => (theme.colorScheme.error, Icons.error_outline),
        AlertKind.info => (
          theme.colorScheme.onSurfaceVariant,
          Icons.info_outline,
        ),
      };

      return Positioned(
        top: MediaQuery.paddingOf(context).top + 68,
        left: 20,
        right: 20,
        child: FadeTransition(
          opacity: _controller,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.35),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: _controller, curve: Curves.easeOut),
            ),
            child: Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width - 48,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withValues(alpha: 0.55)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 18, color: accent),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }