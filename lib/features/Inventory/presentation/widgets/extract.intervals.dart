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
