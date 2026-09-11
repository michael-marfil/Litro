import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/maintenance.dart';
import '../domain/fuel_stats.dart';
import 'database.dart';

/// Local notifications for maintenance reminders.
abstract final class Notifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _prefKey = 'reminders_enabled';
  static const _leadDays =
      7; // How far ahead of the estimated due date to warn.
  static const _warnKm =
      200; // Warn immediately if a service is within this many km.

  static Future<bool> remindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> setRemindersEnabled(AppDatabase db, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);

    if (value) {
      await sync(db);
    } else {
      await _plugin.cancelAll();
    }
  }

  /// The wording for one reminder, built from real numbers.
  static ({String title, String body}) messageFor(
    MaintenanceItem item,
    DateTime dueDate,
    String bikeName,
    int? currentOdo,
  ) {
    final km = Maintenance.kmRemaining(item, currentOdo);
    final date = DateFormat('d MMM').format(dueDate);

    final body = km == null
        ? '$bikeName · due around $date'
        : '$bikeName · about ${NumberFormat.decimalPattern().format(km)} km '
              'to go, around $date at your current pace';

    return (title: '${item.name} due soon', body: body);
  }

  /// The soonest upcoming reminder, if there is one.
  static Future<({String name, DateTime date})?> nextDue(AppDatabase db) async {
    final now = DateTime.now();
    ({String name, DateTime date})? soonest;

    for (final bike in await db.select(db.bikes).get()) {
      final entries = await (db.select(
        db.fuelEntries,
      )..where((t) => t.bikeId.equals(bike.id))).get();
      final items = await (db.select(
        db.maintenanceItems,
      )..where((t) => t.bikeId.equals(bike.id))).get();

      for (final item in items) {
        final due = Maintenance.estimatedDueDate(item, entries, now);
        if (due == null) continue;
        if (soonest == null || due.isBefore(soonest.date)) {
          soonest = (name: item.name, date: due);
        }
      }
    }

    return soonest;
  }

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'maintenance',
      'Maintenance reminders',
      channelDescription: 'Tells you when a service is coming due.',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  /// Call once, before runApp.
  static Future<void> init() async {
    tz_data.initializeTimeZones();

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  /// Android 13+ asks at runtime. False means the user declined.
  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;
    return await android.requestNotificationsPermission() ?? false;
  }

  /// Fires immediately. For proving the pipe works.
  static Future<void> showNow(String title, String body) {
    return _plugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: _details,
    );
  }

  /// Schedules one reminder for [item], at 9am on its estimated due date.
  /// Silently skips date in the past — you can't schedule backwards.
  static Future<void> _scheduleFor(
    MaintenanceItem item,
    DateTime dueDate,
    String bikeName,
    int? currentOdo,
  ) async {
    final warnOn = dueDate.subtract(const Duration(days: _leadDays));
    final when = tz.TZDateTime.from(
      DateTime(warnOn.year, warnOn.month, warnOn.day, 9),
      tz.local,
    );
    if (!when.isAfter(tz.TZDateTime.now(tz.local))) return;

    final message = messageFor(item, dueDate, bikeName, currentOdo);

    await _plugin.zonedSchedule(
      id: item.id,
      title: message.title,
      body: message.body,
      scheduledDate: when,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Rebuilds every scheduled reminder from the current state of the database.
  ///
  /// Cheap and idempotent: cancel everything, then reschedule from scratch.
  /// Call it after anything that could move a due date.
  static Future<void> sync(AppDatabase db, {bool warnNow = false}) async {
    await _plugin.cancelAll();
    if (!await remindersEnabled()) return;

    final now = DateTime.now();

    for (final bike in await db.select(db.bikes).get()) {
      final entries = await (db.select(
        db.fuelEntries,
      )..where((t) => t.bikeId.equals(bike.id))).get();

      final items = await (db.select(
        db.maintenanceItems,
      )..where((t) => t.bikeId.equals(bike.id))).get();

      final currentOdo = FuelStats.currentOdometer(entries);

      for (final item in items) {
        final due = Maintenance.estimatedDueDate(item, entries, now);
        if (due == null) continue;
        await _scheduleFor(item, due, bike.nickname, currentOdo);

        // A fill-up is the only moment we know the real odometer.
        if (warnNow) {
          final km = Maintenance.kmRemaining(item, currentOdo);
          if (km != null && km > 0 && km <= _warnKm) {
            final message = messageFor(item, due, bike.nickname, currentOdo);
            await _plugin.show(
              id: item.id + 10000,
              title: message.title,
              body: message.body,
              notificationDetails: _details,
            );
          }
        }
      }
    }
  }

  /// What's currently scheduled. For checking the thing actually worked.
  static Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();
}
