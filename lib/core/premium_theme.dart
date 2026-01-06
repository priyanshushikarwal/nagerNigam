import 'package:fluent_ui/fluent_ui.dart';

/// Premium Minimal Theme
/// Inspired by: Apple iOS, Clean SAAS UI, Modern Fintech
/// Colors: White + Black (High Contrast Minimal)
/// Accent: Neutral Grays
/// Vibe: Elegant, Premium, Calm, Minimal, Luxury, Balanced
class PremiumTheme {
  // Primary Colors - High Contrast Minimal
  static const Color primaryBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color primaryAccent = Color(0xFF2563EB);
  static const Color accentHover = Color(0xFF1D4ED8);
  static const Color accentPressed = Color(0xFF1E3A8A);
  static const Color accentDisabledLight = Color(0xFFCBD5F5);
  static const Color accentDisabledDark = Color(0xFF1B2B55);

  // Background & Surface Colors
  static const Color backgroundColor = Color(0xFFFFFFFF); // Pure white
  static const Color cardBackground = Color(0xFFF5F5F5); // Soft gray
  static const Color surfaceLight = Color(0xFFFAFAFA);

  // Dark Mode Core Colors
  static const Color darkBackground = Color(0xFF0F1114);
  static const Color darkCard = Color(0xFF181B20);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000); // Black
  static const Color textSecondary = Color(0xFF898989); // Neutral gray
  static const Color textTertiary = Color(0xFFBDBDBD); // Light gray
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9DA7B4);

  // Accent & Border Colors
  static const Color borderColor = Color(0xFFE8E8E8);
  static const Color dividerColor = Color(0xFFF0F0F0);
  static const Color iconGray = Color(0xFF898989);

  // Semantic Colors (Minimal & Muted)
  static const Color successGreen = Color(0xFF2E7D32); // Muted green
  static const Color warningOrange = Color(0xFFE65100); // Muted orange
  static const Color errorRed = Color(0xFFC62828); // Muted red
  static const Color infoBlue = Color(0xFF1565C0); // Muted blue

  // Shadow Definition - Soft & Subtle
  static const shadow = BoxShadow(
    color: Color(0x12000000), // 7% opacity
    blurRadius: 30,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const cardShadow = BoxShadow(
    color: Color(0x0A000000), // 4% opacity
    blurRadius: 25,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  static const elevatedShadow = BoxShadow(
    color: Color(0x14000000), // 8% opacity
    blurRadius: 40,
    offset: Offset(0, 6),
    spreadRadius: -2,
  );

  // Border Radius - 16px rounded
  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusLarge = 20.0;

  // Spacing System - Airy & Balanced
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  static FluentThemeData get fluentTheme => _buildLightTheme();
  static FluentThemeData get lightTheme => _buildLightTheme();
  static FluentThemeData get darkTheme => _buildDarkTheme();

  static FluentThemeData _buildLightTheme() {
    return FluentThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardBackground,
      accentColor: _lightAccent,
      typography: _buildTypography(
        primary: textPrimary,
        secondary: textSecondary,
      ),
      iconTheme: const IconThemeData(color: iconGray, size: 20),
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: pureWhite,
        overlayBackgroundColor: cardBackground,
        highlightColor: cardBackground,
        animationDuration: const Duration(milliseconds: 200),
        selectedIconColor: WidgetStatePropertyAll(primaryAccent),
        unselectedIconColor: WidgetStatePropertyAll(iconGray),
        selectedTextStyle: WidgetStatePropertyAll(
          const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryAccent,
          ),
        ),
        unselectedTextStyle: WidgetStatePropertyAll(
          const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
        ),
      ),
      buttonTheme: ButtonThemeData(
        defaultButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return accentDisabledLight;
            }
            if (states.contains(WidgetState.pressed)) {
              return accentPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return accentHover;
            }
            return primaryAccent;
          }),
          foregroundColor: WidgetStatePropertyAll(pureWhite),
          padding: WidgetStatePropertyAll(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadiusSmall),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        filledButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return accentDisabledLight;
            }
            if (states.contains(WidgetState.pressed)) {
              return accentPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return accentHover;
            }
            return primaryAccent;
          }),
          foregroundColor: WidgetStatePropertyAll(pureWhite),
          padding: WidgetStatePropertyAll(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadiusSmall),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  static FluentThemeData _buildDarkTheme() {
    return FluentThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      cardColor: darkCard,
      accentColor: _darkAccent,
      typography: _buildTypography(
        primary: darkTextPrimary,
        secondary: darkTextSecondary,
      ),
      iconTheme: const IconThemeData(color: darkTextSecondary, size: 20),
      navigationPaneTheme: NavigationPaneThemeData(
        backgroundColor: darkBackground,
        overlayBackgroundColor: darkCard,
        highlightColor: const Color(0xFF1E2228),
        animationDuration: const Duration(milliseconds: 200),
        selectedIconColor: WidgetStatePropertyAll(primaryAccent),
        unselectedIconColor: WidgetStatePropertyAll(darkTextSecondary),
        selectedTextStyle: WidgetStatePropertyAll(
          const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryAccent,
          ),
        ),
        unselectedTextStyle: WidgetStatePropertyAll(
          const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: darkTextSecondary,
          ),
        ),
      ),
      buttonTheme: ButtonThemeData(
        defaultButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return accentDisabledDark;
            }
            if (states.contains(WidgetState.pressed)) {
              return accentPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return accentHover;
            }
            return primaryAccent;
          }),
          foregroundColor: WidgetStatePropertyAll(pureWhite),
          padding: WidgetStatePropertyAll(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadiusSmall),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        filledButtonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return accentDisabledDark;
            }
            if (states.contains(WidgetState.pressed)) {
              return accentPressed;
            }
            if (states.contains(WidgetState.hovered)) {
              return accentHover;
            }
            return primaryAccent;
          }),
          foregroundColor: WidgetStatePropertyAll(pureWhite),
          padding: WidgetStatePropertyAll(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadiusSmall),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Premium Card Decoration
  static BoxDecoration cardDecoration({Color? color, bool elevated = false}) {
    return BoxDecoration(
      color: color ?? cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [elevated ? elevatedShadow : cardShadow],
    );
  }

  /// Surface Card Decoration (for nested cards)
  static BoxDecoration surfaceDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? pureWhite,
      borderRadius: BorderRadius.circular(borderRadiusSmall),
      border: Border.all(color: borderColor, width: 1),
    );
  }

  /// Info Card Decoration (for alerts/info boxes)
  static BoxDecoration infoCardDecoration(Color accentColor) {
    return BoxDecoration(
      color: accentColor.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(borderRadiusSmall),
      border: Border.all(color: accentColor.withValues(alpha: 0.15), width: 1),
    );
  }

  static AccentColor get _lightAccent => AccentColor.swatch({
    'darkest': const Color(0xFF1E3A8A),
    'darker': const Color(0xFF1D4ED8),
    'dark': accentHover,
    'normal': primaryAccent,
    'light': const Color(0xFF3B82F6),
    'lighter': const Color(0xFF60A5FA),
    'lightest': const Color(0xFF93C5FD),
  });

  static AccentColor get _darkAccent => AccentColor.swatch({
    'darkest': accentPressed,
    'darker': const Color(0xFF1F3B7B),
    'dark': accentHover,
    'normal': primaryAccent,
    'light': const Color(0xFF4F83FF),
    'lighter': const Color(0xFF7CA3FF),
    'lightest': const Color(0xFFAEC5FF),
  });

  static Typography _buildTypography({
    required Color primary,
    required Color secondary,
  }) {
    return Typography.raw(
      display: TextStyle(
        fontFamily: 'Inter',
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: primary,
        letterSpacing: -0.5,
      ),
      title: TextStyle(
        fontFamily: 'Inter',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primary,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: primary,
        letterSpacing: -0.2,
      ),
      subtitle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: primary,
        letterSpacing: 0,
      ),
      body: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primary,
        letterSpacing: 0,
      ),
      bodyStrong: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
        color: primary,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: primary,
        letterSpacing: 0,
      ),
      caption: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: secondary,
        letterSpacing: 0.1,
      ),
    );
  }
}
