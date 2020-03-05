import 'package:capstone_app/repositories/filterRepository.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';

class FilterPage extends StatefulWidget {
  @override
  FilterPageState createState() => FilterPageState();
}

class FilterPageState extends State<FilterPage> {
  FilterRepository _filterRepo = FilterRepository.getInstance();

  RangeValues _rangeValues;

  DateTime _selectedDate;

  int _getIndexForTimeOfDay(TimeOfDay timeOfDay) {
    return (timeOfDay.hour * 4) + (timeOfDay.minute / 15).truncate();
  }

  TimeOfDay _getTimeOfDayForIndex(int index) {
    int hour = (index / 4).truncate();
    int minute = (index % 4) * 15;

    return TimeOfDay(hour: hour, minute: minute);
  }

  void _applyNewFilterParams() {
    TimeOfDay newStartTime = _getTimeOfDayForIndex(_rangeValues.start.truncate());
    DateTime newIntervalStart = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, newStartTime.hour, newStartTime.minute);

    TimeOfDay newEndTime = _getTimeOfDayForIndex(_rangeValues.end.truncate());
    DateTime newIntervalEnd = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, newEndTime.hour, newEndTime.minute);

    if (newIntervalEnd.isBefore(newIntervalStart) || newIntervalEnd.isAtSameMomentAs(newIntervalStart)) {
      newIntervalEnd.add(Duration(days: 1));
    }

    _filterRepo.intervalStart = newIntervalStart;
    _filterRepo.intervalEnd = newIntervalEnd;
  }

  @override
  void initState() {
    super.initState();

    double rangeStart = _getIndexForTimeOfDay(TimeOfDay.fromDateTime(_filterRepo.intervalStart)).toDouble();
    double rangeEnd = _getIndexForTimeOfDay(TimeOfDay.fromDateTime(_filterRepo.intervalEnd)).toDouble();

    // Since the time range both starts and ends at 12:00am, if the range end is calculated to be 0,
    // it really should be the second 12:00am, which is the last index in the range
    if (rangeEnd == 0) {
      rangeEnd = 24.0 * 4;
    }

    _rangeValues = RangeValues(rangeStart, rangeEnd);

    _selectedDate = _filterRepo.intervalStart;
  }

  @override
  Widget build(BuildContext context) {
    String startTimeOfDay = _getTimeOfDayForIndex(_rangeValues.start.truncate()).format(context);
    String endTimeOfDay = _getTimeOfDayForIndex(_rangeValues.end.truncate()).format(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Filter'),
        centerTitle: false,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 35.0,
                bottom: 20.0
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    '12am',
                    style: TextStyle(
                      color: Colors.grey
                    ),
                  ),
                  Expanded(
                    child: RangeSlider(
                      values: _rangeValues,
                      min: 0.0,
                      max: 24.0 * 4,
                      divisions: 24 * 4,
                      onChanged: (RangeValues newValues) {
                        setState(() {
                          if (newValues.end - newValues.start >= 1.0) {
                            _rangeValues = newValues;
                          }
                        });
                      },
                      labels: RangeLabels('$startTimeOfDay', '$endTimeOfDay'),
                      activeColor: getAppTheme().primaryColor,
                    ),
                  ),
                  Text(
                    '12am',
                    style: TextStyle(
                      color: Colors.grey
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CalendarCarousel(
                selectedDateTime: _selectedDate,
                minSelectedDate: DateTime.now().subtract(Duration(days: 1)),
                onDayPressed: (date, events) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                todayButtonColor: Colors.grey[400],
                selectedDayButtonColor: getAppTheme().accentColor,
                weekendTextStyle: TextStyle(
                  color: Colors.black
                ),
                weekdayTextStyle: TextStyle(
                  color: getAppTheme().accentColor
                ),
                headerTextStyle: TextStyle(
                  fontSize: 20.0,
                  color: getAppTheme().primaryColor
                ),
                iconColor: getAppTheme().primaryColor,
              ),
            ),
            MaterialButton(
              onPressed: () {
                _applyNewFilterParams();

                Navigator.pop(context);
              },
              minWidth: double.infinity,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              color: getAppTheme().accentColor,
              child: Text(
                "APPLY",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

}