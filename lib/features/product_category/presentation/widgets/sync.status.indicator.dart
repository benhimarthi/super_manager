import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../synchronisation/cubit/product_category_sync_manager_cubit/product.category.sync.trigger.cubit.dart';
import '../../../synchronisation/cubit/product_category_sync_manager_cubit/product.category.sync.trigger.state.dart';

class SyncStatusIndicator extends StatelessWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      ProductCategorySyncTriggerCubit,
      ProductCategorySyncTriggerState
    >(
      builder: (_, state) {
        if (state is SyncInProgress) {
          return const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.sync, color: Colors.amber),
          );
        }
        if (state is SyncFailure) {
          return const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.sync_problem, color: Colors.red),
          );
        }
        return const SizedBox.shrink(); // no indicator on success/idle
      },
    );
  }
}
