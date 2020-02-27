import 'package:capstone_app/components/probabilityIndicator.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:capstone_app/repositories/filterRepository.dart';
import 'package:capstone_app/style/appTheme.dart';
import 'package:flutter/material.dart';

class GarageDetailPage extends StatefulWidget {
  GarageDetailPage();

  @override
  GarageDetailPageState createState() => GarageDetailPageState();
}

class GarageDetailPageState extends State<GarageDetailPage> {
  Garage _garage;

  FilterRepository _filterRepo = FilterRepository.getInstance();

  bool _checkedIn = false;

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(_garage.name),
      centerTitle: false,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Navigate to filter page
          },
        )
      ],
      iconTheme: IconThemeData(color: Colors.white),
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
            "${_garage.enforcementStartTime.format(context)} - ${_garage.enforcementEndTime.format(context)}")
      ],
    );
  }

  Widget _buildProbabilityLabel(double ticketProbability) {
    Column(
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

  @override
  Widget build(BuildContext context) {
    if (_garage == null) {
      _garage = ModalRoute.of(context).settings.arguments;
    }

    double ticketProbability = _garage.getProbabilityForTimeInterval(_filterRepo.intervalStart, _filterRepo.intervalEnd);

    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: <Widget>[
          // TODO: Replace container with either map or garage image
          Container(
            color: Colors.red,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Material(
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
                        // TODO: Replace container with bar graph
                        Container(
                          margin: EdgeInsets.only(bottom: 20.0),
                          height: 200,
                          color: Colors.green,
                        ),
                        MaterialButton(
                          onPressed: () {
                            setState(() {
                              // TODO: Notify repository of user check in
                              _checkedIn = !_checkedIn;
                            });
                          },
                          minWidth: double.infinity,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          color: getAppTheme().accentColor,
                          child: Text(
                            _checkedIn ? "CHECK OUT" : "CHECK IN",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
