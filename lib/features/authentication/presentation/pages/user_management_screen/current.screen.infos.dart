import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/product/presentation/pages/product.page.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.state.dart';
import 'user.management.dart';
import 'user.profile.dart';

class CurrentSCreenInfos extends StatefulWidget {
  const CurrentSCreenInfos({super.key});

  @override
  State<CurrentSCreenInfos> createState() => _CurrentSCreenInfosState();
}

class _CurrentSCreenInfosState extends State<CurrentSCreenInfos> {
  late String title;
  @override
  void initState() {
    super.initState();
    title = "PRODUCT";
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
      listener: (context, state) {
        if (state is ChangeMenuSuccessfully) {
          setState(() {
            title = state.title;
          });
        }
      },
      builder: (context, state) {
        return switch (title) {
          "HOME" => Container(),
          "PROFILE" => UserProfile(),
          "PRODUCT" => ProductPage(),
          "USER MANAGER" => UserManagement(),
          String() => throw UnimplementedError(),
        };
      },
    );
  }
}
