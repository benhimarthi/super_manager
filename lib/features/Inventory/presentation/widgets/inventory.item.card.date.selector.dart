import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/action_history/domain/entities/action.history.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../widge_manipulator/cubit/widget.manipulator.state.dart';

class InventoryItemCardDateSelector extends StatefulWidget {
  final List<ActionHistory> myHistories;
  const InventoryItemCardDateSelector({super.key, required this.myHistories});

  @override
  State<InventoryItemCardDateSelector> createState() =>
      _InventoryItemCardDateSelectorState();
}

class _InventoryItemCardDateSelectorState
    extends State<InventoryItemCardDateSelector> {
  DateTime? _startDate;
  DateTime? _endDate;
  late String selectedPeriod;
  @override
  void initState() {
    super.initState();
    selectedPeriod = "Monthly";
    Future.delayed(Duration(seconds: 3), () {
      _endDate = DateTime.now();
      _startDate = getPeriodStart(_endDate!, selectedPeriod);
      context
          .read<WidgetManipulatorCubit>()
          .emitRandomElement({
            "id": "filter_sales_by_date",
            "start_date": _startDate,
            "end_date": _endDate,
          })
          .whenComplete(() {
            setState(() {});
          });
    });
  }

  Future<void> _pickDate(bool isStart) async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      var myInventoryHistory = widget.myHistories;
      myInventoryHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      setState(() {
        if (isStart) {
          _startDate = picked.isBefore(myInventoryHistory.first.timestamp)
              ? myInventoryHistory.first.timestamp
              : (picked.isAfter(DateTime.now()) ? DateTime.now() : picked);
        } else {
          _endDate = picked;
          if (picked.isBefore(_startDate!)) {
            _endDate = _startDate;
            _startDate = picked.isBefore(myInventoryHistory.first.timestamp)
                ? myInventoryHistory.first.timestamp
                : picked;
          } else if (picked.isAfter(DateTime.now())) {
            _endDate = DateTime.now();
          } else {
            _endDate = picked;
          }
        }
        // Optionally: filter data here or trigger callback
      });
      context.read<WidgetManipulatorCubit>().emitRandomElement({
        "id": "filter_sales_by_date",
        "start_date": _startDate,
        "end_date": _endDate,
      });
    }
  }

  DateTime getPeriodStart(DateTime now, String period) {
    var myInventoryHistory = widget.myHistories;
    myInventoryHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    switch (period) {
      case 'Weekly':
        // Monday as first day of week
        final today = now.subtract(Duration(days: now.weekday - 1));
        return today.isBefore(myInventoryHistory.first.timestamp)
            ? myInventoryHistory.first.timestamp
            : today;
      case 'Monthly':
        final month = DateTime(now.year, now.month, 1);
        return month.isBefore(myInventoryHistory.first.timestamp)
            ? myInventoryHistory.first.timestamp
            : month;
      case 'Semestrial':
        final period = now.month <= 6
            ? DateTime(now.year, 1, 1)
            : DateTime(now.year, 7, 1);
        return period.isBefore(myInventoryHistory.first.timestamp)
            ? myInventoryHistory.first.timestamp
            : period;
      case 'Yearly':
        final year = DateTime(now.year, 1, 1);
        return year.isBefore(myInventoryHistory.first.timestamp)
            ? myInventoryHistory.first.timestamp
            : year;
      default:
        return now;
    }
  }

  //double averageInventory() {}

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              underline: SizedBox(),
              value: selectedPeriod,
              items: ['Weekly', 'Monthly', 'Semestrial', 'Yearly']
                  .map(
                    (period) => DropdownMenuItem(
                      value: period,
                      child: Text(
                        period,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value!;
                  _startDate = getPeriodStart(DateTime.now(), selectedPeriod);
                  context.read<WidgetManipulatorCubit>().emitRandomElement({
                    "id": "filter_sales_by_date",
                    "start_date": _startDate,
                    "end_date": _endDate,
                  });
                });
              },
            ),
            //SizedBox(width: 8),
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onTap: () => _pickDate(true),
                child: Text(
                  _startDate == null
                      ? 'Start Date'
                      : _startDate.toString().split(' ')[0],
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            //SizedBox(width: 8),
            Text("->", style: TextStyle(color: Colors.white)),
            //SizedBox(width: 8),
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: GestureDetector(
                onTap: () => _pickDate(false),
                child: Text(
                  _endDate == null
                      ? 'End Date'
                      : _endDate.toString().split(' ')[0],
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            GestureDetector(
              child: Icon(
                Icons.help,
                size: 18,
                color: Colors.white, //Theme.of(context).primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
