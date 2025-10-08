import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/authentication/data/models/user.model.dart';
import 'package:super_manager/features/authentication/presentation/cubit/authentication.cubit.dart';
import 'package:super_manager/features/authentication/presentation/widgets/add.user.to.account.dart';
import 'package:super_manager/features/authentication/presentation/widgets/delete.user.confirmation.screen.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.state.dart';
import '../../../domain/entities/user.dart';
import '../../cubit/authentication.state.dart';
import '../../widgets/edit.user.dialog.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  late bool isSwitched = false;
  AssetImage img = Random().nextDouble() >= .5
      ? AssetImage('assets/images/boy.png')
      : AssetImage('assets/images/girl.png');
  @override
  void initState() {
    super.initState();
    context.read<AuthenticationCubit>().fetchUsers();
  }

  void _onEditUser(User user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );
  }

  void _onDeletion(User deletedUser) {
    showDialog(
      context: context,
      builder: (context) =>
          DeleteUserConfirmationScreen(deletedUser: deletedUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users Management")),
      floatingActionButton: CircleAvatar(
        child: Center(
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddUserToAccount(),
              );
            },
            icon: Icon(Icons.add),
          ),
        ),
      ),
      body: BlocConsumer<AuthenticationCubit, AuthenticationState>(
        listener: (context, state) {
          if (state is UsersLoaded) {}
        },
        builder: (context, state) {
          if (state is UsersLoaded) {
            final users = state.users;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 1,
                mainAxisExtent: 230,
              ),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                isSwitched = users[index].activated == null
                    ? false
                    : users[index].activated!;
                final currentUser = users[index];
                context.read<AppImageManagerCubit>().loadImages(currentUser.id);
                return GestureDetector(
                  onTap: () {
                    _onEditUser(currentUser);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.all(15),
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * .45,
                        height: 250,
                        decoration: BoxDecoration(
                          color: isSwitched
                              ? Color.fromARGB(255, 64, 64, 64)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            width: 1,
                            color: Color.fromARGB(255, 64, 64, 64),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  //color: Colors.amber,
                                  width: 70,
                                  child: Text(
                                    currentUser.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        //_onDeletion(currentUser);
                                      },
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 10,
                                          child: Center(
                                            child: Icon(Icons.edit, size: 12),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        _onDeletion(currentUser);
                                      },
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 10,
                                          child: Center(
                                            child: Icon(
                                              Icons.delete,
                                              size: 12,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              "role : ${users[index].role.name}",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            BlocConsumer<AppImageManagerCubit, AppImageState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                if (state is AppImageManagerLoaded) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: CircleAvatar(
                                      backgroundColor: const Color.fromARGB(
                                        136,
                                        255,
                                        255,
                                        255,
                                      ),
                                      radius: 35,
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundImage: img,
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: CircleAvatar(
                                      backgroundColor: const Color.fromARGB(
                                        136,
                                        255,
                                        255,
                                        255,
                                      ),
                                      radius: 35,
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundImage: img,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Statut",
                                  style: TextStyle(
                                    color: isSwitched
                                        ? Colors.green
                                        : const Color.fromARGB(
                                            136,
                                            255,
                                            255,
                                            255,
                                          ),
                                  ),
                                ),
                                Transform.scale(
                                  scale:
                                      .6, // 1.0 is default size, >1 enlarges, <1 shrinks
                                  child: Switch(
                                    value: isSwitched,
                                    onChanged: (value) {
                                      setState(() {
                                        isSwitched = value;
                                        final updatedUser = UserModel.fromUser(
                                          currentUser,
                                        ).copyWith(activated: value);
                                        context
                                            .read<AuthenticationCubit>()
                                            .updateUser(updatedUser);
                                      });
                                    },
                                    activeThumbColor: const Color.fromARGB(
                                      255,
                                      41,
                                      204,
                                      47,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}
