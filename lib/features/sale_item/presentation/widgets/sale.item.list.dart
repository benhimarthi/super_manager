import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/sale_item/presentation/widgets/sale.product.item.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

class SaleItemList extends StatefulWidget {
  final Map<String, dynamic> saleItems;
  const SaleItemList({super.key, required this.saleItems});

  @override
  State<SaleItemList> createState() => _SaleItemListState();
}

class _SaleItemListState extends State<SaleItemList> {
  @override
  Widget build(BuildContext context) {
    /*return BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
      listener: (context, state) {},
      builder: (context, state) {
        
      },
    );*/
    return AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text("My products", style: TextStyle(color: Colors.white)),
      content: SizedBox(
        //width: 400, //double.infinity,
        width: MediaQuery.of(context).size.width * .99,
        height: 300,
        child: ListView(
          children: List.generate(widget.saleItems.values.length, (index) {
            final data = widget.saleItems.values.toList()[0];
            final productName = data.first;
            final totalAmount = data[1].totalAmount;
            final quantity = data[2].quantity;
            return saleProductItem(
              context,
              productName,
              totalAmount,
              quantity,
              onDelete: () {
                setState(() {
                  context.read<WidgetManipulatorCubit>().emitRandomElement({
                    "id": "delete_sale",
                    "sale_id": data[1].id,
                    "product_id": data[2].productId,
                  });
                });
                Navigator.pop(context);
              },
            );
          }),
        ),
      ),
    );
  }
}
