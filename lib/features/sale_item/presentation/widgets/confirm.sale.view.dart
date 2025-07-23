import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';

class ConfirmSaleView extends StatefulWidget {
  const ConfirmSaleView({super.key});

  @override
  State<ConfirmSaleView> createState() => _ConfirmSaleViewState();
}

class _ConfirmSaleViewState extends State<ConfirmSaleView> {
  late Map<String, dynamic> saleItems;
  @override
  void initState() {
    super.initState();
    saleItems = {};
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
        listener: (context, state) {
          if (state is EmitRandomElementSuccessfully) {
            try {
              setState(() {
                var value = (state.element as Map<String, dynamic>);
                if (value['id'] == "sale") {
                  saleItems[value['sale'].id] = [
                    value['product_name'],
                    value['sale'],
                    value['sale_item'],
                  ];
                } else if (value['id'] == "sale_update") {
                  saleItems[value['sale'].id] = [
                    value['product_name'],
                    value['sale'],
                    value['sale_item'],
                  ];
                  print(saleItems);
                }
              });
            } catch (e) {
              print(e);
            }
          }
        },
        builder: (context, state) {
          return Visibility(
            visible: saleItems.isNotEmpty,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 340,
              //height: 100,
              decoration: BoxDecoration(
                color: Colors.green, //Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Visibility(
                          visible: saleItems.length > 1,
                          child: Text(
                            "See More...",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 150,
                          constraints: BoxConstraints(maxHeight: 200),
                          child: ListView(
                            children: List.generate(saleItems.values.length, (
                              index,
                            ) {
                              final data = saleItems.values.toList()[index];
                              final productName = data.first;
                              final totalAmount = data[1].totalAmount;
                              final quantity = data[2].quantity;
                              return saleProductItem(
                                productName,
                                totalAmount,
                                quantity,
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: Text(
                        "REGISTER SALES",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  saleProductItem(
    String productName,
    double totalAmount,
    int quantity, {
    String currency = "MAD",
  }) {
    return Container(
      padding: EdgeInsets.all(2),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 110,
            //color: Colors.amber,
            child: Text(
              productName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 90,
            //color: Colors.amber,
            child: Text(
              "$currency $totalAmount",
              style: TextStyle(
                //color: Colors.blue
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 60,
            //color: Colors.amber,
            child: Text(
              "x$quantity",
              style: TextStyle(
                //color: Colors.blue
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            child: CircleAvatar(
              child: Icon(Icons.close, color: Colors.red, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}
