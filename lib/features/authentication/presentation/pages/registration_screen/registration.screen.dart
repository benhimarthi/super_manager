import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:super_manager/features/authentication/presentation/pages/registration_screen/registration.formular.dart';
import '../../cubit/authentication.cubit.dart';
import '../../cubit/authentication.state.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        actions: [
          Row(
            children: const [
              Text("Skip to home page", style: TextStyle(fontSize: 13)),
              Icon(Icons.arrow_forward_ios_rounded, size: 16),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<AuthenticationCubit, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is UserCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User created successfully!")),
                );
                Navigator.pushReplacementNamed(context, "/users");
              } else if (state is AuthenticationOfflinePending) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("You're offline. Registration pending sync."),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: Text(
                      "Strat with a new Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RegistrationFormular(),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).go("/login");
                    },
                    child: const SizedBox(
                      width: double.infinity,
                      child: Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          children: [
                            TextSpan(
                              text: "Login!",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          style: TextStyle(
                            color: Color.fromARGB(120, 126, 126, 126),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
