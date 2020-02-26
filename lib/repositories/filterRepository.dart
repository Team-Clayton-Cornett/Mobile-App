class FilterRepository {
  static final FilterRepository _instance = FilterRepository._initialize();

  DateTime _intervalStart;
  DateTime _intervalEnd;

  DateTime get intervalStart => _intervalStart;

  set intervalStart(DateTime newIntervalStart) {
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

  FilterRepository._initialize() {
    // Default the filter interval to a 1 hour interval starting in the current time slot
    intervalStart = DateTime.now();
    intervalEnd = DateTime.now().add(Duration(hours: 1));
  }

  static FilterRepository getInstance() {
    return _instance;
  }
}