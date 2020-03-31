import 'package:flutter/material.dart';

class Park {
  int id;
  DateTime start;
  DateTime end;
  int garageId;
  String garageName;
  DateTime ticketDateTime;

  Park({
    @required this.id,
    @required this.start,
    @required this.end,
    @required this.garageId,
    @required this.garageName
  });

  Park.fromJson(Map<String, dynamic> json) :
    id = json['pk'],
    start = DateTime.parse(json['start']),
    end = DateTime.parse(json['end']),
    garageId = json['garage']['pk'],
    garageName = json['garage']['name'],
    ticketDateTime = (json['ticket'] != null) ? DateTime.parse(json['ticket']['date']) : null;
}