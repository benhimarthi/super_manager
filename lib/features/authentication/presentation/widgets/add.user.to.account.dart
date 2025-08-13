import 'package:flutter/material.dart';

import '../pages/registration_screen/registration.formular.dart';

class AddUserToAccount extends StatelessWidget {
  const AddUserToAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ADD USER",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.group, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          Container(margin: EdgeInsets.all(20), child: RegistrationFormular()),
        ],
      ),
    );
  }
}
