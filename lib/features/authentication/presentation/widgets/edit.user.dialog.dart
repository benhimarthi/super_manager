import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  UserRole _selectedRole = UserRole.regular;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _avatarController = TextEditingController(text: widget.user.avatar);
    _selectedRole = widget.user.role;
  }

  void _onUpdateUser() {
    final updatedUser = User(
      id: widget.user.id,
      createdAt: widget.user.createdAt,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: "",
      avatar: _avatarController.text.trim(),
      role: _selectedRole,
    );

    context.read<AuthenticationCubit>().updateUser(updatedUser);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit User"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name")),
          TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email")),
          TextField(
              controller: _avatarController,
              decoration: const InputDecoration(labelText: "Avatar URL")),
          DropdownButton<UserRole>(
            value: _selectedRole,
            items: const [
              DropdownMenuItem(
                  value: UserRole.admin, child: Text("Administrator")),
              DropdownMenuItem(
                  value: UserRole.regular, child: Text("Regular User")),
            ],
            onChanged: (role) {
              setState(() => _selectedRole = role!);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        ElevatedButton(onPressed: _onUpdateUser, child: const Text("Update")),
      ],
    );
  }
}
