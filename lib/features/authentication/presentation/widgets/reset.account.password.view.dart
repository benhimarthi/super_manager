import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/history_actions/action.create.history.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:super_manager/features/action_history/presentation/cubit/action.history.cubit.dart';
import 'package:super_manager/features/authentication/presentation/widgets/after.password.reset.prompt.dart';
import 'package:super_manager/features/synchronisation/cubit/authentication_synch_manager_cubit/authentication.sync.trigger.cubit.dart';

class ResetAccountPasswordView extends StatelessWidget {
  const ResetAccountPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Reset Password",
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Check your mail box for the reinitialization Link."),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 15),
              SizedBox(width: 4),
              Text(
                "Warning",
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ),
          Text(
            "You migth needs to check up your Spam messages.",
            style: TextStyle(color: Colors.orange, fontSize: 12),
          ),
          Text(
            SessionManager.getUserSession()!.email,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              final history = addHistoryItem(
                "authentication",
                SessionManager.getUserSession()!.id,
                "user",
                "password reset",
                SessionManager.getUserSession()!.id,
                SessionManager.getUserSession()!.name,
                "password resting",
                {},
                {},
                "Authentication service",
                "statusBefore",
                "statusAfter",
              );
              context.read<ActionHistoryCubit>().addHistory(history);
              context
                  .read<AuthenticationSyncTriggerCubit>()
                  .resetAccountPassword(SessionManager.getUserSession()!.email);
              if (SessionManager.getUserSession() != null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AfterPasswordResetPrompt();
                  },
                );
              }
            },
            child: Text("Reset Password"),
          ),
        ],
      ),
    );
  }
}
