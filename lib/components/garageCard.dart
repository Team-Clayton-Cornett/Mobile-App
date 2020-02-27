import 'package:capstone_app/components/probabilityIndicator.dart';
import 'package:capstone_app/models/garage.dart';
import 'package:capstone_app/repositories/filterRepository.dart';
import 'package:flutter/material.dart';

class GarageCard extends StatelessWidget {
  final Garage garage;
  final FilterRepository _filterRepo = FilterRepository.getInstance();

  GarageCard({
    @required this.garage,
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
          Navigator.pushNamed(context, '/home/garage_details', arguments: garage);
        },
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  garage.name,
                  style: textStyle,
                ),
              ),
              Text(
                "${(garage.getProbabilityForTimeInterval(_filterRepo.intervalStart, _filterRepo.intervalEnd) * 100).round()}%",
                style: textStyle,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: ProbabilityIndicator(
                  diameter: 34.0,
                  probability: garage.getProbabilityForTimeInterval(_filterRepo.intervalStart, _filterRepo.intervalEnd),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}