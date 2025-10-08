import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/authorization_management/authorization.service.dart';
import 'package:super_manager/core/authorization_management/permissions.dart';
import 'package:super_manager/core/notification_service/notification.params.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:super_manager/features/image_manager/domain/entities/app.image.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.state.dart';
import 'package:super_manager/features/image_manager/presentation/widgets/profile.image.dart';
import 'package:super_manager/features/notification_manager/domain/entities/notification.dart';
import 'package:super_manager/features/notification_manager/presentation/cubit/notification.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

import '../../../../notification_manager/presentation/cubit/notification.state.dart';

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
  late List<Notifications> myNotifications;

  @override
  void initState() {
    super.initState();
    myNotifications = [];
    context.read<AppImageManagerCubit>().loadImages(currentUser!.id);
    context.read<NotificationCubit>().loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: const Color.fromARGB(255, 0, 0, 0),
            width: MediaQuery.of(context).size.width * .88,
            height: double.infinity,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .11,
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
                          return GestureDetector(
                            onTap: () {
                              context.read<WidgetManipulatorCubit>().changeMenu(
                                targetPosition,
                                "PROFILE",
                              );
                            },
                            child: Transform.scale(
                              scale: .9,
                              child: ProfileImage(
                                itemId: SessionManager.getUserSession()!.id,
                                entityType: "profile",
                                name: SessionManager.getUserSession()!.name,
                                displayEdit: false,
                                radius: 24,
                                fontSize: 18,
                              ),
                            ),
                          );
                        },
                      ),
                      BlocConsumer<NotificationCubit, NotificationState>(
                        listener: (context, state) {
                          if (state is NotificationManagerLoaded) {
                            setState(() {
                              myNotifications = state.notifications;
                            });
                          }
                        },
                        builder: (context, state) {
                          return GestureDetector(
                            onTap: () {
                              context.read<WidgetManipulatorCubit>().changeMenu(
                                targetPosition,
                                "NOTIFICATIONS",
                              );
                            },
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 15,
                                    height: 25,
                                    child: Icon(
                                      Icons.notifications,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Visibility(
                                    visible: myNotifications
                                        .where(
                                          (x) =>
                                              x.status ==
                                              NotificationStatus.unread.name,
                                        )
                                        .toList()
                                        .isNotEmpty,
                                    child: CircleAvatar(
                                      radius: 6,
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        255,
                                        17,
                                        0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                menuItem(
                  Icons.group,
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
                const SizedBox(height: 30),
                menuItem(
                  Icons.home,
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
                const SizedBox(height: 30),
                menuItem(
                  Icons.gif_box,
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
                const SizedBox(height: 30),
                menuItem(
                  Icons.category,
                  () {
                    setState(() {
                      targetPosition = 118;
                      context.read<WidgetManipulatorCubit>().changeMenu(
                        targetPosition,
                        "PRODUCT_CATEGORY",
                      );
                    });
                  },
                  AuthorizationService.hasPermission(
                    currentUser!.role,
                    Permissions.salesRead,
                  ),
                ),
                const SizedBox(height: 30),
                menuItem(
                  Icons.inventory,
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
                const SizedBox(height: 30),
                menuItem(
                  Icons.money,
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
                const SizedBox(height: 30),
                menuItem(
                  Icons.graphic_eq,
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

  menuItem(IconData icon, onTap, bool authorization) {
    return Visibility(
      visible: authorization,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(icon),
        /*Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 64, 64, 64),
            ),
          ),*/
      ),
    );
  }
}
