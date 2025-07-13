import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/authentication/presentation/cubit/authentication.cubit.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';

import '../cubit/product.cubit.dart';

class DeleteProductConfirmationScreen extends StatelessWidget {
  final Product deletedProduct;
  const DeleteProductConfirmationScreen({
    super.key,
    required this.deletedProduct,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Deletion Confirmation",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Do your really wish to remove, this Product ?"),
          ListTile(
            //leading: CircleAvatar(),
            title: Text(
              deletedProduct.name,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            //subtitle: Text(deletedProduct.role.name),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  context.read<ProductCubit>().deleteProduct(deletedProduct.id);
                  Navigator.pop(context);
                },
                child: Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
