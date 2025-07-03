import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/pages/login_screen/login.screen.dart';
import '../../features/authentication/presentation/pages/registration_screen/registration.screen.dart';
import '../../features/authentication/presentation/pages/user_management_screen/main.screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(path: '/users', builder: (context, state) => const MainScreen()),
  ],
);
