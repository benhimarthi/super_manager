import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/inventory.form.data.dart';

import '../cubit/inventory.cubit.dart';
import '../cubit/inventory.state.dart';
import '../widgets/inventory.item.card.dart';
import 'inventory.detail.screen.dart';

class InventoryListScreen extends StatelessWidget {
  const InventoryListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: BlocBuilder<InventoryCubit, InventoryState>(
        builder: (context, state) {
          if (state is InventoryManagerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InventoryManagerError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is InventoryManagerLoaded) {
            final inventoryList = state.inventoryList;
            if (inventoryList.isEmpty) {
              return const Center(child: Text('No inventory items found.'));
            }
            return ListView.builder(
              itemCount: inventoryList.length,
              itemBuilder: (context, index) {
                final item = inventoryList[index];
                return InventoryItemCard(
                  inventory: item,
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
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return InventoryFormData();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
