// Visual foundation: industrial grit, restrained accent, utilitarian type.
import 'package:flutter/material.dart';

class IronColors {
  static const background = Color(0xFF14161A);
  static const surface = Color(0xFF1E2126);
  static const surfaceRaised = Color(0xFF272B31);
  static const border = Color(0xFF3A3F47);
  static const text = Color(0xFFE8E4DA);
  static const textMuted = Color(0xFF9AA0A8);
  static const accent = Color(0xFFC8641F); // rust orange
  static const accentBright = Color(0xFFF2A35A);
  static const hydration = Color(0xFF4FA3D1);
  static const fatigue = Color(0xFFE0A040);
  static const success = Color(0xFF6FB56A);
  static const locked = Color(0xFF5C6168);
  static const press = Color(0xFFD08A4A);
  static const isolation = Color(0xFF6FA8C9);
  static const recovery = Color(0xFF6FB5A0);
  static const xp = Color(0xFFE6C15A);
}

class IronSpacing {
  static const xs = 4.0, s = 8.0, m = 12.0, l = 16.0, xl = 24.0, xxl = 32.0;
}

class IronRadius {
  static const small = 6.0, panel = 10.0, modal = 14.0;
}

class IronBreakpoints {
  static const compact = 700.0;
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;
}

ThemeData buildIronTheme() {
  const scheme = ColorScheme.dark(
    primary: IronColors.accent,
    onPrimary: Colors.white,
    secondary: IronColors.accentBright,
    surface: IronColors.surface,
    onSurface: IronColors.text,
    error: Color(0xFFD9645A),
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: IronColors.background,
    fontFamily: null,
  );
  final text = base.textTheme.apply(
    bodyColor: IronColors.text,
    displayColor: IronColors.text,
  );
  return base.copyWith(
    textTheme: text.copyWith(
      displayLarge: text.displayLarge?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
      ),
      headlineMedium: text.headlineMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
      titleLarge: text.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
      ),
      titleMedium: text.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
      labelLarge: text.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
      labelSmall: text.labelSmall?.copyWith(
        color: IronColors.textMuted,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerColor: IronColors.border,
    dialogTheme: const DialogThemeData(
      backgroundColor: IronColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(IronRadius.modal)),
        side: BorderSide(color: IronColors.border),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: IronColors.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(IronRadius.small)),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: IronColors.text,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: IronColors.border, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(IronRadius.small)),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: IronColors.accentBright,
        minimumSize: const Size(48, 44),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? IronColors.accentBright
            : IronColors.textMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? IronColors.accent.withValues(alpha: 0.5)
            : IronColors.surfaceRaised,
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: IronColors.accent,
      thumbColor: IronColors.accentBright,
      inactiveTrackColor: IronColors.surfaceRaised,
    ),
    focusColor: IronColors.accentBright.withValues(alpha: 0.35),
  );
}
