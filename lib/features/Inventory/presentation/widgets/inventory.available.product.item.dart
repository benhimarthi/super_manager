import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/product/domain/entities/product.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

import '../../../image_manager/presentation/cubit/app.image.state.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';

class InventoryAvailableProductItem extends StatefulWidget {
  final Product product;
  final String? selectedItemId;
  const InventoryAvailableProductItem({
    super.key,
    this.selectedItemId,
    required this.product,
  });

  @override
  State<InventoryAvailableProductItem> createState() =>
      _InventoryAvailableProductItemState();
}

class _InventoryAvailableProductItemState
    extends State<InventoryAvailableProductItem> {
  late File? myProductImage;
  late bool isItemSelected;
  late String selectedProductUid;
  @override
  void initState() {
    super.initState();
    myProductImage = null;

    selectedProductUid = widget.selectedItemId != null
        ? widget.selectedItemId!
        : "";
    if (selectedProductUid.isNotEmpty) {
      isItemSelected = selectedProductUid == widget.product.id;
    } else {
      isItemSelected = false;
    }
    context.read<AppImageManagerCubit>().loadProductImages(widget.product.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppImageManagerCubit, AppImageState>(
      listener: (context, state) {
        if (state is AppImageProductLoaded) {
          if (state.images.isNotEmpty) {
            var productIamge = state.images
                .where((x) => x.entityId == widget.product.id)
                .firstOrNull;
            if (productIamge != null) {
              myProductImage = File(productIamge.url);
            }
          }
        }
      },
      builder: (context, state) {
        return myProductImage != null
            ? BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
                listener: (context, state) {
                  if (state is EmitRandomElementSuccessfully) {
                    try {
                      setState(() {
                        var emitedProduct = (state.element as String);
                        selectedProductUid = emitedProduct;
                        if (selectedProductUid == widget.product.id &&
                            isItemSelected) {
                          isItemSelected = false;
                          context
                              .read<WidgetManipulatorCubit>()
                              .emitRandomElement("");
                        } else if (selectedProductUid == widget.product.id &&
                            !isItemSelected) {
                          isItemSelected = true;
                        } else if (selectedProductUid != widget.product.id) {
                          isItemSelected = false;
                        }
                      });
                      // ignore: empty_catches
                    } catch (e) {}
                  }
                },
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      context.read<WidgetManipulatorCubit>().emitRandomElement(
                        widget.product.id,
                      );
                    },
                    child: Container(
                      height: 50,
                      width: 90,
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(myProductImage!),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: isItemSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 4,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: EdgeInsets.all(2),
                              margin: EdgeInsets.all(5),
                              width: 75,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(130, 159, 122, 234),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: Text(
                                widget.product.name,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Container(
                height: 50,
                width: 90,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(Icons.image)),
              );
      },
    );
  }
}
