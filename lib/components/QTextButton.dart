import 'package:flutter/material.dart';

class QTextButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;

  const QTextButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onPressed,
          child: Text(text),
        ),
      ],
    );
  }
}
