import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/authentication/presentation/cubit/authentication.cubit.dart';
import '../../domain/entities/user.dart';

class DeleteUserConfirmationScreen extends StatelessWidget {
  final User deletedUser;
  const DeleteUserConfirmationScreen({super.key, required this.deletedUser});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Deletion Confirmation",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Do your really wish to remove, ths user ?"),
          ListTile(
            leading: CircleAvatar(),
            title: Text(
              deletedUser.name,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            subtitle: Text(deletedUser.role.name),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  context.read<AuthenticationCubit>().deleteUser(
                    deletedUser.id,
                  );
                },
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
