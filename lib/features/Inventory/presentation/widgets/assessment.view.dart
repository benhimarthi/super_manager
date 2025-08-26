import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/assessment.relevant.numbers.view.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.item.card.date.selector.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

import '../../../action_history/domain/entities/action.history.dart';
import '../../../action_history/presentation/cubit/action.history.cubit.dart';
import '../../../action_history/presentation/cubit/action.history.state.dart';
import '../../../inventory_meta_data/domain/entities/inventory.meta.data.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/presentation/cubit/product.cubit.dart';
import '../../../product/presentation/cubit/product.state.dart';
import '../../../synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.cubit.dart';
import '../../../synchronisation/cubit/inventory_meta_data_cubit/inventory.meta.data.state.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../domain/entities/inventory.dart';
import '../cubit/inventory.cubit.dart';
import '../cubit/inventory.state.dart';
import 'inventory.form.data.dart';
import 'inventory.item.card.dart';

class AssessmentView extends StatefulWidget {
  const AssessmentView({super.key});

  @override
  State<AssessmentView> createState() => _AssessmentViewState();
}

class _AssessmentViewState extends State<AssessmentView> {
  late List<Product> products;
  late List<InventoryMetadata> metadatas;
  late List<Inventory> myInventories;
  late List<ActionHistory> myInventoryHistory;
  late Set<Map<String, dynamic>> availableQuantitySet = {};
  late Set<Map<String, dynamic>> reservedQuantitySet = {};
  late Set<Map<String, dynamic>> soldQuantitySet = {};
  late int totalAvailableQuantity = 0;
  late int totalReservedQuantity = 0;
  late int totalSoldQuantity = 0;

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

  Widget _buildQuantityInfo(String label, int value, context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  calculateKPI(dt) {
    return dt.map((x) => x.values.first).toList().reduce((a, b) => a + b);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Assessment")),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          //height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
                listener: (context, state) {
                  try {
                    if (state is EmitRandomElementSuccessfully) {
                      var data = (state.element as Map<String, dynamic>);
                      if (data['id'] == 'activity_numbers') {
                        setState(() {
                          availableQuantitySet.add({
                            data["inv_id"]: data["datas"]["available_quantity"],
                          });
                          totalAvailableQuantity = calculateKPI(
                            availableQuantitySet,
                          );
                          soldQuantitySet.add({
                            data["inv_id"]: data["datas"]["sold_quantity"],
                          });
                          totalSoldQuantity = calculateKPI(soldQuantitySet);
                          reservedQuantitySet.add({
                            data["inv_id"]: data["datas"]["reserved_quantity"],
                          });
                          totalReservedQuantity = calculateKPI(
                            reservedQuantitySet,
                          );
                        });
                      }
                    }
                  } catch (e) {}
                },
                builder: (context, state) {
                  return Container();
                },
              ),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          InventoryItemCardDateSelector(
                            myHistories: myInventoryHistory,
                          ),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _buildQuantityInfo(
                                'Available',
                                totalAvailableQuantity,
                                context,
                              ),
                              _buildQuantityInfo(
                                'Reserved',
                                totalReservedQuantity,
                                context,
                              ),
                              _buildQuantityInfo(
                                'Sold',
                                totalSoldQuantity,
                                context,
                              ),
                            ],
                          ),
                          AssessmentRelevantNumbersView(),
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
                                final itemHistories = myInventoryHistory
                                    .where((x) => x.entityId == item.id)
                                    .toList();
                                return Visibility(
                                  visible: true,
                                  child: InventoryItemCard(
                                    isInfoDisplayer: false,
                                    myInventories: inventoryList
                                        .where(
                                          (x) => x.productId == myProductId,
                                        )
                                        .toList(),
                                    inventory: item,
                                    product: myProduct,
                                    myInventoryHistory: itemHistories,
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
                                      // Trigger delete action
                                    },
                                  ),
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
      ),
    );
  }
}
