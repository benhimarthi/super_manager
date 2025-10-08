import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../../domain/entities/product.category.dart';
import '../selecting.parent.category.dart';

class ParentCategorySelector extends StatelessWidget {
  final ProductCategory? category;
  final String parentCategoryName;
  final Function(String) onParentCategoryChanged;

  const ParentCategorySelector(
      {super.key,
      required this.category,
      required this.parentCategoryName,
      required this.onParentCategoryChanged});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
      listener: (context, state) {
        if (state is SelectingProductCategorySuccessfully) {
          onParentCategoryChanged(state.categoryuid);
        }
      },
      builder: (context, state) {
        return SelectingParentCategory(
          category: category,
          categoryUid: parentCategoryName,
        );
      },
    );
  }
}
