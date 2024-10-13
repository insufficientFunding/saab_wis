import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static ThemeData? _theme;

  static ColorScheme get colorScheme => _theme?.colorScheme ?? const ColorScheme.light();
  static TextTheme get textTheme => _theme?.textTheme ?? _buildTextTheme();

  static const Color primaryColor = Color(0xFF002D65);
  static const Color secondaryColor = Color(0xFFCD1041);
  static const Color tertiaryColor = Color(0xFFe6B23B);
  static const Color quaternaryColor = Color(0xFFD1D3D4);

  static List<Color> get backgroundColorsLight => [
        const Color(0xFFFFFFFF),
        const Color(0xFFF4F3F8),
        const Color(0xFFE9E8ED),
        const Color(0xFFE0DFE4),
        const Color(0xFFD6D5DA),
      ];

  static List<Color> get backgroundColorsDark => [
        const Color(0xFF121212),
        const Color(0xFF1E1E1E),
        const Color(0xFF2A2A2A),
        const Color(0xFF363636),
        const Color(0xFF424242),
      ];

  static TextTheme _buildTextTheme() {
    font(double fontSize, {FontWeight? weight}) => GoogleFonts.urbanist(
          fontSize: fontSize,
          fontWeight: weight,
          color: colorScheme.onSurface,
        );
    fontSmall(double fontSize, {FontWeight? weight}) => GoogleFonts.atkinsonHyperlegible(
          fontSize: fontSize,
          fontWeight: weight,
          color: colorScheme.onSurface,
        );

    return GoogleFonts.atkinsonHyperlegibleTextTheme().copyWith(
      displayLarge: font(57, weight: FontWeight.w300),
      displayMedium: font(45, weight: FontWeight.w300),
      displaySmall: font(36, weight: FontWeight.w300),
      headlineLarge: font(32, weight: FontWeight.w500),
      headlineMedium: font(28, weight: FontWeight.w500),
      headlineSmall: font(24, weight: FontWeight.w500),
      titleLarge: font(22, weight: FontWeight.w600),
      titleMedium: font(16, weight: FontWeight.w500),
      titleSmall: font(14, weight: FontWeight.w500),
      labelLarge: fontSmall(12, weight: FontWeight.w500),
      labelMedium: fontSmall(11, weight: FontWeight.w500),
      labelSmall: fontSmall(10, weight: FontWeight.w500),
      bodyLarge: fontSmall(16),
      bodyMedium: fontSmall(14),
      bodySmall: fontSmall(12),
    );
  }

  static ThemeData buildTheme({required Brightness brightness}) {
    final backgroundColors = brightness == Brightness.light ? backgroundColorsLight : backgroundColorsDark;
    _theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        dynamicSchemeVariant: DynamicSchemeVariant.content,
        contrastLevel: 0.35,
        brightness: brightness,
        seedColor: primaryColor,
        primary: primaryColor,
        primaryFixed: primaryColor,
        secondary: secondaryColor,
        secondaryFixed: secondaryColor,
        tertiaryFixed: tertiaryColor,
        tertiary: tertiaryColor,
        surfaceContainerLowest: backgroundColors[0],
        surfaceContainerLow: backgroundColors[1],
        surfaceContainer: backgroundColors[2],
        surfaceContainerHigh: backgroundColors[3],
        surfaceContainerHighest: backgroundColors[4],
      ),
      cardTheme: const CardTheme(
        elevation: 2,
        surfaceTintColor: primaryColor,
      ),
      dividerTheme: const DividerThemeData(
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
        space: 0,
      ),
    );

    final textTheme = _buildTextTheme();

    final inputDecorationBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: BorderSide.none,
    );

    final inputDecorationTheme = InputDecorationTheme(
      hintStyle: textTheme.bodyLarge?.apply(color: colorScheme.onSurface.withOpacity(0.5)),
      isDense: true,
      filled: true,
      fillColor: colorScheme.surfaceContainerHigh,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: inputDecorationBorder,
      focusedBorder: inputDecorationBorder,
      enabledBorder: inputDecorationBorder,
      errorBorder: inputDecorationBorder,
      focusedErrorBorder: inputDecorationBorder,
      disabledBorder: inputDecorationBorder,
    );

    _theme = _theme!.copyWith(
        textTheme: textTheme,
        inputDecorationTheme: inputDecorationTheme,
        dropdownMenuTheme: DropdownMenuThemeData(
          inputDecorationTheme: inputDecorationTheme,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: colorScheme.surfaceContainerLow,
        ),
        tooltipTheme: TooltipThemeData(
          textStyle: textTheme.bodyMedium?.apply(color: colorScheme.onSurface),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        searchBarTheme: SearchBarThemeData(
          textStyle: WidgetStatePropertyAll(textTheme.bodyLarge?.apply(color: colorScheme.onSurface)),
          hintStyle: WidgetStatePropertyAll(textTheme.bodyLarge?.apply(color: colorScheme.onSurface.withOpacity(0.5))),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
        ));

    return _theme!;
  }
}
