import 'package:after_layout/after_layout.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:capstone_app/models/park.dart';
import 'package:capstone_app/repositories/accountRepository.dart';
import 'package:capstone_app/repositories/garageRepository.dart';
import 'package:capstone_app/style/appTheme.dart';
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

  Set<Marker> markers = Set();

  GarageRepository _garageRepo = GarageRepository.getInstance();
  Future<List<Garage>> _garageFuture;

  bool _ticketed = false;

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
      iconTheme: IconThemeData(
          color: Colors.white
      ),
    );
  }

  Widget _ticketedWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Ticketed: ",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
        ),
        Text(
//          "TICKETED",
          new DateFormat.yMMMd().format(_park.ticketDateTime) + " " +
              new DateFormat.jm().format(_park.ticketDateTime),
          style: TextStyle(
              fontSize: 20
          ),
        )
      ],
    );
  }

  Widget _unTicketedWidget(){
    return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Ticketed: ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
              Text(
                "NOT TICKETED",
                style: TextStyle(
                    fontSize: 20
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          MaterialButton(
            onPressed: () {
              print("Reported");
              Navigator.pushNamed(context, 'history/history_details/report_park', arguments: _park);
//              setState(() {
//                _Ticketed = true;
//              });
              print("Test" + _ticketed.toString());
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_park == null) {
      setState(() {
        _park = ModalRoute.of(context).settings.arguments;
        if(_park.ticketDateTime == null){
          _ticketed = false;
        } else{
          _ticketed = true;
        }
      });
//      print(_park.ticketDateTime);
      _garageFuture.then((List<Garage> garages) async {
        for(Garage garage in garages) {
          if(_park.garageId == garage.id){
            setState(() {
              _garage = garage;
              markers.add(Marker(
                  markerId: MarkerId(garage.name),
                  position: garage.location
              ));
//              print(garage.location);
            });
//            print(_park.garageName);
            print(_garage.name);
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
      body: Padding(
          padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Container(
              height: _preferredGoogleMapHeight == 0 ? MediaQuery.of(context).size.height * 0.45 : _preferredGoogleMapHeight,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                    target: _garage.location,
                    zoom: 16.0
                ),
                markers: markers,
                myLocationButtonEnabled: false,
//              scrollGesturesEnabled: false,
//              zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Start Date: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
                Text(
                    new DateFormat.yMMMd().format(_park.start) + " " +
                        new DateFormat.jm().format(_park.start),
                    style: TextStyle(
                      fontSize: 20
                    ),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "End Date: ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                ),
                Text(
                  new DateFormat.yMMMd().format(_park.end) + " " +
                        new DateFormat.jm().format(_park.end),
                  style: TextStyle(
                      fontSize: 20
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Center(
                child: _ticketed == false ? _unTicketedWidget() : _ticketedWidget()
            )
          ],
        )
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
