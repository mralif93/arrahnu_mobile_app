import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final bool isLoading;
  final Widget? icon;
  final MainAxisAlignment? alignment;
  final bool enabled;

  const QOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.padding,
    this.margin,
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
    final effectiveBorderColor = borderColor ?? AppTheme.primaryOrange;
    final effectiveTextColor = textColor ?? AppTheme.primaryOrange;
    final effectiveFontSize = fontSize ?? AppTheme.responsiveSize(16, scaleFactor);
    final effectiveFontWeight = fontWeight ?? AppTheme.fontWeightSemiBold;
    final effectiveBorderRadius = borderRadius ?? AppTheme.responsiveSize(AppTheme.radiusLarge, scaleFactor);
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: AppTheme.responsiveSize(AppTheme.spacingLarge, scaleFactor),
      vertical: AppTheme.responsiveSize(AppTheme.spacingMedium, scaleFactor),
    );
    final effectiveMargin = margin ?? EdgeInsets.zero;
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
              valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
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
              color: effectiveTextColor,
            ),
          ),
      ],
    );

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      margin: effectiveMargin,
      child: OutlinedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          side: BorderSide(
            color: enabled ? effectiveBorderColor : effectiveBorderColor.withOpacity(0.5),
            width: 1,
          ),
          padding: effectivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
        ),
        child: buttonContent,
      ),
    );
  }
}
