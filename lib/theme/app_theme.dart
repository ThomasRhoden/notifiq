import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF0E0E0E);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceHigh = Color(0xFF242424);
  static const Color border = Color(0xFF2E2E2E);
  static const Color textPrimary = Color(0xFFF1EFE8);
  static const Color textSecondary = Color(0xFF888780);
  static const Color textTertiary = Color(0xFF4A4A48);

  static const List<Color> accentColors = [
    Color(0xFF5DCAA5), // teal
    Color(0xFF7F77DD), // purple
    Color(0xFF378ADD), // blue
    Color(0xFFD4537E), // pink
    Color(0xFFEF9F27), // amber
    Color(0xFFE24B4A), // red
    Color(0xFFB4B2A9), // gray
    Color(0xFF63C9E0), // cyan
  ];

  static const List<String> accentNames = [
    'Teal', 'Roxo', 'Azul', 'Rosa', 'Âmbar', 'Vermelho', 'Cinza', 'Ciano'
  ];

  static const List<String> iconOptions = [
    '💊', '💧', '💪', '❤️', '⭐', '🔔', '📅', '💡',
    '☀️', '🌙', '🧘', '🏃', '📖', '✅', '🎯', '🙏',
  ];

  static const List<Map<String, String>> soundOptions = [
    {'name': 'Cristal', 'file': 'crystal'},
    {'name': 'Sino suave', 'file': 'soft_bell'},
    {'name': 'Pulso', 'file': 'pulse'},
    {'name': 'Eco', 'file': 'echo'},
    {'name': 'Zen', 'file': 'zen'},
    {'name': 'Padrão', 'file': 'default'},
    {'name': 'Nenhum', 'file': 'none'},
  ];

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          surface: surface,
          primary: Color(0xFF5DCAA5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: textSecondary),
        ),
        dividerColor: border,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: textPrimary, fontSize: 15),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
          labelSmall: TextStyle(color: textTertiary, fontSize: 11),
        ),
      );
}
