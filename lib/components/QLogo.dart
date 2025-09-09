import 'package:flutter/material.dart';

class QLogo extends StatelessWidget {
  final String image;

  const QLogo({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Image.asset(image),
      ),
    );
  }
}
