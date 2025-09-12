import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryOrange = Color(0xFFFE8000);
  static const Color primaryOrangeDark = Color(0xFFE67300);
  static const Color primaryOrangeLight = Color(0xFFFF9500);
  
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color secondaryGreen = Color(0xFF10B981);
  static const Color secondaryPurple = Color(0xFF8B5CF6);
  static const Color secondaryCyan = Color(0xFF06B6D4);
  static const Color secondaryRed = Color(0xFFEF4444);
  
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color backgroundWhite = Colors.white;
  static const Color backgroundGrey = Colors.grey;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textWhite = Colors.white;
  
  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  
  // Font Sizes (Base sizes - will be scaled with scaleFactor)
  static const double fontSizeTiny = 7.0;
  static const double fontSizeSmall = 9.0;
  static const double fontSizeBody = 11.0;
  static const double fontSizeMedium = 13.0;
  static const double fontSizeLarge = 15.0;
  static const double fontSizeXLarge = 17.0;
  static const double fontSizeXXLarge = 19.0;
  static const double fontSizeTitle = 21.0;
  static const double fontSizeWelcome = 26.0;
  
  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightNormal = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // Border Radius
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusXXLarge = 20.0;
  static const double radiusCircular = 50.0;
  
  // Spacing
  static const double spacingTiny = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 20.0;
  static const double spacingXXLarge = 24.0;
  static const double spacingXXXLarge = 32.0;
  
  // Icon Sizes
  static const double iconTiny = 16.0;
  static const double iconSmall = 18.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 22.0;
  static const double iconXLarge = 24.0;
  static const double iconXXLarge = 26.0;
  static const double iconXXXLarge = 30.0;
  
  // Shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      spreadRadius: 1,
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryOrange.withOpacity(0.3),
      spreadRadius: 2,
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Text Styles
  static TextStyle getTitleStyle(double scaleFactor) => TextStyle(
    fontSize: fontSizeTitle * scaleFactor,
    fontWeight: fontWeightBold,
    color: textPrimary,
  );
  
  static TextStyle getSubtitleStyle(double scaleFactor) => TextStyle(
    fontSize: fontSizeXLarge * scaleFactor,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
  );
  
  static TextStyle getHeaderStyle(double scaleFactor) => TextStyle(
    fontSize: fontSizeXXLarge * scaleFactor,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
  );
  
  static TextStyle getBodyStyle(double scaleFactor) => TextStyle(
    fontSize: fontSizeBody * scaleFactor,
    fontWeight: fontWeightNormal,
    color: textPrimary,
  );
  
  static TextStyle getCaptionStyle(double scaleFactor) => TextStyle(
    fontSize: fontSizeSmall * scaleFactor,
    fontWeight: fontWeightNormal,
    color: textSecondary,
  );
  
  static TextStyle getLabelStyle(double scaleFactor) => TextStyle(
    fontSize: fontSizeSmall * scaleFactor,
    fontWeight: fontWeightMedium,
    color: textMuted,
  );
  
  static TextStyle getWelcomeStyle(double scaleFactor) => TextStyle(
    fontSize: fontSizeWelcome * scaleFactor,
    fontWeight: fontWeightLight,
    color: textPrimary,
    letterSpacing: -0.5,
  );
  
  // AppBar Styles
  static TextStyle getAppBarTitleStyle(double scaleFactor) => TextStyle(
    fontSize: fontSizeXLarge * scaleFactor,
    fontWeight: fontWeightSemiBold,
    color: textWhite,
  );
  
  // Button Styles
  static TextStyle getButtonTextStyle(double scaleFactor) => TextStyle(
    fontSize: fontSizeLarge * scaleFactor,
    fontWeight: fontWeightSemiBold,
    color: textWhite,
  );
  
  // Icon Circle Styles
  static BoxDecoration getIconCircleDecoration(Color color, double scaleFactor) => BoxDecoration(
    color: color.withOpacity(0.1),
    shape: BoxShape.circle,
  );
  
  static EdgeInsets getIconCirclePadding(double scaleFactor) => EdgeInsets.all(8 * scaleFactor);
  
  // Card Styles
  static BoxDecoration getCardDecoration(double scaleFactor) => BoxDecoration(
    color: backgroundWhite,
    borderRadius: BorderRadius.circular(radiusLarge * scaleFactor),
    boxShadow: cardShadow,
  );
  
  static EdgeInsets getCardPadding(double scaleFactor) => EdgeInsets.all(spacingLarge * scaleFactor);
  
  // Container Styles
  static BoxDecoration getContainerDecoration(double scaleFactor) => BoxDecoration(
    color: backgroundWhite,
    borderRadius: BorderRadius.circular(radiusLarge * scaleFactor),
    boxShadow: cardShadow,
  );
  
  // Gradient Styles
  static LinearGradient getPrimaryGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, primaryOrangeDark],
  );
  
  // Scale Factor Helper
  static double getScaleFactor(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth / 375).clamp(0.8, 1.2);
  }
  
  // Responsive Helper
  static double responsiveSize(double baseSize, double scaleFactor) {
    return baseSize * scaleFactor;
  }
}
