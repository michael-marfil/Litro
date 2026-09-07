import 'package:flutter/material.dart';

/// Litro's raw palette. Dark technical, motorcycle instrument cluster.
///
/// These are values, not meanings - widgets should read from
/// `Theme.of(context)`, not from here. See `app_theme.dart`.
abstract final class AppColors {
  /// App background. Near-black with a green cast.
  static const ink = Color(0xFF08110F);

  /// Cards and elevated panels.
  static const surface = Color(0xFF0E1E1D);

  /// Primary. Every number that matters is this colour.
  static const cyan = Color(0xFF37D7E6);

  /// Alerts, warnings, maintenance-due accents.
  static const coral = Color(0xFFFF6B54);

  /// Body text.
  static const text = Color(0xFFDCEAE9);

  /// Labels and secondary text.
  static const muted = Color(0xFF688784);
}