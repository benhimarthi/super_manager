import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.state.dart';

class SelectedOption extends StatefulWidget {
  const SelectedOption({super.key});

  @override
  State<SelectedOption> createState() => _SelectedOptionState();
}

class _SelectedOptionState extends State<SelectedOption> {
  final bool _isMoved = false;
  final double initialSelectorPosition = 0;
  late double targetPosition = 0;
  late String title = "HOME";

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
      listener: (context, state) {
        if (state is ChangeMenuSuccessfully) {
          setState(() {
            targetPosition = state.position;
            title = state.title;
          });
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: 49,
          height: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const SizedBox(height: 100, width: 35),
              const SizedBox(height: 5),
              Container(
                //color: Color.fromARGB(68, 255, 193, 7),
                height: 600,
                width: 55,
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                      top: _isMoved ? initialSelectorPosition : targetPosition,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            //_isMoved = !_isMoved;
                          });
                        },
                        child: Container(
                          color: const Color.fromARGB(255, 27, 29, 31),
                          height: 120,
                          width: 45,
                          child: Align(
                            alignment: Alignment.center,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 30,
                                    height: 118,
                                    color: Colors.black,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 60,
                                    height: 100,
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: RotatedBox(
                                      quarterTurns:
                                          -1, // Rotates 90° counter-clockwise
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    width: 60,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 27, 29, 31),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(60),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    width: 60,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color.fromARGB(255, 27, 29, 31),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(60),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }
}
