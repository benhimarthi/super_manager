import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/product_category/domain/entities/product.category.dart';
import 'package:super_manager/features/product_category/presentation/cubit/local.category.manager.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

class DeleteProductCategoryConfirmationView extends StatefulWidget {
  final ProductCategory category;
  const DeleteProductCategoryConfirmationView({
    super.key,
    required this.category,
  });

  @override
  State<DeleteProductCategoryConfirmationView> createState() =>
      _DeleteProductCategoryConfirmationViewState();
}

class _DeleteProductCategoryConfirmationViewState
    extends State<DeleteProductCategoryConfirmationView> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Product Category'),
      content: const Text(
        'Are you sure you want to delete this product category?',
      ),
      actions: [
        TextButton(onPressed: () {}, child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            context
                .read<LocalCategoryManagerCubit>()
                .deleteCategory(widget.category.id)
                .whenComplete(() {
                  context.read<WidgetManipulatorCubit>().emitRandomElement({
                    "id": "element_supress_successfully",
                  });
                });
            Navigator.of(context).pop(true);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
