import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/authorization_management/authorization.service.dart';
import 'package:super_manager/core/authorization_management/permissions.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:super_manager/features/image_manager/domain/entities/app.image.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.state.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

class MenuApplicationView extends StatefulWidget {
  const MenuApplicationView({super.key});

  @override
  State<MenuApplicationView> createState() => _MenuApplicationViewState();
}

class _MenuApplicationViewState extends State<MenuApplicationView> {
  final double initialSelectorPosition = 0;
  late double targetPosition = 0;
  final currentUser = SessionManager.getUserSession();
  late final AppImage avatar;
  late String selectedMenu = "HOME";

  @override
  void initState() {
    super.initState();
    context.read<AppImageManagerCubit>().loadImages(currentUser!.id);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width * .88,
            height: double.infinity,
          ),
          SizedBox(
            width: 49,
            height: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  height: 100,
                  width: 35,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      BlocBuilder<AppImageManagerCubit, AppImageState>(
                        builder: (context, state) {
                          if (state is AppImageManagerLoaded) {
                            final currentImage = state.images
                                .where((x) => x.url.isNotEmpty)
                                .lastOrNull;
                            if (currentImage != null) {
                              return CircleAvatar(
                                backgroundImage: FileImage(
                                  File(currentImage.url),
                                ),
                              );
                            } else {
                              return Icon(
                                Icons.person,
                                color: Theme.of(context).primaryColor,
                              );
                            }
                          } else {
                            return Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            );
                          }
                        },
                      ),
                      Icon(
                        Icons.notifications,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                menuItem(
                  "Home",
                  () {
                    setState(() {
                      targetPosition = 0;
                      context.read<WidgetManipulatorCubit>().changeMenu(
                        targetPosition,
                        "HOME",
                      );
                    });
                  },
                  AuthorizationService.hasPermission(
                    currentUser!.role,
                    Permissions.salesRead,
                  ),
                ),
                const SizedBox(height: 50),
                menuItem(
                  "Products",
                  () {
                    setState(() {
                      targetPosition = 118;
                      context.read<WidgetManipulatorCubit>().changeMenu(
                        targetPosition,
                        "PRODUCT",
                      );
                    });
                  },
                  AuthorizationService.hasPermission(
                    currentUser!.role,
                    Permissions.salesRead,
                  ),
                ),
                const SizedBox(height: 50),
                menuItem(
                  "Inventory",
                  () {
                    setState(() {
                      targetPosition = 118;
                      context.read<WidgetManipulatorCubit>().changeMenu(
                        targetPosition,
                        "INVENTORY",
                      );
                    });
                  },
                  AuthorizationService.hasPermission(
                    currentUser!.role,
                    Permissions.salesRead,
                  ),
                ),
                const SizedBox(height: 50),
                menuItem(
                  "Users",
                  () {
                    setState(() {
                      targetPosition = 118 * 2;
                      context.read<WidgetManipulatorCubit>().changeMenu(
                        targetPosition,
                        "USERS",
                      );
                    });
                  },
                  !AuthorizationService.hasPermission(
                    currentUser!.role,
                    Permissions.usersRead,
                  ),
                ),
                const SizedBox(height: 50),
                menuItem(
                  "Finances",
                  () {
                    setState(() {
                      setState(() {
                        targetPosition = 118 * 3;
                        context.read<WidgetManipulatorCubit>().changeMenu(
                          targetPosition,
                          "FINANCE",
                        );
                      });
                    });
                  },
                  AuthorizationService.hasPermission(
                    currentUser!.role,
                    Permissions.salesRead,
                  ),
                ),
                const SizedBox(height: 50),
                menuItem(
                  "Stats",
                  () {
                    setState(() {
                      targetPosition = 118 * 4;
                      selectedMenu = "STATS";
                      context.read<WidgetManipulatorCubit>().changeMenu(
                        targetPosition,
                        selectedMenu,
                      );
                    });
                  },
                  AuthorizationService.hasPermission(
                    currentUser!.role,
                    Permissions.salesRead,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  menuItem(String title, onTap, bool authorization) {
    return Visibility(
      visible: authorization,
      child: RotatedBox(
        quarterTurns: -1, // Rotates 90° counter-clockwise
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 64, 64, 64),
            ),
          ),
        ),
      ),
    );
  }
}
