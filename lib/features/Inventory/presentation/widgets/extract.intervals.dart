import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

enum IntervalType { days, weeks, years }

class IntervalResult {
  final int count;
  final List<Map<String, DateTime>> subIntervals;

  IntervalResult(this.count, this.subIntervals);
}

IntervalResult extractIntervals(
  DateTime start,
  DateTime end,
  IntervalType type,
) {
  if (end.isBefore(start)) {
    throw ArgumentError("End date must be after start date");
  }

  List<Map<String, DateTime>> intervals = [];

  DateTime current = start;
  int count = 0;

  switch (type) {
    case IntervalType.days:
      while (!current.isAfter(end)) {
        intervals.add({"start": current, "end": current});
        current = current.add(const Duration(days: 1));
        count++;
      }
      break;

    case IntervalType.weeks:
      while (current.isBefore(end)) {
        DateTime weekEnd = current.add(const Duration(days: 6));
        if (weekEnd.isAfter(end)) weekEnd = end;

        intervals.add({"start": current, "end": weekEnd});

        current = weekEnd.add(const Duration(days: 1));
        count++;
      }
      break;

    case IntervalType.years:
      while (current.isBefore(end)) {
        DateTime yearEnd = DateTime(current.year, 12, 31);
        if (yearEnd.isAfter(end)) yearEnd = end;

        intervals.add({"start": current, "end": yearEnd});

        current = DateTime(current.year + 1, 1, 1);
        count++;
      }
      break;
  }

  return IntervalResult(count, intervals);
}


class ExtractIntervals extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const ExtractIntervals({
    Key? key,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  _ExtractIntervalsState createState() => _ExtractIntervalsState();
}

class _ExtractIntervalsState extends State<ExtractIntervals> {
  late DateTime _startDate;
  late DateTime _endDate;
  String _periodicity = 'days';

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStart ? _startDate : _endDate)) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: () => _selectDate(context, true),
              child: Text('Start: ${_startDate.toLocal()}'.split(' ')[0]),
            ),
            TextButton(
              onPressed: () => _selectDate(context, false),
              child: Text('End: ${_endDate.toLocal()}'.split(' ')[0]),
            ),
          ],
        ),
        DropdownButton<String>(
          value: _periodicity,
          onChanged: (String? newValue) {
            setState(() {
              _periodicity = newValue!;
            });
          },
          items: <String>['days', 'weeks', 'years']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<WidgetManipulatorCubit>().emitRandomElement({
              'id': 'filter_sales_by_date',
              'start_date': _startDate,
              'end_date': _endDate,
              'periodicity': _periodicity,
            });
          },
          child: const Text('Filter'),
        ),
      ],
    );
  }
}