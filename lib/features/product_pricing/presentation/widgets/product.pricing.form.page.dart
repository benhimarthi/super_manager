import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/session/session.manager.dart';
import 'package:super_manager/features/authentication/domain/entities/user.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import 'package:uuid/uuid.dart';

import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';
import '../../domain/entities/product.pricing.dart';
import '../cubit/product.pricing.cubit.dart';
import 'currency.picker.dropdown.dart';

class ProductPricingFormPage extends StatefulWidget {
  final ProductPricing? pricing;
  final String productId;

  const ProductPricingFormPage({
    super.key,
    this.pricing,
    required this.productId,
  });

  @override
  State<ProductPricingFormPage> createState() => _ProductPricingFormPageState();
}

class _ProductPricingFormPageState extends State<ProductPricingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late String pricingId;
  late String _currency;
  late String _country;
  late TextEditingController _amount;
  late TextEditingController _discount;
  late User _currentUser;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final pricing = widget.pricing;
    pricingId = widget.pricing?.id ?? Uuid().v4();
    _currency = "";
    _country = "";
    _amount = TextEditingController(text: pricing?.amount.toString() ?? '');
    _discount = TextEditingController(
      text: pricing?.discountPercent.toString() ?? '',
    );
    _active = pricing?.active ?? true;
    _currentUser = SessionManager.getUserSession()!;
  }

  @override
  void dispose() {
    _amount.dispose();
    _discount.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final pricing = ProductPricing(
      creatorId: _currentUser.id,
      id: pricingId,
      productId: widget.pricing?.productId ?? widget.productId,
      currency: _currency,
      country: _country,
      amount: double.parse(_amount.text.trim()),
      discountPercent: double.parse(_discount.text.trim()),
      active: _active,
      createdAt: widget.pricing?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final cubit = context.read<ProductPricingCubit>();

    if (widget.pricing == null) {
      cubit.addPricing(pricing).whenComplete(() {});
      context.read<WidgetManipulatorCubit>().addELement(pricingId);
    } else {
      cubit.updatePricing(pricing).whenComplete(() {});
      context.read<WidgetManipulatorCubit>().addELement(pricingId);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.pricing == null ? 'Add Pricing' : 'Edit Pricing',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
                    listener: (context, state) {
                      if (state is SelectingCurrencySuccessfully) {
                        _currency = state.currency;
                        _country = state.country;
                      }
                    },
                    builder: (context, state) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        width: 300,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [CurrencyPickerDropdown()],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _amount,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _discount,
                    decoration: const InputDecoration(labelText: 'Discount %'),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      Text("Activate pricing"),
                      Transform.scale(
                        scale: .6,
                        child: Switch(
                          //title: const Text('Active'),
                          value: _active,
                          onChanged: (val) => setState(() => _active = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _submit, child: const Text('Save')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
