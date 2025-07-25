import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.form.data.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';
import 'package:super_manager/features/product/presentation/cubit/product.cubit.dart';
import 'package:super_manager/features/synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';
import '../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';
import '../../../product/presentation/cubit/product.state.dart';
import '../../../synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.state.dart';
import '../cubit/inventory.cubit.dart';
import '../cubit/inventory.state.dart';
import '../widgets/inventory.item.card.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({Key? key}) : super(key: key);

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  late List<Product> products;
  late List<InventoryMetadata> metadatas;
  @override
  void initState() {
    super.initState();
    products = [];
    metadatas = [];
    context.read<InventoryCubit>().loadInventory();
    context.read<ProductCubit>().loadProducts();
    context.read<InventoryMetadataCubit>().loadMetadata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        //color: Colors.grey,
        child: Column(
          children: [
            BlocConsumer<ProductCubit, ProductState>(
              listener: (context, state) {
                if (state is ProductManagerLoaded) {
                  products = state.products;
                }
              },
              builder: (context, state) {
                return Container();
              },
            ),
            BlocConsumer<InventoryMetadataCubit, InventoryMetadataState>(
              listener: (context, state) {
                if (state is InventoryMetadataManagerLoaded) {
                  metadatas = state.metadataList;
                }
              },
              builder: (context, state) {
                return Container();
              },
            ),
            BlocConsumer<InventoryCubit, InventoryState>(
              listener: (context, state) {},
              builder: (context, state) {
                if (state is InventoryManagerLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is InventoryManagerError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is InventoryManagerLoaded) {
                  final inventoryList = state.inventoryList;
                  if (inventoryList.isEmpty) {
                    return const Center(
                      child: Text('No inventory items found.'),
                    );
                  }
                  return Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * .9,
                    //color: Colors.amber,
                    child: Column(
                      children: [
                        BlocConsumer<ProductCubit, ProductState>(
                          listener: (context, state) {
                            if (state is ProductManagerLoaded) {
                              products = state.products;
                            }
                          },
                          builder: (context, state) {
                            return Container();
                          },
                        ),
                        BlocConsumer<
                          InventoryMetadataCubit,
                          InventoryMetadataState
                        >(
                          listener: (context, state) {
                            if (state is InventoryMetadataManagerLoaded) {
                              metadatas = state.metadataList;
                            }
                          },
                          builder: (context, state) {
                            return Container();
                          },
                        ),
                        Container(
                          //color: Colors.green,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * .8,
                          child: ListView.builder(
                            itemCount: inventoryList.length,
                            itemBuilder: (context, index) {
                              final item = inventoryList[index];
                              return InventoryItemCard(
                                inventory: item,
                                product: products
                                    .where((x) => x.id == item.productId)
                                    .firstOrNull,
                                metadata: metadatas
                                    .where((x) => x.inventoryId == item.id)
                                    .firstOrNull,
                                onTap: () {
                                  // Navigate to detail or edit screen
                                },
                                onEdit: () {
                                  // Trigger edit action
                                },
                                onDelete: () {
                                  // Trigger delete action
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return InventoryFormData(isBuilding: true);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
