import 'package:intl/intl.dart';

Map<String, dynamic> getSubIntervals(
  DateTime start,
  DateTime end,
  String unit,
) {
  List<Map<String, DateTime>> subIntervals = [];
  int count = 0;
  DateTime current = start;

  while (current.isBefore(end)) {
    DateTime next;
    switch (unit) {
      case 'days':
        next = current.add(Duration(days: 1));
        break;
      case 'weeks':
        next = current.add(Duration(days: 7));
        break;
      case 'months':
        int year = current.year;
        int month = current.month + 1;
        if (month > 12) {
          year += 1;
          month = 1;
        }
        // Handle months with fewer days safely
        int day = current.day;
        int lastDayOfNextMonth = DateTime(year, month + 1, 0).day;
        if (day > lastDayOfNextMonth) {
          day = lastDayOfNextMonth;
        }
        next = DateTime(
          year,
          month,
          day,
          current.hour,
          current.minute,
          current.second,
          current.millisecond,
          current.microsecond,
        );
        break;
      case 'years':
        next = DateTime(current.year + 1, current.month, current.day);
        break;
      default:
        throw ArgumentError('Invalid unit: $unit');
    }
    if (next.isAfter(end)) next = end;
    subIntervals.add({'start': current, 'end': next});
    count++;
    current = next;
  }

  return {'count': count, 'subIntervals': subIntervals};
}
