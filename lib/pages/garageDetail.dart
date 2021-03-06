import 'package:after_layout/after_layout.dart';
import 'package:capstone_app/components/probabilityIndicator.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:capstone_app/repositories/accountRepository.dart';
import 'package:capstone_app/repositories/filterRepository.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GarageDetailPage extends StatefulWidget {
  GarageDetailPage();

  @override
  GarageDetailPageState createState() => GarageDetailPageState();
}

class GarageDetailPageState extends State<GarageDetailPage> with AfterLayoutMixin<GarageDetailPage>{
  Garage _garage;

  FilterRepository _filterRepo = FilterRepository.getInstance();

  AccountRepository _accountRepo = AccountRepository.getInstance();

  bool _checkedIn = false;
  bool _loadingCheckedInState = true;

  static const int minBars = 1;
  static const int maxBars = 12;

  int numBars = 0;

  Duration durationPerBar;

  GlobalKey _bottomSheetKey = GlobalKey();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  double _preferredGoogleMapHeight = 0.0;

  @override
  initState() {
    super.initState();

    _initBars();
  }

  void _initBars() {
    Duration filterIntervalDuration = _filterRepo.intervalEnd.difference(_filterRepo.intervalStart);
    int numSegmentsInInterval = (filterIntervalDuration.inMinutes / 15).ceil();

    if (numSegmentsInInterval < minBars) {
      numBars = minBars;
    }
    else if (numSegmentsInInterval > maxBars) {
      numBars = maxBars;
    }
    else {
      numBars = numSegmentsInInterval;
    }

    durationPerBar = filterIntervalDuration ~/ numBars;
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_garage.name),
      centerTitle: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            Navigator.pushNamed(context, '/home/filter').then((value) {
              setState(() {
                _initBars();
              });
            });
          },
        )
      ],
      iconTheme: IconThemeData(
          color: Colors.white
      ),
    );
  }

  Widget _buildEnforcementLabel() {
    return Column(
      children: <Widget>[
        Text(
          "Enforced",
          style: TextStyle(fontSize: 28.0),
        ),
        Text(
            "${_garage.enforcementStartTime.format(context)} - ${_garage.enforcementEndTime.format(context)}"
        )
      ],
    );
  }

  Widget _buildProbabilityLabel(double ticketProbability) {
    return Column(
      children: <Widget>[
        Text(
          "${(ticketProbability * 100).round()}%",
          style: TextStyle(fontSize: 28.0),
        ),
        Text(
          "Chance of\nTicket",
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget _buildProbabilityChart() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        BorderRadius barRadius = BorderRadius.only(
            topLeft: Radius.circular(6.0),
            topRight: Radius.circular(6.0)
        );

        double barWidth = (constraints.maxWidth / numBars) * 0.6;

        TimeOfDay intervalStartTime = TimeOfDay.fromDateTime(_filterRepo.intervalStart);
        TimeOfDay intervalEndTime = TimeOfDay.fromDateTime(_filterRepo.intervalEnd);

        List<BarChartGroupData> groupData = [];

        for (int i = 0; i < numBars; i++) {
          double probability = _garage.getProbabilityForTimeInterval(_filterRepo.intervalStart.add(durationPerBar * i), _filterRepo.intervalStart.add(durationPerBar * (i + 1)));
          groupData.add(
              BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                        y: probability,
                        width: barWidth,
                        borderRadius: barRadius,
                        color: probability >= 0.5 ?getAppTheme().accentColor : getAppTheme().primaryColor
                    )
                  ]
              )
          );
        }

        return BarChart(
            BarChartData(
                maxY: 1.0,
                alignment: BarChartAlignment.center,
                groupsSpace: (constraints.maxWidth / numBars) * 0.2,
                borderData: FlBorderData(
                    show: true,
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.grey
                        )
                    )
                ),
                titlesData: FlTitlesData(
                    show: true,
                    leftTitles: SideTitles(
                        showTitles: false
                    ),
                    rightTitles: SideTitles(
                        showTitles: false
                    ),
                    bottomTitles: SideTitles(
                        showTitles: true,
                        getTitles: (double x) {
                          if (x == 0) {
                            return '${intervalStartTime.format(context)}';
                          }
                          else if (x == numBars - 1) {
                            return '${intervalEndTime.format(context)}';
                          }
                          else {
                            return '';
                          }
                        }
                    )
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (groupData, groupIndex, rodData, rodIndex) {
                      return BarTooltipItem(
                        "${(rodData.y * 100).round()}%",
                        TextStyle(
                          color: Colors.black
                        )
                      );
                    }
                  )
                ),
                gridData: FlGridData(
                  horizontalInterval: 0.25,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[300], strokeWidth: 1)
                ),
                barGroups: groupData
            )
        );
      },
    );
  }

  Widget _buildCheckInOutButton() {
    if (_loadingCheckedInState) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(getAppTheme().accentColor),
      );
    } else {
      return MaterialButton(
        onPressed: () {
          setState(() {
            _loadingCheckedInState = true;
          });

          if (_checkedIn) {
            _accountRepo.checkOutOfGarage()
                        .timeout(Duration(seconds: 30))
                        .catchError((_) {
                          debugPrint('Error checking out of garage');

                          SnackBar snackBar = SnackBar(
                            content: Text('Unable to check out'),
                          );

                          _scaffoldKey.currentState.showSnackBar(snackBar);
                        })
                        .whenComplete(() {
                          _accountRepo.isCheckedInTo(_garage).then((bool checkedIn) {
                            setState(() {
                              _loadingCheckedInState = false;
                              _checkedIn = checkedIn;
                            });
                          });
                        });
          } else {
            _accountRepo.checkInToGarage(_garage)
                        .timeout(Duration(seconds: 30))
                        .catchError((_) {
                          debugPrint('Error checking in to garage');

                          SnackBar snackBar = SnackBar(
                            content: Text('Unable to check in'),
                          );

                          _scaffoldKey.currentState.showSnackBar(snackBar);
                        })
                        .whenComplete(() {
                          _accountRepo.isCheckedInTo(_garage).then((bool checkedIn) {
                            setState(() {
                              _loadingCheckedInState = false;
                              _checkedIn = checkedIn;
                            });
                          });
                        });
          }
        },
        minWidth: double.infinity,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
        ),
        color: getAppTheme().accentColor,
        child: Text(
          _checkedIn ? "CHECK OUT" : "CHECK IN",
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_garage == null) {
      _garage = ModalRoute.of(context).settings.arguments;

      setState(() {
        _loadingCheckedInState = true;
      });

      _accountRepo.isCheckedInTo(_garage).then((checkedIn) {
        setState(() {
          _checkedIn = checkedIn;
          _loadingCheckedInState = false;
        });
      });
    }

    double ticketProbability = _garage.getProbabilityForTimeInterval(_filterRepo.intervalStart, _filterRepo.intervalEnd);

    Set<Marker> markers = Set();
    markers.add(Marker(
      markerId: MarkerId(_garage.name),
      position: _garage.location
    ));

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: Stack(
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
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
                key: _bottomSheetKey,
                elevation: 8.0,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15.0),
                  topLeft: Radius.circular(15.0),
                ),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 25.0),
                          child: Row(
                            children: <Widget>[
                              _buildEnforcementLabel(),
                              Spacer(),
                              _buildProbabilityLabel(ticketProbability),
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: ProbabilityIndicator(
                                  diameter: 70,
                                  probability: ticketProbability,
                                ),
                              )
                            ],
                          ),
                        ),
                        _buildProbabilityChart(),
                        _buildCheckInOutButton(),
                      ],
                    ),
                  ),
                )
            ),
          ),
        ],
      ),
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
