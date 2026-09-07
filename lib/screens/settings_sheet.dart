import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/backup.dart';
import '../data/database.dart';

Future<void> showSettingsSheet(BuildContext context, AppDatabase db) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SettingsSheet(db: db),
  );
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key, required this.db});

  final AppDatabase db;
  
  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  bool _busy = false;

  Future<void> _backup() async {
    setState(() => _busy = true);
    try {
      final file = await Backup.writeFile(widget.db);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          subject: 'Litro backup',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Settings', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.ios_share,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Back up my data'),
            subtitle: const Text(
              'Save everything to a file you keep — Drive, email, anywhere.',
            ),
            enabled: !_busy,
            onTap: _busy ? null : _backup,
          ),
          const SizedBox(height: 8),
          Text(
            'Litro stores everything on this phone only. '
            'There is no account and no server, so backup is the only '
            'way your history survives a lost device.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}