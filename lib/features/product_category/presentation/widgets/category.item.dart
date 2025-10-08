import 'package:flutter/material.dart';
import 'package:super_manager/features/image_manager/presentation/widgets/profile.image.dart';
import 'package:super_manager/features/product_category/domain/entities/product.category.dart';
import 'package:super_manager/features/product_category/presentation/pages/category.form.page.dart';
import 'package:super_manager/features/product_category/presentation/widgets/item.id.card.dart';

import 'delete.product.category.cofirmation.view.dart';

class CategoryItem extends StatefulWidget {
  final ProductCategory category;
  final List<ProductCategory> categories;
  const CategoryItem({
    super.key,
    required this.category,
    required this.categories,
  });

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      //padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.category.name),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CategoryFormPage(category: widget.category);
                      },
                    );
                  },
                  child: Container(
                    width: 90,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      //color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Edit", style: TextStyle(color: Colors.green)),
                        Icon(Icons.edit, color: Colors.green),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DeleteProductCategoryConfirmationView(
                          category: widget.category,
                        );
                      },
                    );
                  },
                  child: Container(
                    width: 90,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      //color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Remove", style: TextStyle(color: Colors.red)),
                        Icon(Icons.close, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                ProfileImage(
                  itemId: widget.category.id,
                  entityType: "category",
                  name: widget.category.name,
                  radius: 20,
                  fontSize: 10,
                  displayEdit: false,
                ),
                SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Parent category",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    widget.category.parentId!.isEmpty ||
                            !widget.categories
                                .map((x) => x.id)
                                .toList()
                                .contains(widget.category.parentId)
                        ? Text(
                            "None",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: const Color.fromARGB(134, 0, 0, 0),
                            ),
                            textAlign: TextAlign.start,
                          )
                        : ItemIdCard(
                            itemId: widget.category.parentId!,
                            itemName: widget.categories
                                .where((x) => x.id == widget.category.parentId)
                                .first
                                .name,
                          ),
                    Text(
                      "Category description",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(widget.category.description!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
