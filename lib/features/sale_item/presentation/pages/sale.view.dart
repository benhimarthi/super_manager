import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/Inventory/presentation/cubit/inventory.cubit.dart';
import 'package:super_manager/features/inventory_meta_data/domain/entities/inventory.meta.data.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';
import 'package:super_manager/features/product/presentation/cubit/product.cubit.dart';
import 'package:super_manager/features/sale_item/presentation/widgets/confirm.sale.view.dart';
import 'package:super_manager/features/sale_item/presentation/widgets/daily.activity.infos.dart';
import 'package:super_manager/features/sale_item/presentation/widgets/sale.item.dart';
import 'package:super_manager/features/synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';

import '../../../Inventory/presentation/cubit/inventory.state.dart';
import '../../../product/presentation/cubit/product.state.dart';
import '../../../synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.state.dart';

class SaleView extends StatefulWidget {
  const SaleView({super.key});

  @override
  State<SaleView> createState() => _SaleViewState();
}

class _SaleViewState extends State<SaleView> {
  late List<Inventory> inventories;
  late List<InventoryMetadata> inventoryMetaDatas;
  late List<Product> products;

  @override
  void initState() {
    inventories = [];
    products = [];
    inventoryMetaDatas = [];
    super.initState();
    context.read<InventoryCubit>().loadInventory();
    context.read<ProductCubit>().loadProducts();
    context.read<InventoryMetadataCubit>().loadMetadata();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocConsumer<InventoryCubit, InventoryState>(
        listener: (context, state) {
          if (state is InventoryManagerLoaded) {
            inventories = state.inventoryList;
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Container(
                height: 45,
                width: double.infinity,
                //color: Colors.green,
              ),
              SizedBox(height: 10),
              DailyActivityInfos(),
              SizedBox(height: 10),
              BlocConsumer<InventoryMetadataCubit, InventoryMetadataState>(
                listener: (context, state) {
                  if (state is InventoryMetadataManagerLoaded) {
                    inventoryMetaDatas = state.metadataList;
                  }
                },
                builder: (context, state) {
                  return Container();
                },
              ),
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .8,
                //color: Colors.amber,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    BlocConsumer<ProductCubit, ProductState>(
                      listener: (context, state) {
                        if (state is ProductManagerLoaded) {
                          products = state.products;
                        }
                      },
                      builder: (context, state) {
                        return Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * .8,
                          //color: Colors.amber,
                          child: ListView(
                            children: List.generate(inventories.length, (
                              index,
                            ) {
                              var prod = products
                                  .where(
                                    (x) => x.id == inventories[index].productId,
                                  )
                                  .firstOrNull;
                              var invMeta = inventoryMetaDatas
                                  .where(
                                    (x) =>
                                        x.inventoryId == inventories[index].id,
                                  )
                                  .firstOrNull;
                              return SaleItem(
                                inventory: inventories[index],
                                product: prod!,
                                inventoryMetadata: invMeta!,
                              );
                            }),
                          ),
                        );
                      },
                    ),
                    ConfirmSaleView(inventory: inventories),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
