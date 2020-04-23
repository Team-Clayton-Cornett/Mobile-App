import 'package:flutter/material.dart';
import 'package:capstone_app/models/park.dart';

class HistoryCard extends StatelessWidget{

  final Park historyPark;

  HistoryCard({
    @required this.historyPark
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
        fontSize: 18.0
    );

    return Card(
        margin: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
        elevation: 1.0,
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                  historyPark.garageName,
                  style: textStyle,
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}