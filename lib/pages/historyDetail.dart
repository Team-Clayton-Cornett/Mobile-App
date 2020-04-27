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
  FilterRepository _filterRepo = FilterRepository.getInstance();
  var _garages;

  bool _Ticketed = false;
  bool _loadingTicketedState = true;

  GlobalKey _bottomSheetKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double _preferredGoogleMapHeight = 0.0;

  @override
  initState() {
    super.initState();
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

  Widget _buildTicketedButton(){
    return  Align(
        alignment: Alignment.bottomCenter,
        child: Material(
            elevation: 8.0,
            child: Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  "Test",
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                )
            )
        )
    );
//    if (_loadingTicketedState) {
//      return CircularProgressIndicator(
//        valueColor: AlwaysStoppedAnimation<Color>(getAppTheme().accentColor),
//      );
//    } else{
//      return MaterialButton(
//        onPressed: () {
//          setState(() {
//            _loadingTicketedState = true;
//          });
//
//          if (_Ticketed) {
//                setState(() {
//                  _loadingTicketedState = false;
//                  _Ticketed = checkedIn;
//                });
//          } else {
//            _accountRepo.checkInToGarage(_garage)
//                .timeout(Duration(seconds: 30))
//                .catchError((_) {
//              debugPrint('Error checking in to garage');
//
//              SnackBar snackBar = SnackBar(
//                content: Text('Unable to check in'),
//              );
//
//              _scaffoldKey.currentState.showSnackBar(snackBar);
//            })
//                .whenComplete(() {
//              _accountRepo.isCheckedInTo(_garage).then((bool checkedIn) {
//                setState(() {
//                  _loadingCheckedInState = false;
//                  _checkedIn = checkedIn;
//                });
//              });
//            });
//          }
//        },
//        minWidth: double.infinity,
//        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//        shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(10.0)
//        ),
//        color: getAppTheme().accentColor,
//        child: Text(
//          _Ticketed ? "TICKETED" : "NOT TICKETED",
//          style: TextStyle(color: Colors.white),
//        ),
//      );
//    }
  }

  @override
  Widget build(BuildContext context) {
    if (_park == null) {
      _park = ModalRoute.of(context).settings.arguments;
//      _garages = _garageRepository.getGarages();
//      for(var item in _garages){
//        if(_park.garageId == item.id){
//          _garage = item;
//        }
//      }
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
          _buildTicketedButton()
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
