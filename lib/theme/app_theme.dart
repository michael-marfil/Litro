import 'package:flutter/material.dart';
import 'tokens.dart';

/// Litro's Material theme - the one place raw tokens become semantic roles.
abstract final class AppTheme {
	static final ThemeData dark = ThemeData(
		colorScheme: _darkScheme,
		scaffoldBackgroundColor: AppColors.ink,
		textTheme: _textTheme,
		inputDecorationTheme: InputDecorationTheme(
			filled: true,
			fillColor: AppColors.ink,
			contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
			labelStyle: const TextStyle(color: AppColors.muted),
			enabledBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(12),
				borderSide: BorderSide(color: AppColors.muted.withValues(alpha: 0.25)),
			),
			focusedBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(12),
				borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
			),
			errorBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(12),
				borderSide: const BorderSide(color: AppColors.coral),
			),
			focusedErrorBorder: OutlineInputBorder(
				borderRadius: BorderRadius.circular(12),
				borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
			),
		),
	);

	static final ColorScheme _darkScheme = ColorScheme.fromSeed(
		seedColor: AppColors.cyan,
		brightness: Brightness.dark,
	).copyWith(
		primary: AppColors.cyan,
		onPrimary: AppColors.ink,
		surface: AppColors.ink,
		onSurface: AppColors.text,
		surfaceContainer: AppColors.surface,
		error: AppColors.coral,
		onError: AppColors.ink,
		outline: AppColors.muted,
		onSurfaceVariant: AppColors.muted,
	);

	static const _display = 'JetBrainsMono';
	static const _heading = 'SpaceGrotesk';
	static const _body = 'Inter';

	static const TextTheme _textTheme = TextTheme(
			// Hero numbers - km/L, stat tiles. Tight leading so big digits don't float.
			displayLarge: TextStyle(
				fontFamily: _display,
				fontSize: 57,
				fontWeight: FontWeight.w700,
				height: 1.0,
			),
			displayMedium: TextStyle(
				fontFamily: _display,
				fontSize: 45,
				fontWeight: FontWeight.w700,
				height: 1.0,
			),
			displaySmall: TextStyle(
				fontFamily: _display,
				fontSize: 32,
				fontWeight: FontWeight.w700,
			),

			headlineMedium: TextStyle(
				fontFamily: _heading,
				fontSize: 28,
				fontWeight: FontWeight.w700,
			),
			headlineSmall: TextStyle(
				fontFamily: _heading,
				fontSize: 22,
				fontWeight: FontWeight.w500,
			),

			titleLarge: TextStyle(
				fontFamily: _heading,
				fontSize: 20,
				fontWeight: FontWeight.w700,
			),
			titleMedium: TextStyle(
				fontFamily: _heading,
				fontSize: 16,
				fontWeight: FontWeight.w500,
			),

			bodyLarge: TextStyle(fontFamily: _body, fontSize: 16),
			bodyMedium: TextStyle(fontFamily: _body, fontSize: 14),
			bodySmall: TextStyle(fontFamily: _body, fontSize: 12),

			// Buttons.
			labelLarge: TextStyle(
				fontFamily: _body,
				fontSize: 14,
				fontWeight: FontWeight.w500,
			),
			// Tracked-out micro-labels: LAST FULL TANK, COST / KM.
			labelMedium: TextStyle(
				fontFamily: _display,
				fontSize: 12,
				letterSpacing: 1.5,
			),
			labelSmall: TextStyle(
				fontFamily: _display,
				fontSize: 11,
				letterSpacing: 1.5,
			),
	);
}