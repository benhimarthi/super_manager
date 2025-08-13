import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/authentication/presentation/widgets/modify.account.email.address.new.email.dart';

import '../cubit/authentication.cubit.dart';
import '../cubit/authentication.state.dart';

class ModifyAccountEmailAddress extends StatefulWidget {
  const ModifyAccountEmailAddress({super.key});

  @override
  State<ModifyAccountEmailAddress> createState() =>
      _ModifyAccountEmailAddressState();
}

class _ModifyAccountEmailAddressState extends State<ModifyAccountEmailAddress> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool authenticated = true;
  final formKey = GlobalKey<FormState>();
  onReauthenticate() {
    if (formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      context.read<AuthenticationCubit>().loginWithEmail(email, password);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      title: Text(
        "Modify mail address",
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: BlocConsumer<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is UserAuthenticated) {
            setState(() {
              authenticated = true;
            });
          }
        },
        builder: (context, state) {
          return !authenticated
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.all(10),
                      child: Text(
                        "You will have to reauthenticate yourself before changing your mail address",
                      ),
                    ),
                    SizedBox(height: 10),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    hintText: "your current email address",
                                  ),
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (value) {},
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
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    hintText: "password",
                                  ),
                                  validator: (value) {
                                    RegExp regex = RegExp(
                                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                                    );
                                    if (!regex.hasMatch(value!)) {
                                      return 'Password must be at least 8 characters, include uppercase, lowercase, number, and special character (!@#\$&*~)';
                                    } else if (value.isEmpty) {
                                      return "This field can not be null";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                          /*ElevatedButton(
                            onPressed: () {
                              onReauthenticate();
                            },
                            child: Text("Reauthenticate"),
                          ),*/
                          GestureDetector(
                            onTap: () {
                              onReauthenticate();
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
                                child: Text(
                                  "Reauthenticate",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : ModifyAccountEmailAddressNewEmail();
        },
      ),
    );
  }
}
