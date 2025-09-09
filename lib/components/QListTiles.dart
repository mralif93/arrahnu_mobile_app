import 'package:flutter/material.dart';

class QListTiles extends StatelessWidget {
  final String text;
  final Function()? onTap;

  const QListTiles({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            // text
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
