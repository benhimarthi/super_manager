import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/sale/domain/entities/sale.dart';
import 'package:super_manager/features/sale/presentation/cubit/sale.cubit.dart';
import 'package:super_manager/features/sale_item/domain/entities/sale.item.dart';
import 'package:super_manager/features/sale_item/presentation/cubit/sale.item.cubit.dart';

import '../../../sale/presentation/cubit/sale.state.dart';
import '../cubit/sale.item.state.dart';

class DailyActivityInfos extends StatefulWidget {
  const DailyActivityInfos({super.key});

  @override
  State<DailyActivityInfos> createState() => _DailyActivityInfosState();
}

class _DailyActivityInfosState extends State<DailyActivityInfos> {
  late List<Sale> mySales;
  late List<SaleItem> mySaleItems;
  late int soldQuantity;
  late double amountSold;
  @override
  void initState() {
    super.initState();
    mySales = [];
    mySaleItems = [];
    soldQuantity = 0;
    amountSold = 0;
    context.read<SaleCubit>().loadSales();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SaleCubit, SaleState>(
      listener: (context, state) {
        if (state is SaleManagerLoaded) {
          mySales = state.saleList;
          setState(() {
            amountSold = mySales
                .map((x) => x.totalAmount)
                .toList()
                .reduce((a, b) => a + b);
          });
          for (var n in mySales.map((x) => x.id).toList()) {
            context.read<SaleItemCubit>().loadSaleItems(n);
          }
        }
      },
      builder: (context, state) {
        return Container(
          height: 100,
          //width: 350,
          //color: Colors.amber,
          margin: EdgeInsets.symmetric(horizontal: 6),
          child: ListView(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            scrollDirection: Axis.horizontal,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quantity sold",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  BlocConsumer<SaleItemCubit, SaleItemState>(
                    listener: (context, state) {
                      if (state is SaleItemManagerLoaded) {
                        if (state.saleItemList.isNotEmpty) {
                          mySaleItems.add(state.saleItemList.first);
                          setState(() {
                            soldQuantity += state.saleItemList.first.quantity;
                          });
                        }
                      }
                    },
                    builder: (context, state) {
                      return Text.rich(
                        TextSpan(
                          text: soldQuantity.toString(),
                          style: TextStyle(color: Colors.green, fontSize: 32),
                          children: [
                            TextSpan(
                              text: " item",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(width: 50),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sold Amount",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: amountSold.toStringAsFixed(1),
                      style: TextStyle(color: Colors.green, fontSize: 32),
                      children: [
                        TextSpan(
                          text: " MAD",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
