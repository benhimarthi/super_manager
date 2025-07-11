import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/product/presentation/widgets/product.card.item.dart';
import 'package:super_manager/features/product_category/presentation/pages/product.category.view.dart';
import '../cubit/product.cubit.dart';
import '../cubit/product.state.dart';
import 'product.form.page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  void initState() {
    super.initState();
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
    return BlocBuilder<ProductCubit, ProductState>(
      builder: (context, state) {
        if (state is ProductManagerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductManagerError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        final productList = state is ProductManagerLoaded ? state.products : [];
        return Scaffold(
          appBar: AppBar(title: const Text('Products')),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * .1,
                  //color: Colors.amber,
                  child: Column(
                    children: [
                      ProductCategoryView(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
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
              _addProduct();
            },
          ),
        );
      },
    );
  }
}
