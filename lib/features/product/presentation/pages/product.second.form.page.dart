import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/image_manager/presentation/cubit/app.image.cubit.dart';
import 'package:super_manager/features/product/data/models/product.model.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../../image_manager/domain/entities/app.image.dart';
import '../../domain/entities/product.dart';
import '../cubit/product.cubit.dart';
import '../widgets/product.pricing.view.dart';

class ProductSecondFormPage extends StatefulWidget {
  final List<AppImage> myProductImages;
  final bool creation;
  const ProductSecondFormPage({
    super.key,
    required this.myProductImages,
    required this.creation,
  });

  @override
  State<ProductSecondFormPage> createState() => _ProductSecondFormPageState();
}

class _ProductSecondFormPageState extends State<ProductSecondFormPage> {
  late TextEditingController _unit;
  late TextEditingController _barcode;
  late Product? product;
  bool _active = true;
  late String princingValue = "";

  @override
  void initState() {
    super.initState();
    var state = context.read<WidgetManipulatorCubit>().state;
    if (state is CacheProductSuccessfully) {
      product = state.product;
    } else {
      product = null;
    }
    _unit = TextEditingController(text: "");
    _barcode = TextEditingController(text: "");
    _active = false;
  }

  _submit() {
    for (var t in widget.myProductImages) {
      context.read<AppImageManagerCubit>().createImage(t);
    }
    final finalProduct = ProductModel.fromEntity(product!).copyWith(
      barcode: _barcode.text.trim(),
      unit: _unit.text.trim(),
      active: _active,
      pricingId: princingValue.isNotEmpty
          ? princingValue
          : product != null
          ? product!.id
          : "",
    );
    final cubit = context.read<ProductCubit>();
    if (widget.creation) {
      cubit.addProduct(finalProduct);
    } else {
      cubit.updateProduct(finalProduct);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
      listener: (context, state) {
        if (state is CacheProductSuccessfully) {
          var product = state.product;
          _unit = TextEditingController(text: product.unit);
          _barcode = TextEditingController(text: product.barcode);
          _active = product.active;
        }
        if (state is ElementAddedSuccessfully) {
          print("WWWWWWWMMMMMMMMMMMDDDWCCCCCCCCCCCVSSSS ${state.elementId}");
          princingValue = state.elementId;
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              ProductPricingView(productId: product != null ? product!.id : ""),
              SizedBox(height: 10),
              TextFormField(
                controller: _unit,
                decoration: const InputDecoration(
                  labelText: 'Unit (e.g. kg, box)',
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _barcode,
                decoration: InputDecoration(
                  labelText: 'Barcode',
                  suffixIcon: Icon(
                    Icons.barcode_reader,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SwitchListTile(
                title: const Text('Active'),
                value: _active,
                onChanged: (val) => setState(() => _active = val),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _submit, child: const Text('Save')),
            ],
          ),
        );
      },
    );
  }
}
