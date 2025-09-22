import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? shadowColor;
  final double? width;
  final double? height;
  final bool isLoading;
  final Widget? icon;
  final MainAxisAlignment? alignment;
  final bool enabled;

  const QButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.margin,
    this.elevation,
    this.shadowColor,
    this.width,
    this.height,
    this.isLoading = false,
    this.icon,
    this.alignment = MainAxisAlignment.center,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    final effectiveBackgroundColor = backgroundColor ?? AppTheme.primaryOrange;
    final effectiveForegroundColor = foregroundColor ?? AppTheme.textWhite;
    final effectiveFontSize = fontSize ?? AppTheme.responsiveSize(16, scaleFactor);
    final effectiveFontWeight = fontWeight ?? AppTheme.fontWeightSemiBold;
    final effectiveBorderRadius = borderRadius ?? AppTheme.responsiveSize(AppTheme.radiusLarge, scaleFactor);
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor),
      vertical: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
    );
    final effectiveMargin = margin ?? EdgeInsets.zero;
    final effectiveElevation = elevation ?? 0;
    final effectiveShadowColor = shadowColor ?? effectiveBackgroundColor.withOpacity(0.3);
    final effectiveWidth = width ?? double.infinity;
    final effectiveHeight = height ?? AppTheme.responsiveSize(AppTheme.buttonHeightSmall, scaleFactor);

    Widget buttonContent = Row(
      mainAxisAlignment: alignment!,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            height: AppTheme.responsiveSize(16, scaleFactor),
            width: AppTheme.responsiveSize(16, scaleFactor),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveForegroundColor),
            ),
          ),
          if (text.isNotEmpty) SizedBox(width: AppTheme.responsiveSize(8, scaleFactor)),
        ],
        if (icon != null) ...[
          icon!,
          if (text.isNotEmpty) SizedBox(width: AppTheme.responsiveSize(8, scaleFactor)),
        ],
        if (text.isNotEmpty)
          Text(
            text,
            style: TextStyle(
              fontSize: effectiveFontSize,
              fontWeight: effectiveFontWeight,
              color: effectiveForegroundColor,
            ),
          ),
      ],
    );

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      margin: effectiveMargin,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          elevation: effectiveElevation,
          shadowColor: effectiveShadowColor,
          padding: effectivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
          disabledBackgroundColor: effectiveBackgroundColor.withOpacity(0.5),
          disabledForegroundColor: effectiveForegroundColor.withOpacity(0.7),
        ),
        child: buttonContent,
      ),
    );
  }
}
