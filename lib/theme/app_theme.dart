import 'package:material_ui/material_ui.dart';

class AppTheme {
  static const Color primary = Color(0xFF173B50);
  static const Color secondary = Color(0xFF148B85);
  static const Color background = Color(0xFFF3F6F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF243746);
  static const Color textSecondary = Color(0xFF718096);
  static const Color border = Color(0xFFDCE4EC);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      onPrimary: surface,
      onSurface: textPrimary,
    ),
  );
}
