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
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar image
        SizedBox(
          width: 130,
          height: 130,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(65),
            child: Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(65),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(65),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          ),
        ),

        // space
        const SizedBox(height: 12),

        // name - always render to maintain consistent layout
        Text(
          name.isNotEmpty ? name : 'User',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        // space
        const SizedBox(height: 6),

        // mobile - always render to maintain consistent layout
        Text(
          mobile.isNotEmpty ? mobile : 'No mobile number',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        // space
        const SizedBox(height: 12),
      ],
    );
  }
}
