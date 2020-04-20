import 'package:clock/clock.dart';

class FilterRepository {
  static FilterRepository _instance;

  DateTime _intervalStart;
  DateTime _intervalEnd;

  DateTime get intervalStart => _intervalStart;

  set intervalStart(DateTime newIntervalStart) {
    if (intervalEnd != null) {
      assert(newIntervalStart.isBefore(intervalEnd));
    }

    // Round the new interval start to an even 15 minute boundary
    newIntervalStart = newIntervalStart.subtract(
      Duration(
        minutes: newIntervalStart.minute % 15,
        seconds: newIntervalStart.second,
        milliseconds: newIntervalStart.millisecond,
        microseconds: newIntervalStart.microsecond
      )
    );

    _intervalStart = newIntervalStart;
  }

  DateTime get intervalEnd => _intervalEnd;

  set intervalEnd(DateTime newIntervalEnd) {
    if (intervalStart != null) {
      assert(newIntervalEnd.isAfter(intervalStart));
    }

    // Round the new interval end to an even 15 minute boundary
    newIntervalEnd = newIntervalEnd.subtract(
      Duration(
        minutes: newIntervalEnd.minute % 15,
        seconds: newIntervalEnd.second,
        milliseconds: newIntervalEnd.millisecond,
        microseconds: newIntervalEnd.microsecond
      )
    );

    _intervalEnd = newIntervalEnd;
  }

  FilterRepository._initialize(Clock clock) {
    // Default the filter interval to a 1 hour interval starting in the current time slot
    intervalStart = clock.now();
    intervalEnd = intervalStart.add(Duration(hours: 1));
  }

  static FilterRepository getInstance([Clock clock]) {
    if (clock != null) {
      _instance = FilterRepository._initialize(clock);
    }
    else if (_instance == null) {
      clock = Clock();
      _instance = FilterRepository._initialize(clock);
    }

    return _instance;
  }
}