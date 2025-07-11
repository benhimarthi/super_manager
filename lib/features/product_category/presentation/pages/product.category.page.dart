/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service/depenedancy.injection.dart';
import '../../../../core/util/change.screen.manager.dart';
import '../../domain/entities/product.category.dart';
import '../cubit/local.category.manager.cubit.dart';
import '../cubit/local.category.manager.state.dart';
import '../widgets/category.form.page.dart';
import '../widgets/group.product.category.by.parent.dart';
import '../widgets/sync.status.indicator.dart';

class ProductCategoryPage extends StatefulWidget {
  const ProductCategoryPage({super.key});

  @override
  State<ProductCategoryPage> createState() => _ProductCategoryPageState();
}

class _ProductCategoryPageState extends State<ProductCategoryPage> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LocalCategoryManagerCubit>()..loadCategories(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Categories'),
          actions: const [SyncStatusIndicator()],
        ),
        body: BlocBuilder<LocalCategoryManagerCubit, LocalCategoryManagerState>(
          builder: (context, state) {
            if (state is LocalCategoryManagerLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LocalCategoryManagerLoaded) {
              final grouped = groupByParent(state.categories);
              final treeTiles = buildCategoryTree(
                grouped,
                null,
                context: context,
              );

              return ListView(children: treeTiles);
            }
            if (state is LocalCategoryManagerError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            nextScreen(context, const CategoryFormPage());
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  List<Widget> buildCategoryTree(
    Map<String?, List<ProductCategory>> grouped,
    String? parentId, {
    int depth = 0,
    required BuildContext context,
  }) {
    final children = grouped[parentId] ?? [];

    return children.expand((cat) {
      final isExpanded = _expanded.contains(cat.id);
      final hasSubcats = grouped.containsKey(cat.id);
      final padding = 16.0 * depth;

      return [
        ListTile(
          title: Padding(
            padding: EdgeInsets.only(left: padding),
            child: Text(cat.name),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(left: padding),
            child: Text(cat.description ?? ''),
          ),
          leading: SizedBox(
            width: 70,
            height: 50,
            child: Row(
              children: [
                hasSubcats
                    ? Icon(isExpanded ? Icons.expand_less : Icons.expand_more)
                    : const SizedBox(width: 24),
                cat.iconCodePoint != null
                    ? Icon(
                        IconData(
                          cat.iconCodePoint!,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Colors.teal,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          onTap: () {
            if (hasSubcats) {
              setState(() {
                isExpanded ? _expanded.remove(cat.id) : _expanded.add(cat.id);
              });
            }
          },
          trailing: SizedBox(
            width: 100,
            height: 45,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    nextScreen(context, CategoryFormPage(category: cat));
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Category'),
                        content: const Text(
                          'This will delete this category and all its subcategories. Are you sure?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      context.read<LocalCategoryManagerCubit>().deleteCategory(
                        cat.id,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          ...buildCategoryTree(
            grouped,
            cat.id,
            depth: depth + 1,
            context: context,
          ),
      ];
    }).toList();
  }
}
*/
