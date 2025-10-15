import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class QTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onFieldSubmitted;
  final String? Function(String?)? validator;
  final bool enabled;
  final double? fontSize;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? fillColor;
  final double? borderRadius;
  final EdgeInsets? contentPadding;
  final EdgeInsets? padding;
  final bool showCardStyle;
  final List<BoxShadow>? boxShadow;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const QTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.obscureText,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.validator,
    this.enabled = true,
    this.fontSize,
    this.borderColor,
    this.focusedBorderColor,
    this.fillColor,
    this.borderRadius,
    this.contentPadding,
    this.padding,
    this.showCardStyle = false,
    this.boxShadow,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scaleFactor = AppTheme.getScaleFactor(context);
    final effectiveFontSize = fontSize ?? AppTheme.responsiveSize(12, scaleFactor);
    final effectiveBorderRadius = borderRadius ?? AppTheme.responsiveSize(12, scaleFactor);
    final effectiveBorderColor = borderColor ?? AppTheme.borderLight;
    final effectiveFocusedBorderColor = focusedBorderColor ?? AppTheme.primaryOrange;
    final effectiveFillColor = fillColor ?? AppTheme.backgroundWhite;
    final effectiveContentPadding = contentPadding ?? EdgeInsets.symmetric(
      horizontal: AppTheme.responsiveSize(16, scaleFactor),
      vertical: AppTheme.responsiveSize(12, scaleFactor),
    );
    final effectivePadding = padding ?? EdgeInsets.symmetric(
      horizontal: AppTheme.responsiveSize(0, scaleFactor),
    );

    Widget textField = TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted != null ? (_) => onFieldSubmitted!() : null,
      validator: validator,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: effectiveFontSize,
        fontWeight: FontWeight.w400,
        color: enabled ? AppTheme.textPrimary : AppTheme.textMuted,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: enabled ? AppTheme.primaryOrange : AppTheme.textMuted,
          size: AppTheme.responsiveSize(AppTheme.iconMedium, scaleFactor),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: effectiveFontSize,
          color: AppTheme.textMuted,
          fontWeight: FontWeight.w400,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: BorderSide(
            color: effectiveBorderColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: BorderSide(
            color: effectiveFocusedBorderColor,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: BorderSide(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: BorderSide(
            color: AppTheme.secondaryRed,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          borderSide: BorderSide(
            color: AppTheme.secondaryRed,
            width: 2,
          ),
        ),
        fillColor: effectiveFillColor,
        filled: true,
        contentPadding: effectiveContentPadding,
      ),
    );

    if (showCardStyle) {
      return Padding(
        padding: effectivePadding,
        child: Container(
          decoration: BoxDecoration(
            color: effectiveFillColor,
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            boxShadow: boxShadow ?? AppTheme.cardShadow,
          ),
          child: textField,
        ),
      );
    }

    return Padding(
      padding: effectivePadding,
      child: textField,
    );
  }
}
