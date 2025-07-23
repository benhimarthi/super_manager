import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/authentication/presentation/pages/user_management_screen/current.screen.infos.dart';
import 'package:super_manager/features/authentication/presentation/pages/user_management_screen/menu.application.view.dart';
import 'package:super_manager/features/authentication/presentation/widgets/selected.option.dart';
import '../../../../../core/session/session.manager.dart';
import '../../../domain/entities/user.dart';
import '../../cubit/authentication.cubit.dart';
import '../../widgets/edit.user.dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late User currentUser;

  @override
  void initState() {
    super.initState();
    if (SessionManager.getUserSession() != null) {
      currentUser = SessionManager.getUserSession()!;
    }
    context.read<AuthenticationCubit>().fetchUsers();
  }

  void _onDeleteUser(String userId) {
    context.read<AuthenticationCubit>().deleteUser(userId);
  }

  void _onEditUser(User user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  color: const Color.fromARGB(255, 27, 29, 31),
                  height: double.infinity,
                  width: MediaQuery.of(context).size.width * .2,
                ),
                Container(
                  color: const Color.fromARGB(255, 27, 29, 31),
                  height: double.infinity,
                  width: MediaQuery.of(context).size.width * .2,
                ),
              ],
            ),
            MenuApplicationView(),
            Align(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .88,
                    height: double.infinity,
                  ),
                  SelectedOption(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                color: const Color.fromARGB(255, 0, 0, 0),
                width: MediaQuery.of(context).size.width * .87,
                padding: EdgeInsets.all(2),
                child: const CurrentSCreenInfos(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
