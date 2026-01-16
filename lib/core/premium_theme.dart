import 'package:fluent_ui/fluent_ui.dart';

/// Premium Minimal Theme
/// Inspired by: Modern SaaS Dashboards, Clean UI, Soft Pastels
/// Colors: Soft Gradients + Muted Semantic Colors
/// Vibe: Modern, Airy, Professional, SaaS-style
class PremiumTheme {
  // ===== CORE COLORS =====
  static const Color primaryBlack = Color(0xFF1F2937); // Soft black (not pure)
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color primaryAccent = Color(0xFF6366F1); // Indigo/Purple
  static const Color accentHover = Color(0xFF4F46E5);
  static const Color accentPressed = Color(0xFF4338CA);
  static const Color accentDisabledLight = Color(0xFFE0E7FF);
  static const Color accentDisabledDark = Color(0xFF312E81);

  // ===== BACKGROUND GRADIENTS (Pastel Theme) =====
  static const Color gradientStart = Color(0xFFFFF1EB); // Soft peach
  static const Color gradientEnd = Color(0xFFF8F0FC); // Soft lavender
  static const Color gradientMid = Color(0xFFFDF4FF); // Light pink

  // Background & Surface Colors
  static const Color backgroundColor = Color(0xFFFAFAFB); // Warm gray-white
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure white cards
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color sectionBackground = Color(
    0xFFF3F4F6,
  ); // Section containers

  // Dark Mode Core Colors
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1F2937);

  // ===== TEXT COLORS (No Pure Black) =====
  static const Color textPrimary = Color(0xFF1F2937); // Soft black
  static const Color textSecondary = Color(0xFF6B7280); // Muted gray
  static const Color textTertiary = Color(0xFF9CA3AF); // Light gray
  static const Color textMuted = Color(0xFFD1D5DB); // Very light
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // ===== ACCENT & BORDER COLORS =====
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color dividerColor = Color(0xFFF3F4F6);
  static const Color iconGray = Color(0xFF9CA3AF);

  // ===== SEMANTIC COLORS (Muted & Soft) =====
  static const Color successGreen = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warningAmber = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color errorRed = Color(0xFFEF4444); // Soft red
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color infoBlue = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFFDBEAFE);

  // ===== GRADIENT STAT CARD COLORS =====
  static const List<Color> gradientBlue = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];
  static const List<Color> gradientPink = [
    Color(0xFFF093FB),
    Color(0xFFF5576C),
  ];
  static const List<Color> gradientRed = [Color(0xFFFF6B6B), Color(0xFFEE5A5A)];
  static const List<Color> gradientGreen = [
    Color(0xFF11998E),
    Color(0xFF38EF7D),
  ];
  static const List<Color> gradientOrange = [
    Color(0xFFFFB347),
    Color(0xFFFFCC33),
  ];
  static const List<Color> gradientPurple = [
    Color(0xFF8B5CF6),
    Color(0xFFA855F7),
  ];

  // ===== SHADOW DEFINITIONS - Ultra Soft =====
  static const shadow = BoxShadow(
    color: Color(0x08000000), // 3% opacity
    blurRadius: 24,
    offset: Offset(0, 4),
    spreadRadius: 0,
  );

  static const cardShadow = BoxShadow(
    color: Color(0x06000000), // 2.5% opacity
    blurRadius: 20,
    offset: Offset(0, 2),
    spreadRadius: 0,
  );

  static const elevatedShadow = BoxShadow(
    color: Color(0x0A000000), // 4% opacity
    blurRadius: 32,
    offset: Offset(0, 8),
    spreadRadius: -4,
  );

  static const softGlow = BoxShadow(
    color: Color(0x12667EEA), // Colored glow
    blurRadius: 40,
    offset: Offset(0, 12),
    spreadRadius: -8,
  );

  // ===== BORDER RADIUS - Modern Rounded =====
  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusPill = 100.0; // For pill buttons/badges

  // ===== SPACING SYSTEM =====
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

  /// Gradient Card Decoration (for stat cards)
  static BoxDecoration gradientCardDecoration(List<Color> gradientColors) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          gradientColors[0].withValues(alpha: 0.12),
          gradientColors[1].withValues(alpha: 0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadiusLarge),
      border: Border.all(
        color: gradientColors[0].withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: gradientColors[0].withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Pill Badge Decoration (for status badges)
  static BoxDecoration pillBadgeDecoration({
    required Color backgroundColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadiusPill),
      border:
          borderColor != null ? Border.all(color: borderColor, width: 1) : null,
    );
  }

  /// Section Container Decoration (for dashboard sections)
  static BoxDecoration sectionDecoration() {
    return BoxDecoration(
      color: sectionBackground,
      borderRadius: BorderRadius.circular(borderRadiusLarge),
      boxShadow: const [
        BoxShadow(
          color: Color(0x04000000),
          blurRadius: 20,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  /// Modern Icon Container Decoration
  static BoxDecoration iconContainerDecoration(List<Color> gradientColors) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: gradientColors[0].withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Soft Background Gradient for pages
  static BoxDecoration pageGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientMid, gradientEnd],
        stops: [0.0, 0.5, 1.0],
      ),
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
