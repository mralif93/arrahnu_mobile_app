import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SweetAlert {
  // Success Alert
  static void success({
    required String title,
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) {
    HapticFeedback.lightImpact();
    Get.dialog(
      _SweetAlertDialog(
        type: SweetAlertType.success,
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
      barrierDismissible: false,
    );
  }

  // Error Alert
  static void error({
    required String title,
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) {
    HapticFeedback.heavyImpact();
    Get.dialog(
      _SweetAlertDialog(
        type: SweetAlertType.error,
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
      barrierDismissible: false,
    );
  }

  // Warning Alert
  static void warning({
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    HapticFeedback.mediumImpact();
    Get.dialog(
      _SweetAlertDialog(
        type: SweetAlertType.warning,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
      barrierDismissible: false,
    );
  }

  // Info Alert
  static void info({
    required String title,
    required String message,
    String confirmText = 'OK',
    VoidCallback? onConfirm,
  }) {
    HapticFeedback.lightImpact();
    Get.dialog(
      _SweetAlertDialog(
        type: SweetAlertType.info,
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
      ),
      barrierDismissible: false,
    );
  }

  // Confirmation Alert
  static void confirm({
    required String title,
    required String message,
    String confirmText = 'Yes',
    String cancelText = 'No',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
  }) {
    HapticFeedback.mediumImpact();
    Get.dialog(
      _SweetAlertDialog(
        type: SweetAlertType.question,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmColor: confirmColor,
      ),
      barrierDismissible: false,
    );
  }
}

enum SweetAlertType {
  success,
  error,
  warning,
  info,
  question,
}

class _SweetAlertDialog extends StatefulWidget {
  final SweetAlertType type;
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;

  const _SweetAlertDialog({
    required this.type,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
  });

  @override
  State<_SweetAlertDialog> createState() => _SweetAlertDialogState();
}

class _SweetAlertDialogState extends State<_SweetAlertDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _iconAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _iconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.elasticOut,
    ));

    _iconRotationAnimation = Tween<double>(
      begin: -0.5,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _iconAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case SweetAlertType.success:
        return Colors.green;
      case SweetAlertType.error:
        return Colors.red;
      case SweetAlertType.warning:
        return Colors.orange;
      case SweetAlertType.info:
        return Colors.blue;
      case SweetAlertType.question:
        return widget.confirmColor ?? Colors.purple;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case SweetAlertType.success:
        return Icons.check_circle;
      case SweetAlertType.error:
        return Icons.error;
      case SweetAlertType.warning:
        return Icons.warning;
      case SweetAlertType.info:
        return Icons.info;
      case SweetAlertType.question:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();
    final typeIcon = _getTypeIcon();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 20,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with enhanced animation
                    AnimatedBuilder(
                      animation: _iconAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _iconScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _iconRotationAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: typeColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: typeColor.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                typeIcon,
                                size: 40,
                                color: typeColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Message
                    Text(
                      widget.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        if (widget.cancelText != null) ...[
                          Expanded(
                            child: _AnimatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Get.back();
                                widget.onCancel?.call();
                              },
                              backgroundColor: Colors.grey[200]!,
                              foregroundColor: Colors.black87,
                              child: Text(
                                widget.cancelText!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: _AnimatedButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.back();
                              widget.onConfirm?.call();
                            },
                            backgroundColor: widget.confirmColor ?? typeColor,
                            foregroundColor: Colors.white,
                            child: Text(
                              widget.confirmText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget child;

  const _AnimatedButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.child,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: widget.foregroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
