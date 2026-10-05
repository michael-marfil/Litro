import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../data/backup.dart';
import '../data/database.dart';
import '../data/notifications.dart';
import '../widgets/app_feedback.dart';

import 'restore_flow.dart';

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
  bool _reminders = false;
  ({String name, DateTime date})? _next;
  int _scheduled = 0;

  Future<void> _backup() async {
    var saved = false;

    try {
      await runWithLoader(context, () async {
        final file = await Backup.writeFile(widget.db);
        final result = await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'application/json')],
            subject: 'Litro backup',
          ),
        );

        // Only count it if the file actually went somewhere. Opening the 
        // share sheet and backing out is not a backup.
        if (result.status == ShareResultStatus.success) {
          await Backup.markBackedUp();
          saved = true;
        }
      });
    } catch (e) {
      if (mounted) showAppAlert(context, 'Backup failed', kind: AlertKind.error);
      return;
    }

    if (!mounted) return;
    if (saved) showAppAlert(context, 'Backed up');
  }

  Future<void> _restore() async {
    final restored = await runRestoreFlow(context, widget.db);
    if (!restored || !mounted) return;

    Navigator.of(context).pop();
    showAppAlert(context, 'Restored');
  }

  @override
  void initState() {
    super.initState();
    _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final on = await Notifications.remindersEnabled();
    final next = on ? await Notifications.nextDue(widget.db) : null;
    final count = on ? (await Notifications.pending()).length : 0;
    if (!mounted) return;
    setState(() {
      _reminders = on;
      _next = next;
      _scheduled = count;
    });
  }

  Future<void> _toggleReminders(bool value) async {
    if (value) {
      final granted = await Notifications.requestPermission();
      if (!mounted) return;
      if (!granted) {
        showAppAlert(
          context,
          'Notifications are turned off for Litro',
          kind: AlertKind.error,
        );
        return;
      }
    }

    await Notifications.setRemindersEnabled(widget.db, value);
    await _loadReminderState();
  }

  String get _reminderSubtitle {
    if (!_reminders) return 'Turn on to be reminded before a service.';

    final next = _next;
    if (next == null) return 'On — nothing due yet.';

    final date = DateFormat('d MMM').format(next.date);
    final others = _scheduled > 1 ? ' · +${_scheduled - 1} more' : '';
    return 'Next: ${next.name}, $date$others';
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              Icons.notifications_none,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Maintenance reminders'),
            subtitle: Text(_reminderSubtitle),
            value: _reminders,
            onChanged: _busy == null ? _toggleReminders : null,
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