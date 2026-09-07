import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/backup.dart';
import '../data/database.dart';
import '../widgets/app_feedback.dart';

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
  String? _busy; // 'backup' | 'restore' | null

  Future<void> _backup() async {
    try {
      await runWithLoader(context, () async {
        final file = await Backup.writeFile(widget.db);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'application/json')],
            subject: 'Litro backup',
          ),
        );
      });
    } catch (e) {
      if (mounted) showAppAlert(context, 'Backup failed', kind: AlertKind.error);
    }
  }

  Future<void> _restore() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (picked == null || !mounted) return;

    final BackupPayload payload;
    try {
      payload = Backup.parse(utf8.decode(await picked.readAsBytes()));
    } on FormatException catch (e) {
      if (mounted) showAppAlert(context, e.message, kind: AlertKind.error);
      return;
    } catch (_) {
      if (mounted) {
        showAppAlert(
          context,
          "That file couldn't be read.",
          kind: AlertKind.error,
        );
      }
      return;
    }

    if (!mounted) return;
    final theme = Theme.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainer,
        title: const Text('Replace everything?'),
        content: Text(
          'This backup has ${payload.bikes.length} bike(s), '
          '${payload.entries.length} fill-up(s) and '
          '${payload.maintenance.length} maintenance item(s).\n\n'
          'Restoring deletes what is currently on this phone and puts the '
          'backup in its place. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'REPLACE',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;
    if (!mounted) return;

    await runWithLoader(context, () => Backup.apply(widget.db, payload));

    if (!mounted) return;
    Navigator.of(context).pop();
    showAppAlert(context, 'Restored');
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
            trailing: _busy == 'backup'
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : null,
            enabled: _busy == null,
            onTap: _busy == null ? _backup : null,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.settings_backup_restore,
              color: theme.colorScheme.error,
            ),
            title: const Text('Restore from a backup'),
            subtitle: const Text(
              'Replaces everything currently on this phone.',
            ),
            trailing: _busy == 'restore'
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.error,
                    ),
                  )
                : null,
            enabled: _busy == null,
            onTap: _busy == null ? _restore : null,
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