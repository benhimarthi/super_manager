import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/authentication/presentation/widgets/after.mail.address.changed.action.dart';
import 'package:super_manager/features/synchronisation/cubit/authentication_synch_manager_cubit/authentication.sync.trigger.cubit.dart';

class ModifyAccountEmailAddressNewEmail extends StatelessWidget {
  const ModifyAccountEmailAddressNewEmail({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    onRenewMailAddess() {}
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: Column(
            children: [
              Text("We will send a confirmation link to your new mail box."),
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
              SizedBox(height: 10),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    label: Text("your new mail address"),
                  ),
                  validator: (value) {
                    final bool emailValid = RegExp(
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@'
                      r'((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|'
                      r'(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
                    ).hasMatch(value!);
                    if (!emailValid) {
                      return "Invalid email address, insert a valid mail address!";
                    } else if (value.isEmpty) {
                      return "This field can not be null";
                    } else {
                      return null;
                    }
                  },
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
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (formKey.currentState!.validate()) {
              context
                  .read<AuthenticationSyncTriggerCubit>()
                  .renewMailAccountMailAddress(_emailController.text.trim())
                  .whenComplete(() {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AfterMailAddressChangedACtion();
                      },
                    );
                    Navigator.pop(context);
                  });
            }
          },
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text("Change", style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
