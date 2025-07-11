import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

class CurrencyPickerDropdown extends StatefulWidget {
  const CurrencyPickerDropdown({super.key});

  @override
  _CurrencyPickerDropdownState createState() => _CurrencyPickerDropdownState();
}

class _CurrencyPickerDropdownState extends State<CurrencyPickerDropdown> {
  Country? selectedCountry;

  @override
  Widget build(BuildContext context) {
    return CountryPickerDropdown(
      initialValue: 'US',
      itemBuilder: _buildDropdownItem,
      onValuePicked: (Country? country) {
        if (country == null) return;
        setState(() {
          selectedCountry = country;
          context.read<WidgetManipulatorCubit>().selectCurrency(
            country.currencyName!,
            country.name!,
          );
        });
      },
    );
  }

  Widget _buildDropdownItem(Country country) {
    return Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        Container(width: 5.0),
        SizedBox(
          height: 30,
          child: Text(
            "${country.currencyCode} - ${country.name}",
            style: TextStyle(fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
