class ReportRepository {
  static final ReportRepository _instance = ReportRepository._initialize();

  DateTime _intervalStart;

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

  ReportRepository._initialize() {
    // Default the report interval to a 1 hour interval starting in the current time slot
    intervalStart = DateTime.now();
  }

  static ReportRepository getInstance() {
    return _instance;
  }
}