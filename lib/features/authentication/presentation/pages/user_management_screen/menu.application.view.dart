import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

class MenuApplicationView extends StatefulWidget {
  const MenuApplicationView({super.key});

  @override
  State<MenuApplicationView> createState() => _MenuApplicationViewState();
}

class _MenuApplicationViewState extends State<MenuApplicationView> {
  final double initialSelectorPosition = 0;
  late double targetPosition = 0;
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
                      Icon(Icons.person, color: Theme.of(context).primaryColor),
                      Icon(
                        Icons.notifications,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                RotatedBox(
                  quarterTurns: -1, // Rotates 90° counter-clockwise
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        targetPosition = 0;
                        context.read<WidgetManipulatorCubit>().changeMenu(
                          targetPosition,
                          "HOME",
                        );
                      });
                    },
                    child: const Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 64, 64, 64),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                RotatedBox(
                  quarterTurns: -1, // Rotates 90° counter-clockwise
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        targetPosition = 118;
                        context.read<WidgetManipulatorCubit>().changeMenu(
                          targetPosition,
                          "USER MANAGER",
                        );
                      });
                    },
                    child: const Text(
                      'User Management',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 64, 64, 64),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                RotatedBox(
                  quarterTurns: -1, // Rotates 90° counter-clockwise
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        setState(() {
                          targetPosition = 118 * 2;
                          context.read<WidgetManipulatorCubit>().changeMenu(
                            targetPosition,
                            "MY FINANCES",
                          );
                        });
                      });
                    },
                    child: const Text(
                      'My finances',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 64, 64, 64),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                RotatedBox(
                  quarterTurns: -1, // Rotates 90° counter-clockwise
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        targetPosition = 118 * 3;
                        context.read<WidgetManipulatorCubit>().changeMenu(
                          targetPosition,
                          "MY STATS",
                        );
                      });
                    },
                    child: const Text(
                      'My Stats',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 64, 64, 64),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
