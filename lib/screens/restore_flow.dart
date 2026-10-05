import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/backup.dart';
import '../data/database.dart';
import '../widgets/app_feedback.dart';

/// Pick a backup file, validate it, confirm, and replace everything
/// 
/// Lives on its own because two screens need it: Settings, and the intro -
/// where someone reinstalling the app has no other way in.
/// 
/// Returns true only if a restore actually happened.
Future<bool> runRestoreFlow(BuildContext context, AppDatabase db) async {
  final picked = await  FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['json'],
  );
  if (picked == null || !context.mounted) return false;

  final BackupPayload payload;
  try {
    payload = Backup.parse(utf8.decode(await picked.readAsBytes()));
  } on FormatException catch (e) {
    if (context.mounted) {
      showAppAlert(context, e.message, kind: AlertKind.error);
    }
    return false;
  } catch (_) {
    if (context.mounted) {
      showAppAlert(context, "That file couldn't be read.", kind: AlertKind.error);
    }
    return false;
  }

  if (!context.mounted) return false;
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

  if (ok != true || !context.mounted) return false;

  await runWithLoader(context, () => Backup.apply(db, payload));
  return true;
}