import 'package:after_layout/after_layout.dart';
import 'package:capstone_app/components/probabilityIndicator.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:capstone_app/models/park.dart';
import 'package:capstone_app/repositories/accountRepository.dart';
import 'package:capstone_app/repositories/filterRepository.dart';
import 'package:capstone_app/repositories/garageRepository.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';


class HistoryDetailPage extends StatefulWidget {
  HistoryDetailPage();

  @override
  HistoryDetailPageState createState() => HistoryDetailPageState();
}

class HistoryDetailPageState extends State<HistoryDetailPage> with AfterLayoutMixin<HistoryDetailPage>{
  Garage _garage;
  Park _park;

  AccountRepository _accountRepo = AccountRepository.getInstance();

  GarageRepository _garageRepo = GarageRepository.getInstance();
  List<Garage> _garages = List();

  Future<List<Garage>> _garageFuture;

  bool _Ticketed = false;

  GlobalKey _bottomSheetKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double _preferredGoogleMapHeight = 0.0;

  @override
  initState() {
    super.initState();

    _garageFuture = _garageRepo.getGarages().timeout(Duration(seconds: 30));
  }


  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_park.garageName),
      centerTitle: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            Navigator.pushNamed(context, '/home/filter');
          },
        )
      ],
      iconTheme: IconThemeData(
          color: Colors.white
      ),
    );
  }

  Widget _ticketedWidget(){
    return  Align(
        alignment: Alignment.bottomCenter,
        child: Material(
            elevation: 8.0,
            child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  "TICKETED",
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                )
            )
        )
    );
  }

  Widget _unTicketedWidget(){
    return Padding(
//      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
            "NOT TICKETED",
              style:TextStyle(
                  fontWeight:FontWeight.bold
              )
            ),
          ),
          MaterialButton(
            onPressed: () {
              print("Reported");
              _accountRepo.reportTicketForPark(DateTime.now(), _park);
              setState(() {
                _Ticketed = true;
              });
              print("Test" + _Ticketed.toString());
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
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = Set();
    if (_park == null) {
      setState(() {
        _park = ModalRoute.of(context).settings.arguments;
        if(_park.ticketDateTime == null){
          _Ticketed = false;
        } else{
          _Ticketed = true;
        }
      });
      _garageFuture.then((List<Garage> garages) async {
        for(Garage garage in garages) {
          if(_park.garageId == garage.id){
            setState(() {
              _garage = garage;
            });
            print(_garage.name);
            markers.add(Marker(
              markerId: MarkerId(_garage.name),
              position: _garage.location
            ));
          }
        }
      });
    }

//    Set<Marker> markers = Set();
//    markers.add(Marker(
//        markerId: MarkerId(_garage.name),
//        position: _garage.location
//    ));

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: Stack(
        children: <Widget>[
//          Container(
//            height: _preferredGoogleMapHeight == 0 ? MediaQuery.of(context).size.height * 0.45 : _preferredGoogleMapHeight,
//            child: GoogleMap(
//              initialCameraPosition: CameraPosition(
////                  target: _garage.location,
//                  zoom: 16.0
//              ),
////              markers: markers,
//              myLocationButtonEnabled: false,
//              scrollGesturesEnabled: false,
//              zoomGesturesEnabled: false,
//              rotateGesturesEnabled: false,
//            ),
//          ),
          Align(
              alignment: Alignment.center,
              child: Material(
                key: _bottomSheetKey,
                elevation: 8.0,
                child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Text(
                        "Start Date: " + new DateFormat.yMMMd().format(_park.start) + "\n" + new DateFormat.jm().format(_park.start) + "\n"
                            "End Date: " + new DateFormat.yMMMd().format(_park.end) + "\n" + new DateFormat.jm().format(_park.end) + "\n",
                      //              "End Date: " + _park.end.toString()
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      )
                )
              )
          ),
          Center(
              child: _Ticketed == false ? _unTicketedWidget() : _ticketedWidget()
          )
        ],
      )
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    RenderBox bottomSheetRenderBox = _bottomSheetKey.currentContext.findRenderObject();
    double bottomSheetHeight = bottomSheetRenderBox.size.height;

    setState(() {
      _preferredGoogleMapHeight = MediaQuery.of(context).size.height - bottomSheetHeight;
    });
  }
}