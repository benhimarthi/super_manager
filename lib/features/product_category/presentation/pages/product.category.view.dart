import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/product_category/presentation/pages/product.category.image.item.dart';
import '../../domain/entities/product.category.dart';
import '../cubit/local.category.manager.cubit.dart';
import '../cubit/local.category.manager.state.dart';

class ProductCategoryView extends StatefulWidget {
  const ProductCategoryView({super.key});

  @override
  State<ProductCategoryView> createState() => _ProductCategoryViewState();
}

class _ProductCategoryViewState extends State<ProductCategoryView> {
  late List<ProductCategory> myProductCategories;
  late bool isSelected = true;

  @override
  void initState() {
    super.initState();
    myProductCategories = [];
    context.read<LocalCategoryManagerCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocalCategoryManagerCubit, LocalCategoryManagerState>(
      listener: (context, state) {
        if (state is LocalCategoryManagerLoaded) {
          setState(() {
            myProductCategories = state.categories.toList();
          });
        }
      },
      builder: (context, state) {
        return SizedBox(
          width: 350,
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: myProductCategories.length,
            itemBuilder: (context, ind) {
              return Container(
                margin: EdgeInsets.only(right: 20),
                padding: EdgeInsets.all(10),
                decoration: isSelected
                    ? BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      )
                    : BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Color.fromARGB(255, 27, 29, 31),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                child: Row(
                  children: [
                    ProductCategoryImageItem(
                      categoryUid: myProductCategories[ind].id,
                    ),
                    SizedBox(width: 5),
                    Text(
                      myProductCategories[ind].name,
                      style: TextStyle(
                        color: Color.fromARGB(255, 103, 82, 145),
                      ),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
