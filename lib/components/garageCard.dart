import 'package:capstone_app/components/probabilityIndicator.dart';
import 'package:flutter/material.dart';

class GarageCard extends StatelessWidget {
  final String name;
  final double ticketProbability;

  GarageCard({
    @required this.name,
    @required this.ticketProbability
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
        onTap: () {
          // TODO: Navigate to garage details on tap
        },
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  name,
                  style: textStyle,
                ),
              ),
              Text(
                "${(ticketProbability * 100).round()}%",
                style: textStyle,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: ProbabilityIndicator(
                  diameter: 34.0,
                  probability: ticketProbability,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}