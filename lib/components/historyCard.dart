import 'package:flutter/material.dart';
import 'package:capstone_app/models/park.dart';
import 'package:intl/intl.dart';

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

    String stringStart = DateFormat.Md().add_jm().format(historyPark.start);
    String stringEnd = DateFormat.Md().add_jm().format(historyPark.end);

    return Card(
        margin: EdgeInsets.fromLTRB(15.5, 5.0, 15.0, 15.0),
        elevation: 1.0,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/history/history_details', arguments: historyPark);
          },
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                  historyPark.garageName + '    \n' + stringStart + '  --  ' + stringEnd ,
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