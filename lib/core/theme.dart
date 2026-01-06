import 'package:fluent_ui/fluent_ui.dart';

class AppTheme {
  // Primary accent color matching "View All TNs" button
  static const Color primaryColor = Color(0xFF0078D4); // Fluent blue

  // Font fallback list for special characters like ₹
  static const List<String> fontFallbacks = [
    'Segoe UI',
    'Arial',
    'Noto Sans',
    'Roboto',
  ];

  // Base typography with font fallback
  static Typography get typography => Typography.raw(
    caption: TextStyle(fontSize: 12, fontFamilyFallback: fontFallbacks),
    body: TextStyle(fontSize: 14, fontFamilyFallback: fontFallbacks),
    bodyStrong: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: fontFallbacks,
    ),
    bodyLarge: TextStyle(fontSize: 18, fontFamilyFallback: fontFallbacks),
    subtitle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: fontFallbacks,
    ),
    title: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: fontFallbacks,
    ),
    titleLarge: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: fontFallbacks,
    ),
    display: TextStyle(
      fontSize: 68,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: fontFallbacks,
    ),
  );

  // Use FluentThemeData (from fluent_ui) instead of Material's ThemeData
  static FluentThemeData lightTheme = FluentThemeData(
    brightness: Brightness.light,
    accentColor: AccentColor.swatch({'normal': primaryColor}),
    typography: typography,
  );

  static FluentThemeData darkTheme = FluentThemeData(
    brightness: Brightness.dark,
    accentColor: AccentColor.swatch({'normal': primaryColor}),
    typography: typography,
  );
}

/// Custom button style for consistent appearance across the app
class AppButtonStyle {
  /// Style for primary action buttons (FilledButton)
  static ButtonStyle get filledButtonStyle => ButtonStyle(
    textStyle: ButtonState.all(
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    padding: ButtonState.all(
      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
  );

  /// Style for secondary action buttons (Button)
  static ButtonStyle get secondaryButtonStyle => ButtonStyle(
    textStyle: ButtonState.all(
      const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    padding: ButtonState.all(
      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    ),
  );
}

/// Wrapper widgets for consistent button styling

/// Primary FilledButton with centered text
class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: AppButtonStyle.filledButtonStyle,
      child: Center(child: child),
    );
  }
}

/// Secondary Button with centered text
class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const SecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: onPressed,
      style: AppButtonStyle.secondaryButtonStyle,
      child: Center(child: child),
    );
  }
}
