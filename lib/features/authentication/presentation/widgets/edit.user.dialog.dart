import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/session/session.manager.dart';

import '../../data/models/user.model.dart';
import '../../domain/entities/user.dart';
import '../cubit/authentication.cubit.dart';

class EditUserDialog extends StatefulWidget {
  const EditUserDialog({super.key, required this.user});

  final User user;

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _avatarController;
  late bool isSwitched;
  UserRole _selectedRole = UserRole.regular;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _avatarController = TextEditingController(text: widget.user.avatar);
    _selectedRole = widget.user.role;
    isSwitched = widget.user.activated != null ? widget.user.activated! : true;
  }

  void _onUpdateUser() {
    final updatedUser = User(
      id: widget.user.id,
      createdAt: widget.user.createdAt,
      createdBy: widget.user.createdBy,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: "",
      avatar: _avatarController.text.trim(),
      role: _selectedRole,
      activated: widget.user.activated,
    );
    context.read<AuthenticationCubit>().updateUser(updatedUser);
    SessionManager.saveUserSession(updatedUser);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(),
          const Text("Edit User"),
          Transform.scale(
            scale: .6, // 1.0 is default size, >1 enlarges, <1 shrinks
            child: Switch(
              value: isSwitched,
              onChanged: (value) {
                setState(() {
                  isSwitched = value;
                  final updatedUser = UserModel.fromUser(
                    widget.user,
                  ).copyWith(activated: value);
                  context.read<AuthenticationCubit>().updateUser(updatedUser);
                });
              },
              activeColor: const Color.fromARGB(255, 41, 204, 47),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),

          /*SizedBox(height: 10),
          DropdownButton<UserRole>(
            value: _selectedRole,
            items: const [
              DropdownMenuItem(
                value: UserRole.admin,
                child: Text("Administrator"),
              ),
              DropdownMenuItem(
                value: UserRole.regular,
                child: Text("Regular User"),
              ),
            ],
            onChanged: (role) {
              setState(() => _selectedRole = role!);
            },
          ),*/
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _onUpdateUser, child: const Text("Update")),
      ],
    );
  }
}
