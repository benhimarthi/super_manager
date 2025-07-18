import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/product/presentation/cubit/product.cubit.dart';

class InventoryItemCardproduct extends StatefulWidget {
  final String productId;
  const InventoryItemCardproduct({super.key, required this.productId});

  @override
  State<InventoryItemCardproduct> createState() =>
      _InventoryItemCardproductState();
}

class _InventoryItemCardproductState extends State<InventoryItemCardproduct> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
