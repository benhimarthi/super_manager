import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/user.dart';
import '../../cubit/authentication.cubit.dart';
import '../../cubit/authentication.state.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  UserRole _selectedRole = UserRole.regular;
  late bool viewPassword;
  late bool viewConfirmPassword;
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    viewPassword = false;
    viewConfirmPassword = false;
  }

  void _onRegister() {
    if (formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (name.isEmpty || email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all required fields")),
        );
        return;
      }

      context.read<AuthenticationCubit>().createUser(
        name: name,
        email: email,
        password: password,
        role: _selectedRole,
      );
    }
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
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color.fromARGB(127, 106, 106, 106),
                            ),
                            labelText: "Full Name",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "This field can not be null";
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.mail,
                              color: Color.fromARGB(127, 106, 106, 106),
                            ),
                            labelText: "Email",
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color.fromARGB(127, 106, 106, 106),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  viewPassword = !viewPassword;
                                });
                              },
                              child: Icon(
                                viewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color.fromARGB(127, 106, 106, 106),
                              ),
                            ),
                          ),
                          validator: (value) {
                            RegExp regex = RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                            );
                            if (!regex.hasMatch(value!)) {
                              return 'Password must be at least 8 characters, include uppercase, lowercase, number, and special character (!@#\$&*~)';
                            } else if (value.isEmpty) {
                              return "This field can not be null";
                            } else if (_passwordController.text.trim() !=
                                _confirmPasswordController.text.trim()) {
                              return 'Incompatible passwrod';
                            } else {
                              return null;
                            }
                          },
                          obscureText: !viewPassword,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: "Confirm password",
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color.fromARGB(127, 106, 106, 106),
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  viewConfirmPassword = !viewConfirmPassword;
                                });
                              },
                              child: Icon(
                                viewConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: const Color.fromARGB(127, 106, 106, 106),
                              ),
                            ),
                          ),
                          validator: (value) {
                            RegExp regex = RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
                            );
                            if (!regex.hasMatch(value!)) {
                              return 'Password must be at least 8 characters, include uppercase, lowercase, number, and special character (!@#\$&*~)';
                            } else if (value.isEmpty) {
                              return "This field can not be null";
                            } else if (_passwordController.text.trim() !=
                                _confirmPasswordController.text.trim()) {
                              return 'Incompatible passwrod';
                            } else {
                              return null;
                            }
                          },
                          obscureText: !viewConfirmPassword,
                        ),
                        const SizedBox(height: 16),
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
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: state is AuthenticationLoading
                              ? null
                              : _onRegister,
                          child: state is AuthenticationLoading
                              ? const CircularProgressIndicator()
                              : const Text("Register"),
                        ),
                      ],
                    ),
                  ),
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
