import 'package:flutter/material.dart';

class InventoryRelevantNumbersView extends StatefulWidget {
  const InventoryRelevantNumbersView({super.key});

  @override
  State<InventoryRelevantNumbersView> createState() =>
      _InventoryRelevantNumbersViewState();
}

class _InventoryRelevantNumbersViewState
    extends State<InventoryRelevantNumbersView> {
  Widget _inventoryNbInfos(String title, double value, bool selected) {
    return Container(
      height: 60,
      width: 100,
      padding: EdgeInsets.all(3),
      decoration: selected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.amber, width: 2),
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color.fromARGB(255, 88, 88, 88),
                width: 2,
              ),
            ),
      child: Column(
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      //color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Stock turn over rate",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.amber),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 65,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [_inventoryNbInfos("Stock turn over rate", 0.5, false)],
            ),
          ),
        ],
      ),
    );
  }
}
