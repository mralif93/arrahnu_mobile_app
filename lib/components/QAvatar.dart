import 'package:flutter/material.dart';

class QAvatar extends StatelessWidget {
  final String image;
  final String name;
  final String mobile;

  const QAvatar({
    super.key,
    required this.image,
    required this.name,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar image
        SizedBox(
          width: 130,
          height: 130,
          child: Image.network(image),
        ),

        // space
        const SizedBox(height: 12),

        // name
        if (name.isNotEmpty)
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

        // space
        if (name.isNotEmpty) const SizedBox(height: 6),

        // mobile
        if (mobile.isNotEmpty)
          Text(
            mobile,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

        // space
        if (mobile.isNotEmpty) const SizedBox(height: 12),
      ],
    );
  }
}
