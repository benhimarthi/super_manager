import 'package:flutter/material.dart';

saleProductItem(
  context,
  String productName,
  double totalAmount,
  //onDelete,
  int quantity, {
  String currency = "MAD",
  required Function onDelete,
}) {
  return Transform.scale(
    scale: .9,
    child: Container(
      padding: EdgeInsets.all(2),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 90,
            //color: Colors.amber,
            child: Text(
              productName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white, //Theme.of(context).primaryColor,
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
          SizedBox(width: 5),
          SizedBox(
            width: 50,
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
            onTap: () {
              onDelete();
            },
            child: CircleAvatar(
              child: Icon(Icons.close, color: Colors.red, size: 14),
            ),
          ),
        ],
      ),
    ),
  );
}
