import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:super_manager/features/product/presentation/pages/product.page.dart';
import 'package:super_manager/features/product_category/presentation/pages/product.category.page.dart'
    show ProductCategoryPage;
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../../../Inventory/presentation/pages/inventory.list.screen.dart';
import '../../../../notification_manager/presentation/pages/notification.page.dart';
import '../../../../sale_item/presentation/pages/sale.view.dart';
import 'user.activities.manager.dart';
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
    title = "SALE";
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
          "HOME" => SaleView(),
          "PROFILE" => UserProfile(),
          "PRODUCT" => ProductPage(),
          "USERS" => UserManagement(),
          "INVENTORY" => InventoryListScreen(),
          "SALE" => SaleView(),
          "PRODUCT_CATEGORY" => ProductCategoryPage(),
          "PROFILE" => UserManagement(),
          "FINANCE" => UserActivitiesManager(
            user: SessionManager.getUserSession()!,
          ),
          //AssessmentView(),
          "NOTIFICATIONS" => NotificationPage(),
          String() => throw UnimplementedError(),
        };
      },
    );
  }
}
