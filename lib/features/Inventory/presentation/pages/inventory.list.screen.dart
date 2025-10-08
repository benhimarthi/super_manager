import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/domain/entities/inventory.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/delete.inventory.confirmation.view.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.form.data.dart';
import 'package:super_manager/features/action_history/domain/entities/action.history.dart';
import 'package:super_manager/features/action_history/presentation/cubit/action.history.cubit.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';
import 'package:super_manager/features/product/presentation/cubit/product.cubit.dart';
import 'package:super_manager/features/inventory_meta_data/presentation/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';
import '../../../action_history/presentation/cubit/action.history.state.dart';
import '../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';
import '../../../product/presentation/cubit/product.state.dart';
import '../../../inventory_meta_data/presentation/inventory_meta_data_cubit/inventory.meta.data.state.dart';
import '../cubit/inventory.cubit.dart';
import '../cubit/inventory.state.dart';
import '../widgets/add.inventory.item.options.dart';
import '../widgets/inventory.item.card.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  late List<Product> products;
  late List<InventoryMetadata> metadatas;
  late List<Inventory> myInventories;
  late List<ActionHistory> myInventoryHistory;

  @override
  void initState() {
    super.initState();
    products = [];
    metadatas = [];
    myInventories = [];
    myInventoryHistory = [];
    context.read<InventoryCubit>().loadInventory();
    context.read<ProductCubit>().loadProducts();
    context.read<InventoryMetadataCubit>().loadMetadata();
    context.read<ActionHistoryCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        //color: Colors.grey,
        child: Column(
          children: [
            BlocConsumer<ActionHistoryCubit, ActionHistoryState>(
              listener: (context, state) {
                if (state is ActionHistoryManagerLoaded) {
                  myInventoryHistory = state.historyList
                      .where((x) => x.entityType == "inventory")
                      .toList();
                }
              },
              builder: (context, state) {
                return Container();
              },
            ),
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
              listener: (context, state) {
                if (state is InventoryManagerLoaded) {
                  myInventories = state.inventoryList;
                }
              },
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
                  return SizedBox(
                    width: double.infinity,
                    //height: MediaQuery.of(context).size.height * .9,
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
                        SizedBox(
                          //color: Colors.green,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * .8,
                          child: ListView.builder(
                            itemCount: inventoryList.length,
                            itemBuilder: (context, index) {
                              final item = inventoryList[index];
                              final myProduct = products
                                  .where((x) => x.id == item.productId)
                                  .firstOrNull;
                              final myProductId = myProduct != null
                                  ? myProduct.id
                                  : "";
                              final ItemHistories = myInventoryHistory
                                  .where((x) => x.entityId == item.id)
                                  .toList();
                              return InventoryItemCard(
                                isInfoDisplayer: false,
                                myInventories: inventoryList
                                    .where((x) => x.productId == myProductId)
                                    .toList(),
                                inventory: item,
                                product: myProduct,
                                myInventoryHistory: ItemHistories,
                                metadata: metadatas
                                    .where((x) => x.inventoryId == item.id)
                                    .firstOrNull,
                                onTap: () {
                                  // Navigate to detail or edit screen
                                },
                                onEdit: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InventoryFormData(
                                        myInventories: myInventories,
                                        isBuilding: false,
                                        inventory: inventoryList[index],
                                      );
                                    },
                                  );
                                },
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return DeleteInventoryConfirmationView(
                                        deletedInventory: inventoryList[index],
                                        inventoryMetaData: metadatas
                                            .where(
                                              (x) =>
                                                  x.inventoryId ==
                                                  inventoryList[index].id,
                                            )
                                            .firstOrNull,
                                      );
                                    },
                                  );
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
          if (products.isEmpty) return;
          showDialog(
            context: context,
            builder: (context) {
              return addItemOptions(
                title: "Add inventory item",
                onAdd: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return InventoryFormData(
                        isBuilding: true,
                        myInventories: myInventories,
                      );
                    },
                  );
                },
                context: context,
              );
              /*InventoryFormData(
                isBuilding: true,
                myInventories: myInventories,
              );*/
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
