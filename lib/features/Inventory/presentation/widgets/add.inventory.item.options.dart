import 'package:flutter/material.dart';
import 'package:super_manager/features/product/data/models/product.model.dart';
import '../../../../core/file_reader/file_data_reader.dart';
import '../../../product/presentation/pages/product.form.page.dart';

void openFile(context) async {
  Object? data = await FileDataReader.pickAndReadFile();
  try {
    var datas = data as List<Map<String, dynamic>>;
    var productModel = ProductModel.fromMap(datas[0]);
    _addProduct(context, productModel);
  } catch (e) {}
}

void _addProduct(context, prod) {
  showDialog(
    context: context,
    builder: (context) => ProductFormPage(create: false, product: prod),
  );
}

addItemOptions({
  required String title,
  required Function onAdd,
  required context,
}) {
  return AlertDialog(
    title: Text(
      title,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
      ),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                onAdd();
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
            GestureDetector(
              onTap: () {
                openFile(context);
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.document_scanner, color: Colors.white),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: GestureDetector(child: Text("Cancel")),
          ),
        ),
      ],
    ),
  );
}
