import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/action.history.dart';
import '../cubit/action.history.cubit.dart';
import '../cubit/action.history.state.dart';

// Assume ActionHistory, ActionHistoryCubit, and ActionHistoryManagerLoaded are imported

class ActionHistoryListScreen extends StatelessWidget {
  const ActionHistoryListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Action History')),
      body: BlocBuilder<ActionHistoryCubit, ActionHistoryState>(
        builder: (context, state) {
          if (state is ActionHistoryManagerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ActionHistoryManagerError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ActionHistoryManagerLoaded) {
            final historyList = state.historyList;
            if (historyList.isEmpty) {
              return const Center(child: Text('No history found.'));
            }
            return ListView.builder(
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final item = historyList[index];
                return ActionHistoryCard(action: item);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class ActionHistoryCard extends StatelessWidget {
  final ActionHistory action;

  const ActionHistoryCard({Key? key, required this.action}) : super(key: key);

  Widget _buildChangeSummary(Map<String, Map<String, dynamic>> changes) {
    if (changes.isEmpty) {
      return const Text(
        'No field changes.',
        style: TextStyle(color: Colors.grey),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: changes.entries.map((entry) {
        final field = entry.key;
        final oldVal = entry.value['old'];
        final newVal = entry.value['new'];
        return Text(
          '$field: $oldVal → $newVal',
          style: const TextStyle(fontSize: 13),
        );
      }).toList(),
    );
  }

  Widget _buildContextSummary(Map<String, dynamic> context) {
    if (context.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 16,
      children: context.entries
          .map((e) => Chip(label: Text('${e.key}: ${e.value}')))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: What and Who
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  action.entityName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  action.action.toUpperCase(),
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'by ${action.performedByName} • ${action.timestamp.toLocal()}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            if (action.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(action.description),
              ),

            // Changes
            const Text(
              'Changes:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            _buildChangeSummary(action.changes),
            const SizedBox(height: 8),

            // Status transitions
            Row(
              children: [
                const Text('Status:'),
                const SizedBox(width: 8),
                Chip(
                  label: Text(action.statusBefore),
                  backgroundColor: Colors.grey[300],
                ),
                const Icon(Icons.arrow_forward, size: 18),
                Chip(
                  label: Text(action.statusAfter),
                  backgroundColor: Colors.lightGreen[100],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Context
            if (action.context.isNotEmpty) ...[
              const Text(
                'Context:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              _buildContextSummary(action.context),
              const SizedBox(height: 8),
            ],

            // Module and Entity
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Module: ${action.module}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Entity Type: ${action.entityType}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
