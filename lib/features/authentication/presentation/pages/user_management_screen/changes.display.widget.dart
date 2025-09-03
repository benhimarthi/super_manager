import 'package:flutter/material.dart';

class ChangesDisplayWidget extends StatelessWidget {
  final Map<dynamic, Map<dynamic, dynamic>> changes;

  const ChangesDisplayWidget({required this.changes});

  @override
  Widget build(BuildContext context) {
    if (changes.isEmpty) {
      return Center(
        child: Text(
          'No changes detected',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16),
      children: changes.entries.map((entry) {
        final field = entry.key;
        final oldVal = entry.value['old']?.toString() ?? '';
        final newVal = entry.value['new']?.toString() ?? '';

        return Card(
          color: Colors.yellow.shade50,
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(field, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Old: $oldVal'),
                Text(
                  'New: $newVal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
