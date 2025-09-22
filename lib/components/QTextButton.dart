import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final MainAxisAlignment? alignment;
  final bool enabled;
  final TextDecoration? decoration;
  final Widget? icon;

  const QTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.margin,
    this.alignment = MainAxisAlignment.end,
    this.enabled = true,
    this.decoration,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    final effectiveTextColor = textColor ?? AppTheme.primaryOrange;
    final effectiveFontSize = fontSize ?? AppTheme.responsiveSize(14, scaleFactor);
    final effectiveFontWeight = fontWeight ?? AppTheme.fontWeightNormal;
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: AppTheme.responsiveSize(AppTheme.spacingSmall, scaleFactor),
      vertical: AppTheme.responsiveSize(AppTheme.spacingTiny, scaleFactor),
    );
    final effectiveMargin = margin ?? EdgeInsets.zero;

    Widget buttonContent = Row(
      mainAxisAlignment: alignment!,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon!,
          SizedBox(width: AppTheme.responsiveSize(4, scaleFactor)),
        ],
        Text(
          text,
          style: TextStyle(
            color: enabled ? effectiveTextColor : effectiveTextColor.withOpacity(0.5),
            fontSize: effectiveFontSize,
            fontWeight: effectiveFontWeight,
            decoration: decoration,
          ),
        ),
      ],
    );

    return Container(
      margin: effectiveMargin,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          padding: effectivePadding,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: buttonContent,
      ),
    );
  }
}
