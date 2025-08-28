import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/Inventory/presentation/widgets/add.inventory.item.options.dart';
import 'package:super_manager/features/product/presentation/widgets/product.card.item.dart';
import 'package:super_manager/features/product_category/presentation/widgets/product.category.view.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../domain/entities/product.dart';
import '../cubit/product.cubit.dart';
import '../cubit/product.state.dart';
import 'product.form.page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late List<String> categoryFilters;
  late List<Product> productList;
  late List<Product> myProduct;
  @override
  void initState() {
    super.initState();
    categoryFilters = [];
    productList = [];
    context.read<ProductCubit>().loadProducts();
  }

  void _addProduct() {
    showDialog(
      context: context,
      builder: (context) => const ProductFormPage(create: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductCubit, ProductState>(
      listener: (context, stateP) {
        if (stateP is ProductManagerLoaded) {
          setState(() {
            myProduct = stateP.products;
            productList = stateP.products;
          });
        }
      },
      builder: (context, stateP) {
        if (stateP is ProductManagerLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (stateP is ProductManagerError) {
          return Center(child: Text('Error: ${stateP.message}'));
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Products')),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .1,
                  child: Column(
                    children: [
                      BlocConsumer<
                        WidgetManipulatorCubit,
                        WidgetManipulatorState
                      >(
                        listener: (context, state) {
                          if (state
                              is SelectingProductCategoryFilterSuccessfully) {
                            setState(() {
                              if (categoryFilters.contains(state.categoryuid)) {
                                categoryFilters.remove(state.categoryuid);
                              } else {
                                categoryFilters.add(state.categoryuid);
                              }
                              if (categoryFilters.isNotEmpty) {
                                productList = myProduct
                                    .where(
                                      (x) => categoryFilters.contains(
                                        x.categoryId,
                                      ),
                                    )
                                    .toList();
                              } else {
                                productList = myProduct;
                              }
                            });
                          }
                        },
                        builder: (context, state) {
                          return ProductCategoryView();
                        },
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .8,
                  child: ListView.builder(
                    itemCount: productList.length,
                    itemBuilder: (context, index) {
                      final product = productList[index];
                      return ProductCardItem(product: product);
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return addItemOptions(
                    title: "Add product item",
                    onAdd: () {
                      _addProduct();
                    },
                    context: context,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
