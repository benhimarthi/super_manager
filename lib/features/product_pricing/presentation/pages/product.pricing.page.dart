import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/product.pricing.cubit.dart';
import '../cubit/product.pricing.state.dart';
import '../widgets/product.pricing.form.page.dart';

class ProductPricingPage extends StatefulWidget {
  final String productId;
  const ProductPricingPage({super.key, required this.productId});

  @override
  State<ProductPricingPage> createState() => _ProductPricingPageState();
}

class _ProductPricingPageState extends State<ProductPricingPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductPricingCubit, ProductPricingState>(
      builder: (context, state) {
        if (state is ProductPricingManagerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductPricingManagerError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        final pricingList = state is ProductPricingManagerLoaded
            ? state.pricingList
            : [];

        return Scaffold(
          appBar: AppBar(title: const Text('Product Pricing')),
          body: ListView.builder(
            itemCount: pricingList.length,
            itemBuilder: (context, index) {
              final item = pricingList[index];
              return ListTile(
                title: Text(
                  '${item.currency} ${item.amount.toStringAsFixed(2)} (${item.country})',
                ),
                subtitle: Text(
                  'Discount: ${item.discountPercent.toStringAsFixed(1)}%',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        /*Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                //ProductPricingFormPage(pricing: item),
                          ),
                        );*/
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context.read<ProductPricingCubit>().deletePricing(
                          item.id,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductPricingFormPage(productId: widget.productId),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
