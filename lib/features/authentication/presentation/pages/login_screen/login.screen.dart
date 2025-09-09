import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:super_manager/features/synchronisation/refresh.datas.from.remote.storage.dart';
import '../../cubit/authentication.cubit.dart';
import '../../cubit/authentication.state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late bool viewPassword;
  @override
  void initState() {
    super.initState();
    viewPassword = false;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      if (email.isNotEmpty) {
        context.read<AuthenticationCubit>().loginWithEmail(email, password);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid email")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
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
            listener: (context, state) async {
              if (state is AuthenticationError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is UserAuthenticated) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return RefreshDatasFromRemoteStorage();
                  },
                );
                //nextScreenReplace(context, MainScreen());
              } else if (state is AuthenticationOfflinePending) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("You're offline. Login pending sync."),
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
                      "Hello !\nWelcome Back",
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
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            label: Text("mail adress"),
                            prefixIcon: Icon(
                              Icons.mail,
                              color: Color.fromARGB(127, 106, 106, 106),
                            ),
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          //keyboardType: TextInputType.emailAddress,
                          obscureText: !viewPassword,
                          decoration: InputDecoration(
                            label: const Text("Password"),
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
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            child: const Text(
                              "Recover password ? ",
                              style: TextStyle(
                                color: Color.fromARGB(160, 135, 135, 135),
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: state is AuthenticationLoading
                              ? null
                              : _onLogin,
                          child: state is AuthenticationLoading
                              ? const CircularProgressIndicator()
                              : const Text("Login"),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              color: const Color.fromARGB(125, 221, 221, 221),
                              width: 120,
                              height: 1.5,
                            ),
                            const Text(
                              "Or continue with",
                              style: TextStyle(
                                color: Color.fromARGB(124, 162, 162, 162),
                              ),
                            ),
                            Container(
                              color: const Color.fromARGB(125, 221, 221, 221),
                              width: 120,
                              height: 1.5,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 45,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 242, 242, 242),
                                /*image: DecorationImage(
                                    fit: BoxFit.scaleDown,
                                    image:
                                        AssetImage("assets/icons/google.png"),
                                  ),*/
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.asset("assets/icons/google.png"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            GoRouter.of(context).go("/register");
                          },
                          child: const SizedBox(
                            width: double.infinity,
                            child: Text.rich(
                              TextSpan(
                                text: "Don't Have an account? ",
                                children: [
                                  TextSpan(
                                    text: "Create Account!",
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
