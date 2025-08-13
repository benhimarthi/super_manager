import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/authentication/presentation/cubit/authentication.cubit.dart';

import '../../../../core/util/change.screen.manager.dart';
import '../pages/login_screen/login.screen.dart';

class AfterPasswordResetPrompt extends StatelessWidget {
  const AfterPasswordResetPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Password reset!",
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Log out and log back in with the new password for updated session and security.",
          ),
          SizedBox(height: 10),
          /*GestureDetector(
            child: Text(
              "Later",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 10),*/
          ElevatedButton(
            onPressed: () {
              context.read<AuthenticationCubit>().logout();
              nextScreenReplace(context, LoginScreen());
            },
            child: Text("Log out"),
          ),
        ],
      ),
    );
  }
}
