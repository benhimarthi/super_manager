import 'package:flutter/material.dart';

class PendingSyncBadge extends StatelessWidget {
  const PendingSyncBadge({super.key, required this.isPending});

  final bool isPending;

  @override
  Widget build(BuildContext context) {
    if (!isPending) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orangeAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        "Pending Sync",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
