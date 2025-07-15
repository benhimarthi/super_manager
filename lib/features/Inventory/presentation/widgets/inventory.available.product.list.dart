import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.available.product.item.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';

import '../../../product/presentation/cubit/product.cubit.dart';
import '../../../product/presentation/cubit/product.state.dart';

class InventoryAvailableProductList extends StatefulWidget {
  const InventoryAvailableProductList({super.key});

  @override
  State<InventoryAvailableProductList> createState() =>
      _InventoryAvailableProductListState();
}

class _InventoryAvailableProductListState
    extends State<InventoryAvailableProductList> {
  late List<Product> availableProduct;
  @override
  void initState() {
    super.initState();
    availableProduct = [];
    context.read<ProductCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, state) {
        if (state is ProductManagerLoaded) {
          availableProduct = state.products.where((x) => x.active).toList();
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: 300,
          height: 100,
          child: ListView.builder(
            itemCount: availableProduct.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, ind) {
              return InventoryAvailableProductItem(
                product: availableProduct[ind],
              );
            },
          ),
        );
      },
    );
  }
}
