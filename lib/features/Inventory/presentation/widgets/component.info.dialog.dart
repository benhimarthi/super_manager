import 'package:flutter/material.dart';

/// A reusable StatelessWidget that shows an information alert
class ComponentInfoDialog extends StatelessWidget {
  final String title;
  final String message;

  const ComponentInfoDialog({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("OK"),
        ),
      ],
    );
  }
}
