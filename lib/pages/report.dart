import 'package:capstone_app/components/navigationDrawer.dart';
import 'package:capstone_app/repositories/reportRepository.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:capstone_app/repositories/garageRepository.dart';
import 'package:capstone_app/repositories/accountRepository.dart';


class ReportPage extends StatefulWidget {
  @override
  ReportPageState createState() => ReportPageState();
}

class ReportPageState extends State<ReportPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ReportRepository _reportRepo = ReportRepository.getInstance();

  AccountRepository _accountRepo = AccountRepository.getInstance();

  GarageRepository _garageRepo = GarageRepository.getInstance();
  List<Garage> _garages = List();
  Future<List<Garage>> _garageFuture;

  DateTime _selectedDate;
  Garage currentSelectedValue;

  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay picked;

  void _reportGarage() {
//    TimeOfDay newStartTime = _getTimeOfDayForIndex(_selectedTime.truncate());
    DateTime reportTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _time.hour, _time.minute);
   if(currentSelectedValue != null){
     _accountRepo.reportTicketForGarage(reportTime, currentSelectedValue);
     print("Reported");
     SnackBar snackBar = SnackBar(
       content: Text("Reported"),
     );

     _scaffoldKey.currentState.showSnackBar(snackBar);
   } else{
     SnackBar snackBar = SnackBar(
       content: Text("Unable to Report Ticket"),
     );

     _scaffoldKey.currentState.showSnackBar(snackBar);
   }
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = _reportRepo.intervalStart;
    _garageFuture = _garageRepo.getGarages().timeout(Duration(seconds: 30));

    _garageFuture.then((List<Garage> garages) async {
      setState(() {
        _garages = garages;
      });
    });
  }

  Widget _typeFieldWidget(){
    return Padding(
      padding: EdgeInsets.only(
          top: 5.0,
          bottom: 5.0
      ),

              child: DropdownButton<Garage>(
                hint: Text("Select Garage"),
                value: currentSelectedValue,
                onChanged: (Garage newValue) {
                  setState(() {
                    currentSelectedValue = newValue;
                  });
                  print(currentSelectedValue.name);
                },
                items: _garages.map((Garage value) {
                  return DropdownMenuItem<Garage>(
                    value: value,
                    child: Text(value.name),
                  );
                }).toList(),
              ),
            );
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


    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Report'),
        centerTitle: false,
        iconTheme: IconThemeData(
            color: Colors.white
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            _typeFieldWidget(),
//            _typeTimeWidget(),
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
                maxSelectedDate: DateTime.now(),
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