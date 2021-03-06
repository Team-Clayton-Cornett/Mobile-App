import 'package:capstone_app/components/navigationDrawer.dart';
import 'package:capstone_app/repositories/reportRepository.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:capstone_app/repositories/accountRepository.dart';
import 'package:capstone_app/models/park.dart';


import 'package:intl/intl.dart';

class ReportParkPage extends StatefulWidget {
  @override
  ReportParkPageState createState() => ReportParkPageState();
}

class ReportParkPageState extends State<ReportParkPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ReportRepository _reportRepo = ReportRepository.getInstance();

  AccountRepository _accountRepo = AccountRepository.getInstance();

  Park _park;

  DateTime _selectedDate;

  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay picked;

  void _reportGarage() {
//    TimeOfDay newStartTime = _getTimeOfDayForIndex(_selectedTime.truncate());
    DateTime reportTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _time.hour, _time.minute);
    if(reportTime.isAfter(_park.start) && reportTime.isBefore(_park.end) ){
      _accountRepo.reportTicketForPark(reportTime, _park);
      print("Reported");
      SnackBar snackBar = SnackBar(
        content: Text("Reported"),
      );

      _scaffoldKey.currentState.showSnackBar(snackBar);
//      Navigator.of(context).pushReplacementNamed('/history');
    } else{
      print("Ticket must be reported between parking hours");
      SnackBar snackBar = SnackBar(
        content: Text("Ticket must be between: " + new DateFormat.yMMMd().format(_park.start) + " " + new DateFormat.jm().format(_park.start)
            + "-"+ new DateFormat.yMMMd().format(_park.end) + " " + new DateFormat.jm().format(_park.end)),
        duration: Duration(seconds: 7),
      );

      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = _reportRepo.intervalStart;
  }

  Future<Null>selectTime(BuildContext context)async{
    picked=await showTimePicker(
        context:context,
        initialTime:_time
    );

    if(picked!= null){
      setState((){
        _time=picked;
        print(_time);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
//    String startTimeOfDay = _getTimeOfDayForIndex(_selectedTime.truncate()).format(context);
  if(_park == null){
    setState(() {
      _park = ModalRoute.of(context).settings.arguments;
      _selectedDate = _park.start;
    });
  }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Report '+ _park.garageName),
        centerTitle: false,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Center(
                child: IconButton(
                  icon: Icon(Icons.alarm),
                  onPressed: (){
                    selectTime(context);
                  },
                )
            ),
            Expanded(
              child: CalendarCarousel(
                selectedDateTime: _selectedDate,
                minSelectedDate: _park.start.subtract(Duration(days: 1)),
                maxSelectedDate: _park.end,
                onDayPressed: (date, events) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                todayButtonColor: Colors.transparent,
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
                _reportGarage();
//                createSnackBar();
              },
              minWidth: double.infinity,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              color: getAppTheme().accentColor,
              child: Text(
                "REPORT",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
      drawer: NavigationDrawer(
        currentPage: widget,
      ),
    );
  }
//  void createSnackBar() {
//    final snackBar = new SnackBar(content: new Text("Reported"));
//
//    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
//    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
//  }
}