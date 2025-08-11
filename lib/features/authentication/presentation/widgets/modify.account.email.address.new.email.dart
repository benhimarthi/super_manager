import 'package:flutter/material.dart';

class ModifyAccountEmailAddressNewEmail extends StatelessWidget {
  const ModifyAccountEmailAddressNewEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("We will send a confirmation link to your new mail box."),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(label: Text("your new mail address")),
        ),
        SizedBox(height: 10),
        GestureDetector(
          child: Text("Cancel", style: TextStyle(color: Colors.red)),
        ),
        SizedBox(height: 10),
        ElevatedButton(onPressed: () {}, child: Text("Change")),
      ],
    );
  }
}
