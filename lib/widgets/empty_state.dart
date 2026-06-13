import 'package:flutter/material.dart';

// EmptyState — when data is empty then this show
// message and icon can give from outside— reusable

class EmptyState extends StatelessWidget {

  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // up-down-mid
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}